#!/usr/bin/env bash
# scripts/session-start.sh
# Hook SessionStart de Claude Code. Auto-carga wiki/RESUME.md como contexto
# inicial de la sesión, para que arranques con el estado del proyecto cargado
# sin pedirlo manualmente.
#
# Registro (en .claude/settings.json o core/claude/settings.json.tmpl):
#   "hooks": {
#     "SessionStart": [
#       { "hooks": [{ "type": "command", "command": "bash scripts/session-start.sh" }] }
#     ]
#   }
#
# Stdin: JSON con { session_id, transcript_path, cwd, hook_event_name }
# Stdout: JSON con hookSpecificOutput.additionalContext (lo inyecta al modelo)
#         o vacío si no hay nada que cargar.
#
# Escape hatch: SMART_VIBE_DISABLE_SESSION_HOOK=1.

set -uo pipefail

if [[ "${SMART_VIBE_DISABLE_SESSION_HOOK:-0}" == "1" ]]; then
  exit 0
fi

# Tamaño máximo del contexto inyectado (caracteres). Truncamos a ~12KB para
# evitar gastar el budget del modelo. RESUME.md típico vive bien <5KB.
MAX_CHARS=12000

# --- detectar RESUME.md ---
# Orden de preferencia:
#   1. <cwd>/wiki/RESUME.md         (proyecto single-team o team del workshop)
#   2. <cwd>/RESUME.md              (raíz, fallback)
#   3. <git-root>/wiki/RESUME.md    (cuando cwd está en un subdir profundo)
RESUME_PATH=""
for candidate in \
  "wiki/RESUME.md" \
  "RESUME.md" \
  "$(git rev-parse --show-toplevel 2>/dev/null)/wiki/RESUME.md"
do
  [[ -z "$candidate" ]] && continue
  if [[ -f "$candidate" ]]; then
    RESUME_PATH="$candidate"
    break
  fi
done

if [[ -z "$RESUME_PATH" ]]; then
  # Sin RESUME.md no hay nada que inyectar. Exit silently.
  exit 0
fi

# --- leer y truncar ---
content="$(head -c "$MAX_CHARS" "$RESUME_PATH" 2>/dev/null || true)"
[[ -z "$content" ]] && exit 0

orig_size="$(wc -c < "$RESUME_PATH" | tr -d ' ')"
if [[ "$orig_size" -gt "$MAX_CHARS" ]]; then
  content="${content}

[... truncado, $(($orig_size - $MAX_CHARS)) chars adicionales en $RESUME_PATH ...]"
fi

# --- emitir JSON ---
# Usamos python3 para escapar el contenido como JSON string (más portable que jq).
if command -v python3 >/dev/null 2>&1; then
  python3 - <<PY
import json, sys
ctx = """## Contexto cargado desde $RESUME_PATH

$content"""
print(json.dumps({
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ctx
  }
}))
PY
elif command -v jq >/dev/null 2>&1; then
  jq -n --arg path "$RESUME_PATH" --arg body "$content" '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: ("## Contexto cargado desde " + $path + "\n\n" + $body)
    }
  }'
else
  # Fallback sin escape: si el contenido tiene comillas se rompe el JSON.
  # Imprimimos sólo un mensaje plain (sigue funcional aunque pierde el cuerpo).
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"Existe %s pero no hay python3/jq para inyectarlo. Leelo manualmente."}}\n' "$RESUME_PATH"
fi
