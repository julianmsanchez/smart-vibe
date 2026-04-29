#!/usr/bin/env bash
# scripts/graduate.sh
# Diagnóstico de readiness para handoff a celeru-pro. Read-only sobre el
# proyecto (sólo escribe docs/graduate-handoff.md). Sin umbrales: reporta
# hechos en 3 categorías (crítico / recomendado / inventario).
#
# Uso (desde la raíz del proyecto):
#   bash scripts/graduate.sh
#
# Output:
#   stdout                       — tabla resumen + top findings
#   docs/graduate-handoff.md     — reporte completo (input para celeru-pro)
#
# Exit code: 0 siempre (salvo error de runtime). No es un gate.

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# --- helpers ---
CRITICAL=0
RECOMMENDED=0
declare -a CRITICAL_FINDINGS=()
declare -a RECOMMENDED_FINDINGS=()

add_critical()    { CRITICAL_FINDINGS+=("$1"); CRITICAL=$((CRITICAL+1)); }
add_recommended() { RECOMMENDED_FINDINGS+=("$1"); RECOMMENDED=$((RECOMMENDED+1)); }

# --- pre-checks runtime ---
if [[ ! -f phs.yaml ]]; then
  echo "✗ phs.yaml ausente — no es un proyecto smart-vibe. Abortando." >&2
  exit 2
fi

# --- metadata del proyecto (parse blando con grep; YAML profundo via python3) ---
NAME=$(grep -E "^[[:space:]]+name:" phs.yaml | head -1 | awk '{print $2}')
TYPE=$(grep -E "^[[:space:]]+type:" phs.yaml | head -1 | awk '{print $2}')
VERTICAL=$(grep -E "^[[:space:]]+vertical:" phs.yaml | head -1 | awk '{print $2}')
MODE=$(grep -E "^[[:space:]]+mode:" phs.yaml | head -1 | awk '{print $2}')
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "no-git")

# Versión del toolkit: la inferimos del CLAUDE.md (placeholder ya rendereado).
SV_VERSION=$(grep -oE "smart-vibe v[^ \"\`]*" CLAUDE.md 2>/dev/null | head -1 | sed 's/\.$//' || echo "smart-vibe ?")

# --- 1. critical checks ---

# 1.a .env commiteado (secrets leak)
if [[ -f .env ]] && git ls-files --error-unmatch .env 2>/dev/null >/dev/null; then
  add_critical ".env commiteado al repo (secrets leak). Fix: \`git rm --cached .env && git commit -m 'fix: remove .env from tracking'\`"
fi

# 1.b phs.yaml inválido (parse YAML)
if command -v python3 >/dev/null 2>&1; then
  if ! python3 -c "import yaml; yaml.safe_load(open('phs.yaml'))" >/dev/null 2>&1; then
    add_critical "phs.yaml tiene YAML inválido. Fix: revisar sintaxis con \`python3 -c \"import yaml; yaml.safe_load(open('phs.yaml'))\"\`"
  fi
fi

# 1.c README ausente o muy corto (<50 bytes ≈ vacío)
if [[ ! -f README.md ]]; then
  add_critical "README.md ausente. Fix: ver docs/playbooks/04-no-readme.md"
elif [[ "$(wc -c < README.md | tr -d ' ')" -lt 50 ]]; then
  add_critical "README.md muy corto (<50 bytes). Describí qué es el proyecto."
fi

# 1.d sin tests
TEST_COUNT=$(find . -path ./node_modules -prune -o \( -name '*.test.ts' -o -name '*.test.tsx' -o -name '*.spec.ts' \) -print 2>/dev/null | wc -l | tr -d ' ')
if [[ "$TEST_COUNT" -eq 0 ]]; then
  add_critical "Sin tests automatizados (.test.ts/.spec.ts). Fix: ver docs/playbooks/03-no-tests.md"
fi

# 1.e .gitignore
if [[ ! -f .gitignore ]]; then
  add_critical ".gitignore ausente."
fi

# 1.f workshop: sync-env drift + workshop.yaml válido
if [[ "$TYPE" == "workshop" ]]; then
  if [[ ! -f workshop.yaml ]]; then
    add_critical "type=workshop pero falta workshop.yaml."
  elif [[ -x scripts/sync-env.sh ]]; then
    if ! bash scripts/sync-env.sh --check >/dev/null 2>&1; then
      add_critical "scripts/sync-env.sh --check reporta drift. Fix: \`bash scripts/sync-env.sh\` (regenera env files)."
    fi
  fi
fi

# --- 2. recommended checks ---

# 2.a phs.yaml.stack declarado
if grep -qE "^stack:[[:space:]]*~" phs.yaml; then
  add_recommended "phs.yaml.stack es ~ → declarar runtime/framework/db/test_runner."
fi

# 2.b phs.yaml.decisions[] no vacío
if grep -qE "^decisions:[[:space:]]*\[\]" phs.yaml; then
  add_recommended "phs.yaml.decisions[] vacío → registrar ADRs ya tomadas (ver docs/decisions/)."
fi

# 2.c ADRs en docs/decisions/ no registradas en phs.yaml.decisions[]
ADR_COUNT_ON_DISK=0
ADR_NOT_REGISTERED=""
if [[ -d docs/decisions ]]; then
  while IFS= read -r adr_file; do
    [[ -z "$adr_file" ]] && continue
    base=$(basename "$adr_file" .md)
    [[ "$base" == "_template" ]] && continue
    ADR_COUNT_ON_DISK=$((ADR_COUNT_ON_DISK + 1))
    if command -v python3 >/dev/null 2>&1; then
      if ! python3 -c "
import yaml, sys
d = yaml.safe_load(open('phs.yaml')) or {}
ids = [str(e.get('id', '')) for e in (d.get('decisions') or [])]
sys.exit(0 if '$base' in ids else 1)
" >/dev/null 2>&1; then
        ADR_NOT_REGISTERED="${ADR_NOT_REGISTERED}${base} "
      fi
    fi
  done < <(find docs/decisions -maxdepth 1 -name '*.md' 2>/dev/null)
fi
if [[ -n "$ADR_NOT_REGISTERED" ]]; then
  add_recommended "ADRs en docs/decisions/ NO registradas en phs.yaml.decisions[]: ${ADR_NOT_REGISTERED}"
fi

# 2.d .env.example coverage (mismo check que doctor.sh)
ENV_EXAMPLE=""
if [[ -f .env.example ]]; then ENV_EXAMPLE=".env.example"
elif [[ -f .env.shared.example ]]; then ENV_EXAMPLE=".env.shared.example"
fi
if [[ -n "$ENV_EXAMPLE" && -d src ]]; then
  consumed=$(grep -rhoE "process\.env\.[A-Z_][A-Z0-9_]+" src/ 2>/dev/null | sed 's/process\.env\.//' | sort -u)
  example=$(grep -E "^[A-Z_][A-Z0-9_]+=" "$ENV_EXAMPLE" 2>/dev/null | cut -d= -f1 | sort -u)
  diff=$(comm -23 <(echo "$consumed") <(echo "$example") 2>/dev/null)
  if [[ -n "$diff" ]]; then
    UNDOCUMENTED=$(echo "$diff" | grep -c .)
    add_recommended "$ENV_EXAMPLE no cubre $UNDOCUMENTED var(s) consumida(s) en src/. Fix: \`bash scripts/doctor.sh\`"
  fi
fi

# 2.e PRD con _TODO_ pendientes
if [[ -f wiki/PRD.md ]]; then
  TODO_COUNT=$(grep "_TODO_" wiki/PRD.md 2>/dev/null | wc -l | tr -d ' ')
  if [[ "${TODO_COUNT:-0}" -gt 0 ]]; then
    add_recommended "wiki/PRD.md tiene $TODO_COUNT placeholder(s) _TODO_ → completá personas/KPIs/módulos."
  fi
fi

# 2.f CI configurado
if [[ ! -d .github/workflows ]] || [[ -z "$(find .github/workflows -name '*.yml' -o -name '*.yaml' 2>/dev/null | head -1)" ]]; then
  add_recommended "Sin CI (.github/workflows/ vacío o ausente) → agregar pipeline mínimo de tests."
fi

# 2.g workshop: doctor warns
if [[ "$TYPE" == "workshop" && -x scripts/doctor.sh ]]; then
  DOCTOR_WARNS=$(bash scripts/doctor.sh 2>&1 | grep "^⚠" | wc -l | tr -d ' ')
  if [[ "${DOCTOR_WARNS:-0}" -gt 0 ]]; then
    add_recommended "scripts/doctor.sh reporta $DOCTOR_WARNS warn(s). Fix: \`bash scripts/doctor.sh\` y resolver."
  fi
fi

# --- 3. inventario ---

# LOC en src/ (suma de líneas .ts/.tsx/.js/.jsx)
SRC_LOC=0
if [[ -d src ]]; then
  SRC_LOC=$(find src -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \) -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')
fi

# Session summaries (excluye _template.md). find ! -name evita el grep
# downstream que dispara `|| echo 0` falso por exit code 1 de grep sin matches.
SS_COUNT=$(find wiki/docs/session_summaries -maxdepth 1 -name "*.md" ! -name "_template.md" 2>/dev/null | wc -l | tr -d ' ')

# Módulos en PRD (sección 3 lista con `### \`<nombre>\``).
# grep -c con 0 matches retorna exit 1; usar pipe a wc -l para single value.
MODULE_COUNT=0
if [[ -f wiki/PRD.md ]]; then
  MODULE_COUNT=$(grep -E "^### \`" wiki/PRD.md 2>/dev/null | wc -l | tr -d ' ')
fi

# Edad del proyecto (días desde primer commit)
AGE_DAYS=0
FIRST_COMMIT=$(git log --reverse --format=%aI 2>/dev/null | head -1)
if [[ -n "$FIRST_COMMIT" && -x "$(command -v python3)" ]]; then
  AGE_DAYS=$(python3 -c "
from datetime import datetime, timezone
try:
    d = datetime.fromisoformat('$FIRST_COMMIT'.replace('Z', '+00:00'))
    print((datetime.now(timezone.utc) - d).days)
except Exception:
    print(0)
" 2>/dev/null || echo 0)
fi

# Workshop counts
TEAM_COUNT=0
APIS_COUNT=0
if [[ -f workshop.yaml && -x "$(command -v python3)" ]]; then
  TEAM_COUNT=$(python3 -c "
import yaml
d = yaml.safe_load(open('workshop.yaml')) or {}
print(len(d.get('workshop', {}).get('teams', []) or []))
" 2>/dev/null || echo 0)
  APIS_COUNT=$(python3 -c "
import yaml
d = yaml.safe_load(open('workshop.yaml')) or {}
print(len(d.get('workshop', {}).get('shared_infra', {}).get('apis_external', []) or []))
" 2>/dev/null || echo 0)
fi

# --- emit handoff doc ---
mkdir -p docs
HANDOFF=docs/graduate-handoff.md
{
  echo "# Graduate handoff — $NAME"
  echo ""
  echo "> Generado por $SV_VERSION el $(date +%Y-%m-%d)."
  echo "> Commit: $COMMIT_HASH · Modo actual: $MODE · Type: $TYPE · Vertical: $VERTICAL"
  echo ""
  echo "Diagnóstico read-only producido por \`/smart-graduate\`. Input para auditoría"
  echo "formal en celeru-pro (modo graduating). No representa un pass/fail —"
  echo "es un espejo de readiness."
  echo ""
  echo "---"
  echo ""
  echo "## Inventario"
  echo ""
  echo "| Métrica | Valor |"
  echo "|---|---|"
  echo "| LOC en \`src/\` | $SRC_LOC |"
  echo "| Archivos de test | $TEST_COUNT |"
  echo "| ADRs en \`docs/decisions/\` | $ADR_COUNT_ON_DISK |"
  echo "| Session summaries | $SS_COUNT |"
  echo "| Módulos en PRD | $MODULE_COUNT |"
  echo "| Edad (días desde primer commit) | $AGE_DAYS |"
  if [[ "$TYPE" == "workshop" ]]; then
    echo "| Teams | $TEAM_COUNT |"
    echo "| APIs externas declaradas | $APIS_COUNT |"
  fi
  echo ""
  echo "## Findings críticos ($CRITICAL)"
  echo ""
  echo "Bloquean cualquier auditoría formal. Resolver antes de invocar a celeru-pro."
  echo ""
  if [[ $CRITICAL -eq 0 ]]; then
    echo "Cero blockers. ✓"
  else
    for f in "${CRITICAL_FINDINGS[@]}"; do
      echo "- $f"
    done
  fi
  echo ""
  echo "## Findings recomendados ($RECOMMENDED)"
  echo ""
  echo "No bloquean, pero fortalecen la auditoría. Cuanto más cerrado, mejor el handoff."
  echo ""
  if [[ $RECOMMENDED -eq 0 ]]; then
    echo "Cero recomendaciones pendientes. ✓"
  else
    for f in "${RECOMMENDED_FINDINGS[@]}"; do
      echo "- $f"
    done
  fi
  echo ""
  echo "## Open questions para celeru-pro"
  echo ""
  echo "> Plantilla. Llená estas preguntas antes de invocar al auditor."
  echo ""
  echo "- **Tier real:** ¿startup o corporate? ¿Por qué (justificá)?"
  echo "- **Vertical context:** ¿hay regulaciones específicas (HIPAA, PCI-DSS, GDPR, SOC2, etc.)?"
  echo "- **Integraciones obligatorias:** ¿qué APIs externas debe contemplar el audit?"
  echo "- **Deadlines:** ¿hay fecha duro de release?"
  echo "- **Presupuesto:** ¿constraints de costo de infra/staffing?"
  echo "- **Equipo:** ¿quiénes mantendrán esto post-graduating?"
  echo "- **Riesgos conocidos:** ¿deudas técnicas que el equipo ya identificó?"
  echo ""
  echo "## Próximos pasos"
  echo ""
  echo "1. Revisar findings críticos arriba. Cero blockers = listo para audit técnica."
  echo "2. Llenar \"Open questions\" con el contexto real del proyecto."
  echo "3. Editar \`phs.yaml.mode\` de \`vibe\` a \`graduating\` (decisión humana)."
  echo "4. Instalar celeru-pro (privado, requiere licencia)."
  echo "5. Correr \`celeru-pro audit\` con este doc como input."
  echo ""
  echo "---"
  echo ""
  echo "> Re-correr \`/smart-graduate\` para refrescar este doc cuando cambien los findings."
} > "$HANDOFF"

# --- stdout summary ---
echo "=== /smart-graduate — diagnóstico de readiness ==="
echo ""
echo "Proyecto: $NAME ($MODE, $TYPE, $VERTICAL)"
echo "Edad:     $AGE_DAYS días · $SV_VERSION · commit $COMMIT_HASH"
echo ""
if [[ $CRITICAL -eq 0 ]]; then
  echo "Crítico:     0  ✓"
else
  echo "Crítico:     $CRITICAL"
fi
echo "Recomendado: $RECOMMENDED"
echo "Inventario:  ver $HANDOFF"
echo ""

if [[ $CRITICAL -gt 0 ]]; then
  echo "Críticos pendientes:"
  for f in "${CRITICAL_FINDINGS[@]}"; do
    echo "  ✗ $f"
  done
  echo ""
fi

if [[ $RECOMMENDED -gt 0 ]]; then
  echo "Recomendados (top 5):"
  TOP=0
  for f in "${RECOMMENDED_FINDINGS[@]}"; do
    [[ $TOP -ge 5 ]] && break
    echo "  ⚠ $f"
    TOP=$((TOP + 1))
  done
  if [[ $RECOMMENDED -gt 5 ]]; then
    echo "  ... y $((RECOMMENDED - 5)) más en $HANDOFF"
  fi
  echo ""
fi

echo "Handoff escrito en: $HANDOFF"

exit 0
