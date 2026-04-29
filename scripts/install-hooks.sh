#!/usr/bin/env bash
# scripts/install-hooks.sh
# Instala los git hooks locales del repo. Idempotente.
#
# Uso:
#   bash scripts/install-hooks.sh

set -uo pipefail

ok()   { echo "✓ $*"; }
fail() { echo "✗ $*" >&2; exit 1; }

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || fail "no se detecta repo git"
HOOKS_DIR="$REPO_ROOT/.git/hooks"
mkdir -p "$HOOKS_DIR"

# commit-msg → check-docs.sh
cat > "$HOOKS_DIR/commit-msg" <<'HOOK'
#!/usr/bin/env bash
# Auto-instalado por scripts/install-hooks.sh
# Aplica la "Regla de documentación viva".
exec bash "$(git rev-parse --show-toplevel)/scripts/check-docs.sh" "$1"
HOOK
chmod +x "$HOOKS_DIR/commit-msg"
ok "instalado .git/hooks/commit-msg → scripts/check-docs.sh"

ok "hooks listos. Para saltar puntualmente: SKIP_DOCS_CHECK=1 git commit ..."
