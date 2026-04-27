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
cmd_phs_validate() {
  local path="${1:-phs.yaml}"
  if [[ ! -f "$path" ]]; then
    fail "phs.yaml no encontrado: $path"
    return
  fi

  if command -v node >/dev/null 2>&1 && [[ -f "$REPO_ROOT/core/phs/schema.ts" ]]; then
    info "Validando $path con Zod schema..."
    node -e "
      const yaml = require('js-yaml');
      const fs = require('fs');
      const { phsSchema } = require('$REPO_ROOT/core/phs/schema.ts');
      const doc = yaml.load(fs.readFileSync('$path', 'utf8'));
      const r = phsSchema.safeParse(doc);
      if (!r.success) { console.error(JSON.stringify(r.error.format(), null, 2)); process.exit(1); }
      console.log('OK');
    " 2>&1 || fail "PHS validation failed"
  else
    warn "node/js-yaml no disponibles; validación skipeada (sólo chequeo de presencia)"
  fi
  ok "phs.yaml presente: $path"
}

cmd_workshop_validate() {
  local path="${1:-workshop.yaml}"
  if [[ ! -f "$path" ]]; then
    fail "workshop.yaml no encontrado: $path"
    return
  fi

  if command -v node >/dev/null 2>&1 && [[ -f "$REPO_ROOT/core/workshop-spec/schema.ts" ]]; then
    info "Validando $path con Zod schema..."
    node -e "
      const yaml = require('js-yaml');
      const fs = require('fs');
      const { workshopSchema } = require('$REPO_ROOT/core/workshop-spec/schema.ts');
      const doc = yaml.load(fs.readFileSync('$path', 'utf8'));
      const r = workshopSchema.safeParse(doc);
      if (!r.success) { console.error(JSON.stringify(r.error.format(), null, 2)); process.exit(1); }
      console.log('OK');
    " 2>&1 || fail "workshop.yaml validation failed"
  else
    warn "node/js-yaml no disponibles; validación skipeada"
  fi
  ok "workshop.yaml presente: $path"
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

  # 4. .env.example
  if [[ -f .env.example ]]; then
    ok ".env.example presente"
    # comparar con vars consumidas
    if [[ -d src ]]; then
      local consumed example diff
      consumed=$(grep -rhoE "process\.env\.[A-Z_][A-Z0-9_]+" src/ 2>/dev/null \
        | sed 's/process\.env\.//' | sort -u)
      example=$(grep -E "^[A-Z_][A-Z0-9_]+=" .env.example 2>/dev/null \
        | cut -d= -f1 | sort -u)
      diff=$(comm -23 <(echo "$consumed") <(echo "$example") 2>/dev/null)
      if [[ -n "$diff" ]]; then
        warn "vars consumidas no documentadas en .env.example:"
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
