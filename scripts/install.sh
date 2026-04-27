#!/usr/bin/env bash
# scripts/install.sh
# Wrapper curl-pipe-bash para arrancar un proyecto smart-vibe sin clonar
# manualmente. Mantiene una cache durable en ~/.smart-vibe/dist/ y forwardea
# todos los args a scripts/bootstrap.sh.
#
# Uso típico (desde una sesión Claude Code o terminal, en carpeta vacía):
#
#   curl -fsSL https://raw.githubusercontent.com/julianmsanchez/smart-vibe/main/scripts/install.sh \
#     | bash -s -- --type single-team --name mi-app --addon node-ts
#
#   curl -fsSL https://raw.githubusercontent.com/julianmsanchez/smart-vibe/main/scripts/install.sh \
#     | bash -s -- --type workshop --name hackathon-ai-2026 --teams "checkout,search,recs"
#
# Flags propios de install.sh:
#   --ref <git-ref>   Tag/branch/commit a usar (default: main).
#   --help            Imprime ayuda y la de bootstrap.sh.
#
# Cualquier otro flag se forwardea sin cambios a scripts/bootstrap.sh.
# Idempotente: en re-ejecuciones hace `git fetch && git checkout <ref>` en la
# cache, no re-clona.

set -euo pipefail

REPO_URL="${SMART_VIBE_REPO_URL:-https://github.com/julianmsanchez/smart-vibe.git}"
CACHE_DIR="${SMART_VIBE_CACHE_DIR:-$HOME/.smart-vibe/dist}"
REF="main"

# --- helpers ---
err()  { echo "✗ $*" >&2; }
info() { echo "→ $*"; }
ok()   { echo "✓ $*"; }

require_cmd() {
  local cmd="$1" hint="${2:-}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    err "Falta dependencia: $cmd"
    [[ -n "$hint" ]] && echo "  $hint" >&2
    return 1
  fi
}

print_help() {
  sed -n '2,28p' "$0"
  echo ""
  echo "--- bootstrap.sh args ---"
  if [[ -f "$CACHE_DIR/scripts/bootstrap.sh" ]]; then
    sed -n '2,11p' "$CACHE_DIR/scripts/bootstrap.sh"
  else
    echo "(cache aún no inicializada; se clonará en $CACHE_DIR al primer uso)"
  fi
}

# --- separar --ref / --help propios del resto ---
FORWARD_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) REF="$2"; shift 2 ;;
    -h|--help) print_help; exit 0 ;;
    *) FORWARD_ARGS+=("$1"); shift ;;
  esac
done

# --- check deps mínimas ---
MISSING=0
require_cmd git "Instalar: https://git-scm.com/downloads" || MISSING=1
require_cmd bash "" || MISSING=1
require_cmd node "Instalar Node >=18: https://nodejs.org/" || MISSING=1
require_cmd corepack "Viene con Node >=16.10. 'corepack enable' si está deshabilitado." || MISSING=1
[[ $MISSING -eq 0 ]] || { err "Faltan dependencias. Abortando."; exit 1; }

# bash 4+ es necesario para los arrays asociativos / read -ra de bootstrap.sh
BASH_MAJOR="${BASH_VERSINFO[0]:-0}"
if [[ "$BASH_MAJOR" -lt 4 ]]; then
  err "bash >=4 requerido (detectado: $BASH_VERSION)."
  echo "  En macOS: 'brew install bash' y re-ejecutar con el bash nuevo." >&2
  exit 1
fi

# --- clone / update cache ---
mkdir -p "$(dirname "$CACHE_DIR")"

if [[ ! -d "$CACHE_DIR/.git" ]]; then
  info "Clonando smart-vibe a $CACHE_DIR..."
  git clone --quiet "$REPO_URL" "$CACHE_DIR"
else
  info "Actualizando cache en $CACHE_DIR..."
  git -C "$CACHE_DIR" fetch --quiet --tags origin
fi

info "Checkout ref: $REF"
git -C "$CACHE_DIR" checkout --quiet "$REF"
# Si el ref es una rama, traer últimas commits. En tags falla con un mensaje
# que no nos importa: lo silenciamos y seguimos.
git -C "$CACHE_DIR" pull --quiet --ff-only origin "$REF" 2>/dev/null || true

ok "Cache lista en $CACHE_DIR ($(git -C "$CACHE_DIR" rev-parse --short HEAD))"

# --- forward a bootstrap.sh ---
BOOTSTRAP="$CACHE_DIR/scripts/bootstrap.sh"
if [[ ! -x "$BOOTSTRAP" ]]; then
  if [[ -f "$BOOTSTRAP" ]]; then
    chmod +x "$BOOTSTRAP"
  else
    err "bootstrap.sh no encontrado en $BOOTSTRAP"
    exit 1
  fi
fi

info "Ejecutando bootstrap.sh ${FORWARD_ARGS[*]:-(modo interactivo)}"
exec bash "$BOOTSTRAP" "${FORWARD_ARGS[@]}"
