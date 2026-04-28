#!/usr/bin/env bash
# scripts/bootstrap.sh
# Bootstrap interactivo de un proyecto smart-vibe.
#
# Uso:
#   bash scripts/bootstrap.sh                          # interactivo
#   bash scripts/bootstrap.sh --name foo --type single-team --vertical general --pm pnpm
#
# Requiere: bash 4+, git. Opcional: pnpm/npm/yarn (según --pm).

set -euo pipefail

# --- ubicación del repo smart-vibe ---
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- defaults ---
NAME=""
TYPE=""
VERTICAL=""
PM=""
TARGET_DIR=""
ADDON=""
TEAMS=""
SHELL_OWNER=""

# --- parse args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --type) TYPE="$2"; shift 2 ;;
    --vertical) VERTICAL="$2"; shift 2 ;;
    --pm) PM="$2"; shift 2 ;;
    --target) TARGET_DIR="$2"; shift 2 ;;
    --addon) ADDON="$2"; shift 2 ;;
    --teams) TEAMS="$2"; shift 2 ;;
    --shell-owner) SHELL_OWNER="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,11p' "$0"
      exit 0
      ;;
    *) echo "Arg desconocido: $1" >&2; exit 2 ;;
  esac
done

# --- prompts ---
prompt() {
  local var="$1" question="$2" default="${3:-}"
  if [[ -z "${!var}" ]]; then
    if [[ -n "$default" ]]; then
      read -r -p "$question [$default]: " input
      printf -v "$var" '%s' "${input:-$default}"
    else
      read -r -p "$question: " input
      printf -v "$var" '%s' "$input"
    fi
  fi
}

prompt NAME "Nombre del proyecto (kebab-case)"
prompt TYPE "Tipo (single-team / workshop)" "single-team"
prompt VERTICAL "Vertical (general / fintech / salud / retail / edu / gobierno / telecom / otro)" "general"
prompt PM "Package manager (pnpm / npm / yarn)" "pnpm"

# --- validar inputs ---
if [[ ! "$NAME" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
  echo "✗ Nombre inválido. Usá kebab-case (a-z, 0-9, -, _)." >&2
  exit 1
fi

case "$TYPE" in
  single-team|workshop) ;;
  *) echo "✗ TYPE debe ser 'single-team' o 'workshop'." >&2; exit 1 ;;
esac

case "$VERTICAL" in
  general|fintech|salud|retail|edu|gobierno|telecom|otro) ;;
  *) echo "✗ VERTICAL inválido." >&2; exit 1 ;;
esac

case "$PM" in
  pnpm|npm|yarn) ;;
  *) echo "✗ PM debe ser pnpm/npm/yarn." >&2; exit 1 ;;
esac

# --- target dir ---
if [[ -z "$TARGET_DIR" ]]; then
  TARGET_DIR="$(pwd)/$NAME"
fi

if [[ -e "$TARGET_DIR" ]]; then
  echo "✗ El directorio ya existe: $TARGET_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

# --- helper: render template ---
render_tmpl() {
  local src="$1" dst="$2"
  sed \
    -e "s|{{PROJECT_NAME}}|$NAME|g" \
    -e "s|{{MODE}}|vibe|g" \
    -e "s|{{TIER}}|1|g" \
    -e "s|{{VERTICAL}}|$VERTICAL|g" \
    -e "s|{{PACKAGE_MANAGER}}|$PM|g" \
    -e "s|{{SHELL_OWNER}}|${SHELL_OWNER:-@TODO-shell-owner}|g" \
    "$src" > "$dst"
}

# --- copiar templates base ---
echo "→ Copiando templates base..."

render_tmpl "$REPO_ROOT/core/templates/CLAUDE.md.tmpl" "$TARGET_DIR/CLAUDE.md"
cp "$REPO_ROOT/core/gitignore.tmpl" "$TARGET_DIR/.gitignore"
cp -r "$REPO_ROOT/core/wiki-skeleton" "$TARGET_DIR/wiki"
mkdir -p "$TARGET_DIR/docs"
cp -r "$REPO_ROOT/core/policies" "$TARGET_DIR/docs/policies"
mkdir -p "$TARGET_DIR/.claude"
render_tmpl "$REPO_ROOT/core/claude/settings.json.tmpl" "$TARGET_DIR/.claude/settings.json"

# --- PHS skeleton ---
echo "→ Generando phs.yaml..."
cat > "$TARGET_DIR/phs.yaml" <<EOF
# Prototype Handoff Spec — $NAME
# Spec: $REPO_ROOT/core/phs/schema.yaml
schema_version: "1.0"

project:
  name: $NAME
  mode: vibe
  type: $TYPE
  vertical: $VERTICAL
  tier: 1
  created_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

stack: ~        # completar: runtime, framework, db
data: ~
infra: ~
auth: ~
compliance: ~
addons: []
decisions: []
sla: ~
docs: ~
EOF

# --- workshop ---
if [[ "$TYPE" == "workshop" ]]; then
  echo "→ Copiando addon workshop..."
  prompt TEAMS "IDs de teams (separados por coma)" "team-1,team-2"
  prompt SHELL_OWNER "Shell owner (usuario GitHub)" "@TODO"

  cp -r "$REPO_ROOT/addons/workshop/." "$TARGET_DIR/"

  # README.md del addon es interno (audiencia: maintainers de smart-vibe).
  # Lo eliminamos para que el README.md.tmpl renderice el README user-facing.
  rm -f "$TARGET_DIR/README.md"

  # --- handle templates con scope no genérico ---
  # join.sh viaja embebido en el monorepo: lee workshop.yaml en runtime, no
  # tiene placeholders. Sólo lo movemos a su nombre final y le damos permiso
  # de ejecución antes del loop genérico (sino el loop lo procesaría como tmpl).
  if [[ -f "$TARGET_DIR/scripts/join.sh.tmpl" ]]; then
    mv "$TARGET_DIR/scripts/join.sh.tmpl" "$TARGET_DIR/scripts/join.sh"
    chmod +x "$TARGET_DIR/scripts/join.sh"
  fi

  # team-CLAUDE.md.tmpl tiene placeholders por team ({{TEAM_ID}}, etc.) que el
  # render genérico no conoce. Lo stasheamos fuera del proyecto y lo
  # renderizamos al final, una vez que apps/<team>/ exista.
  TEAM_CLAUDE_STASH=""
  if [[ -f "$TARGET_DIR/templates/team-CLAUDE.md.tmpl" ]]; then
    TEAM_CLAUDE_STASH=$(mktemp)
    cp "$TARGET_DIR/templates/team-CLAUDE.md.tmpl" "$TEAM_CLAUDE_STASH"
    rm -rf "$TARGET_DIR/templates"
  fi

  # Renderizar todos los .tmpl del workshop (recorre y aplica sed)
  while IFS= read -r -d '' tmpl; do
    out="${tmpl%.tmpl}"
    render_tmpl "$tmpl" "$out"
    rm "$tmpl"
  done < <(find "$TARGET_DIR" -name '*.tmpl' -print0)

  # Render {{TEAMS_LIST}} en archivos que lo usan (ORGANIZER-CHECKLIST.md).
  # render_tmpl genérico no lo conoce porque es específico al workshop.
  # sed -i.bak para portabilidad BSD/Linux.
  if [[ -f "$TARGET_DIR/ORGANIZER-CHECKLIST.md" ]]; then
    sed -i.bak "s|{{TEAMS_LIST}}|$TEAMS|g" "$TARGET_DIR/ORGANIZER-CHECKLIST.md"
    rm -f "$TARGET_DIR/ORGANIZER-CHECKLIST.md.bak"
  fi

  # Generar workshop.yaml skeleton
  IFS=',' read -ra TEAM_ARR <<< "$TEAMS"
  {
    echo "# workshop.yaml — $NAME"
    echo "# Spec: $REPO_ROOT/core/workshop-spec/schema.yaml"
    echo "schema_version: \"1.0\""
    echo ""
    echo "workshop:"
    echo "  name: $NAME"
    echo "  type: hackathon"
    echo "  mode: vibe"
    echo "  shell:"
    echo "    framework: next.js"
    echo "    mounts_teams_at: \"/{team_id}\""
    echo "    theme_provider_pkg: \"@workshop/design-system/theme\""
    echo ""
    echo "  teams:"
    for t in "${TEAM_ARR[@]}"; do
      echo "    - id: $t"
      echo "      members: []"
      echo "      domain: ~"
      echo "      app_path: apps/$t"
      echo "      api_prefix: \"/api/$t\""
    done
    echo ""
    echo "  shared_infra:"
    echo "    apis_external: []"
    echo "    databases:"
    echo "      strategy: shared-schema-isolated-rows"
    echo "      url_env: DATABASE_URL"
    echo "      migrations_owner: shell"
    echo "      isolation: none"
    echo "    storage: []"
    echo "    secrets:"
    echo "      shared_file: .env.shared.example"
    echo "      strategy: dotenv-local"
    echo "      rotation_owner: shell"
    echo "    observability:"
    echo "      logger: pino"
    echo "      log_format: json"
    echo "      correlation_header: x-correlation-id"
    echo "      destination: stdout"
    echo "      metrics_enabled: false"
    echo ""
    echo "  ui_shared:"
    echo "    design_system_pkg: \"@workshop/design-system\""
    echo "    tokens_path: packages/design-system/tokens"
    echo "    components_path: packages/design-system/components"
    echo "    assets_path: packages/design-system/assets"
    echo ""
    echo "  fixtures:"
    echo "    seeds_path: packages/fixtures/seeds"
    echo "    mocks_strategy: msw"
    echo ""
    echo "  versioning:"
    echo "    strategy: workspace-protocol"
    echo "    breaking_change_policy: \"PR locks until all teams migrate\""
    echo ""
    echo "  ci_cd:"
    echo "    integration_check: enabled"
    echo "    deployment_strategy: independent-per-team"
    echo "    rollback_owner: shell"
  } > "$TARGET_DIR/workshop.yaml"

  # Crear apps/<team>/ desde _team-template
  for t in "${TEAM_ARR[@]}"; do
    cp -r "$TARGET_DIR/apps/_team-template" "$TARGET_DIR/apps/$t"
  done

  # Render apps/<team>/CLAUDE.md desde el stash.
  # En modo vibe los placeholders TEAM_DOMAIN/TEAM_MEMBERS quedan en TODO; el
  # organizer los completa post-bootstrap (decisión cerrada del plan).
  if [[ -n "${TEAM_CLAUDE_STASH:-}" && -f "$TEAM_CLAUDE_STASH" ]]; then
    for t in "${TEAM_ARR[@]}"; do
      sed \
        -e "s|{{TEAM_ID}}|$t|g" \
        -e "s|{{TEAM_DOMAIN}}|TODO-domain|g" \
        -e "s|{{TEAM_MEMBERS}}|TODO-members|g" \
        -e "s|{{WORKSHOP_NAME}}|$NAME|g" \
        -e "s|{{PROJECT_NAME}}|$NAME|g" \
        "$TEAM_CLAUDE_STASH" > "$TARGET_DIR/apps/$t/CLAUDE.md"
    done
    rm -f "$TEAM_CLAUDE_STASH"
  fi
fi

# --- single-team con node-ts ---
if [[ "$TYPE" == "single-team" ]]; then
  echo "→ Copiando addon node-ts..."
  cp -r "$REPO_ROOT/addons/node-ts/." "$TARGET_DIR/"

  # README.md del addon es interno (audiencia: maintainers de smart-vibe).
  # Lo eliminamos para que el heredoc user-facing más abajo lo genere.
  rm -f "$TARGET_DIR/README.md"

  # Renderizar .tmpl
  while IFS= read -r -d '' tmpl; do
    out="${tmpl%.tmpl}"
    render_tmpl "$tmpl" "$out"
    rm "$tmpl"
  done < <(find "$TARGET_DIR" -name '*.tmpl' -print0)
fi

# --- README minimal del proyecto ---
# Si el addon ya generó un README.md (caso workshop con README.md.tmpl), no
# lo sobrescribimos. El heredoc sólo aplica a single-team y a casos sin
# README addon-aware.
if [[ ! -f "$TARGET_DIR/README.md" ]]; then
  cat > "$TARGET_DIR/README.md" <<EOF
# $NAME

> Proyecto generado por [smart-vibe](https://github.com/celeru/smart-vibe). Modo: \`vibe\`. Vertical: \`$VERTICAL\`.

## Quickstart

\`\`\`bash
$PM install
cp .env.example .env
# editar .env con valores reales
$PM dev
\`\`\`

## Estructura

Ver [phs.yaml](./phs.yaml) y [CLAUDE.md](./CLAUDE.md).

## Modo

Estás en modo \`vibe\` — prototipado con guardrails mínimos. Cuando el proyecto madure, correr \`/smart-graduate\` para preparar handoff a celeru-pro.

## Links

- [phs.yaml](./phs.yaml) — Prototype Handoff Spec
- [docs/policies/](./docs/policies/) — 7 policies del framework
- [wiki/](./wiki/) — wiki paralela del proyecto
EOF
fi

# --- git init ---
echo "→ Inicializando git..."
cd "$TARGET_DIR"
git init -q
git add .
git commit -q -m "chore: smart-vibe bootstrap

Generado con scripts/bootstrap.sh:
- type: $TYPE
- vertical: $VERTICAL
- mode: vibe
- pm: $PM"

echo ""
echo "✓ Proyecto creado en: $TARGET_DIR"
echo ""
echo "Próximos pasos:"
echo "  cd $(basename "$TARGET_DIR")"
if [[ "$TYPE" == "workshop" ]]; then
  echo ""
  echo "  → Abrí ORGANIZER-CHECKLIST.md y completá los 4 pasos (~5–10 min)."
  echo "    Cubre: workshop.yaml, .env.shared.example,"
  echo "    apps/<team>/.env.local.example, apps/<team>/CLAUDE.md, gh repo create."
  echo ""
  echo "  Luego:"
  echo "    $PM install"
  echo "    bash scripts/doctor.sh   # verificá que no queden warns"
else
  echo "  $PM install"
  echo "  cp .env.example .env  # editar valores"
  echo "  $PM dev"
fi
echo ""
echo "Cuando tengas el primer feature, completá phs.yaml.decisions[]."
