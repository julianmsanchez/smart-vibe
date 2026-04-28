#!/usr/bin/env bash
# scripts/doctor.sh
# Chequea estado de un proyecto smart-vibe. Reporta gaps por modo.
#
# Uso:
#   bash scripts/doctor.sh                              # chequeo general (cwd)
#   bash scripts/doctor.sh --quiet                      # sólo errores
#   bash scripts/doctor.sh phs validate <path>          # valida phs.yaml
#   bash scripts/doctor.sh workshop validate <path>     # valida workshop.yaml

set -uo pipefail

QUIET=0
EXIT_CODE=0

# --- helpers ---
ok()    { [[ $QUIET -eq 0 ]] && echo "✓ $*"; }
warn()  { echo "⚠ $*"; EXIT_CODE=$((EXIT_CODE > 1 ? EXIT_CODE : 1)); }
fail()  { echo "✗ $*"; EXIT_CODE=2; }
info()  { [[ $QUIET -eq 0 ]] && echo "  $*"; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- subcomandos ---
# Validación YAML básica (parse) usando python3 si está disponible.
# La validación Zod estricta queda para `pnpm validate` dentro del proyecto
# (que tiene acceso a las deps TS) — ver TODO Fase 2.
yaml_parse() {
  local path="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import yaml,sys; yaml.safe_load(open('$path'))" 2>&1
    return $?
  fi
  return 0  # sin python3, asumimos OK
}

cmd_phs_validate() {
  local path="${1:-phs.yaml}"
  if [[ ! -f "$path" ]]; then
    fail "phs.yaml no encontrado: $path"
    return
  fi
  if ! yaml_parse "$path" >/dev/null 2>&1; then
    fail "phs.yaml tiene YAML inválido: $path"
    return
  fi
  ok "phs.yaml válido (parse): $path"
  info "Validación Zod estricta: correr 'pnpm validate' dentro del proyecto (TODO Fase 2)"
}

cmd_workshop_validate() {
  local path="${1:-workshop.yaml}"
  if [[ ! -f "$path" ]]; then
    fail "workshop.yaml no encontrado: $path"
    return
  fi
  if ! yaml_parse "$path" >/dev/null 2>&1; then
    fail "workshop.yaml tiene YAML inválido: $path"
    return
  fi
  ok "workshop.yaml válido (parse): $path"
  info "Validación Zod estricta: correr 'pnpm validate' dentro del proyecto (TODO Fase 2)"
}

cmd_general() {
  echo "=== smart-vibe doctor ==="
  echo ""

  # 1. PHS presente
  if [[ -f phs.yaml ]]; then
    ok "phs.yaml presente"
    cmd_phs_validate phs.yaml
  else
    fail "phs.yaml ausente. Correr: bash $REPO_ROOT/scripts/bootstrap.sh"
    return
  fi

  # 2. Workshop (si type=workshop)
  if grep -qE "^\s*type:\s*workshop" phs.yaml 2>/dev/null; then
    if [[ -f workshop.yaml ]]; then
      ok "workshop.yaml presente (proyecto type=workshop)"
      cmd_workshop_validate workshop.yaml

      # 2.a. Campos pendientes del workshop.yaml (warns guiando al checklist).
      grep -qE "^[[:space:]]*apis_external:[[:space:]]*\[\]" workshop.yaml \
        && warn "workshop.yaml: apis_external está vacío. Ver ORGANIZER-CHECKLIST.md paso 1."
      grep -qE "^[[:space:]]*storage:[[:space:]]*\[\]" workshop.yaml \
        && warn "workshop.yaml: storage está vacío (OK si ningún team lo usa)."
      grep -qE "^[[:space:]]*members:[[:space:]]*\[\]" workshop.yaml \
        && warn "workshop.yaml: teams[].members con entries vacías. Ver checklist paso 1."
      grep -qE "^[[:space:]]*domain:[[:space:]]*~" workshop.yaml \
        && warn "workshop.yaml: teams[].domain sin completar. Ver checklist paso 1."

      # 2.b. Env files presentes (modelo two-layer).
      if [[ -f .env.shared.example ]]; then
        ok ".env.shared.example presente (capa global)"
      else
        warn ".env.shared.example ausente (esperado en workshop)."
      fi
      for team_app in apps/*/; do
        case "$team_app" in
          apps/_team-template/|apps/shell/) continue ;;
        esac
        if [[ ! -f "${team_app}.env.local.example" ]]; then
          warn "${team_app}.env.local.example ausente (capa team-specific)."
        fi
      done
    else
      fail "type=workshop pero falta workshop.yaml"
    fi
  fi

  # 3. README
  if [[ -f README.md && -s README.md ]]; then
    ok "README.md presente"
  else
    warn "README.md ausente o vacío. Ver core/playbooks/04-no-readme.md"
  fi

  # 4. .env.example (o .env.shared.example en workshop)
  local env_example=""
  if [[ -f .env.example ]]; then env_example=".env.example"; fi
  if [[ -z "$env_example" && -f .env.shared.example ]]; then env_example=".env.shared.example"; fi

  if [[ -n "$env_example" ]]; then
    ok "$env_example presente"
    # comparar con vars consumidas
    if [[ -d src ]]; then
      local consumed example diff
      consumed=$(grep -rhoE "process\.env\.[A-Z_][A-Z0-9_]+" src/ 2>/dev/null \
        | sed 's/process\.env\.//' | sort -u)
      example=$(grep -E "^[A-Z_][A-Z0-9_]+=" "$env_example" 2>/dev/null \
        | cut -d= -f1 | sort -u)
      diff=$(comm -23 <(echo "$consumed") <(echo "$example") 2>/dev/null)
      if [[ -n "$diff" ]]; then
        warn "vars consumidas no documentadas en $env_example:"
        echo "$diff" | sed 's/^/    - /'
      fi
    fi
  else
    warn ".env.example ausente. Ver core/playbooks/05-no-env-example.md"
  fi

  # 5. .env NO commiteado
  if [[ -f .env ]]; then
    if git ls-files --error-unmatch .env 2>/dev/null >/dev/null; then
      fail ".env está commiteado al repo. Ver core/playbooks/01-hardcoded-secrets.md"
    else
      ok ".env presente y gitignored"
    fi
  fi

  # 6. tests presentes
  local test_count
  test_count=$(find . -path ./node_modules -prune -o -name "*.test.ts" -print -o -name "*.test.tsx" -print -o -name "*.spec.ts" -print 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$test_count" -gt 0 ]]; then
    ok "$test_count test file(s) detectado(s)"
  else
    warn "Sin tests automatizados. Ver core/playbooks/03-no-tests.md"
  fi

  # 7. CLAUDE.md
  if [[ -f CLAUDE.md ]]; then
    ok "CLAUDE.md presente"
  else
    warn "CLAUDE.md ausente"
  fi

  # 8. policies docs
  if [[ -d docs/policies ]]; then
    ok "docs/policies/ presente"
  else
    warn "docs/policies/ ausente"
  fi

  echo ""
  if [[ $EXIT_CODE -eq 0 ]]; then
    echo "✓ All checks passed."
  elif [[ $EXIT_CODE -eq 1 ]]; then
    echo "⚠ Warnings detectados (modo vibe los tolera; en graduating son errores)."
  else
    echo "✗ Errors detectados. Ver mensajes arriba."
  fi
}

# --- entry ---
case "${1:-}" in
  --quiet) QUIET=1; shift; cmd_general ;;
  phs)
    case "${2:-}" in
      validate) cmd_phs_validate "${3:-phs.yaml}" ;;
      *) echo "Uso: doctor.sh phs validate <path>"; exit 2 ;;
    esac
    ;;
  workshop)
    case "${2:-}" in
      validate) cmd_workshop_validate "${3:-workshop.yaml}" ;;
      *) echo "Uso: doctor.sh workshop validate <path>"; exit 2 ;;
    esac
    ;;
  -h|--help)
    sed -n '2,11p' "$0"
    exit 0
    ;;
  ""|*)
    cmd_general
    ;;
esac

exit $EXIT_CODE
