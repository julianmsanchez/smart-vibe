#!/usr/bin/env bash
# scripts/check-docs.sh
# Enforcer de la "Regla de documentación viva" (CLAUDE.md).
# Falla si un commit feat/fix toca archivos user-facing pero no actualiza CHANGELOG.md.
#
# Uso:
#   bash scripts/check-docs.sh <commit-msg-file>          # modo commit-msg hook
#   bash scripts/check-docs.sh --pr <base-ref>            # modo PR (compara diff)
#
# Escape hatch: SKIP_DOCS_CHECK=1 omite el chequeo.

set -uo pipefail

ok()   { echo "✓ check-docs: $*"; }
warn() { echo "⚠ check-docs: $*" >&2; }
fail() { echo "✗ check-docs: $*" >&2; exit 1; }

if [[ "${SKIP_DOCS_CHECK:-0}" == "1" ]]; then
  ok "SKIP_DOCS_CHECK=1, skipping"
  exit 0
fi

# Patrón de paths user-facing. Cambios acá impactan al builder externo.
USER_FACING_RE='^(scripts/|addons/|plugin/|core/(phs|workshop-spec|policies|templates)/|docs/framework/)'

# Extrae el tipo conventional-commit del primer header no vacío del mensaje.
extract_type() {
  local msg_file="$1"
  grep -m1 -vE '^\s*(#|$)' "$msg_file" 2>/dev/null \
    | grep -oE '^[a-z]+(\([^)]+\))?!?:' \
    | grep -oE '^[a-z]+' \
    | head -n1
}

# Modo commit-msg hook.
mode_commit_msg() {
  local msg_file="$1"
  [[ -f "$msg_file" ]] || fail "no existe el archivo de mensaje: $msg_file"

  local type
  type="$(extract_type "$msg_file")"

  # Solo aplica a feat/fix. Otros tipos (chore/docs/refactor/test/ci) pasan.
  if [[ "$type" != "feat" && "$type" != "fix" ]]; then
    exit 0
  fi

  local staged user_facing changelog
  staged="$(git diff --cached --name-only --diff-filter=ACMR)"
  user_facing="$(echo "$staged" | grep -E "$USER_FACING_RE" || true)"
  changelog="$(echo "$staged" | grep -E '^CHANGELOG\.md$' || true)"

  if [[ -z "$user_facing" ]]; then
    exit 0
  fi

  if [[ -z "$changelog" ]]; then
    warn "commit '$type' toca archivos user-facing pero no actualiza CHANGELOG.md."
    warn "archivos user-facing staged:"
    echo "$user_facing" | sed 's/^/    /' >&2
    warn ""
    warn "agregá una entrada en [Unreleased] del CHANGELOG.md y stage el archivo,"
    warn "o exportá SKIP_DOCS_CHECK=1 si el cambio realmente no es user-facing."
    exit 1
  fi

  ok "feat/fix con CHANGELOG.md actualizado"
}

# Modo PR: compara HEAD contra base ref.
mode_pr() {
  local base="$1"
  local diff_files user_facing changelog
  diff_files="$(git diff --name-only "${base}...HEAD")"
  user_facing="$(echo "$diff_files" | grep -E "$USER_FACING_RE" || true)"
  changelog="$(echo "$diff_files" | grep -E '^CHANGELOG\.md$' || true)"

  if [[ -z "$user_facing" ]]; then
    ok "no hay cambios user-facing en este PR"
    exit 0
  fi

  if [[ -z "$changelog" ]]; then
    warn "PR toca archivos user-facing sin actualizar CHANGELOG.md."
    warn "archivos user-facing en el diff:"
    echo "$user_facing" | sed 's/^/    /' >&2
    exit 1
  fi

  ok "PR con CHANGELOG.md actualizado"
}

# --- entrypoint ---
case "${1:-}" in
  --pr)
    [[ -n "${2:-}" ]] || fail "uso: $0 --pr <base-ref>"
    mode_pr "$2"
    ;;
  "")
    fail "uso: $0 <commit-msg-file>  |  $0 --pr <base-ref>"
    ;;
  *)
    mode_commit_msg "$1"
    ;;
esac
