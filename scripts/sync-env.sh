#!/usr/bin/env bash
# scripts/sync-env.sh
# Regenera los archivos .env.*.example del workshop a partir de
# `workshop.yaml.shared_infra`. Sólo toca el bloque entre los markers
# `# --- BEGIN AUTO-GENERATED FROM workshop.yaml ---` y
# `# --- END AUTO-GENERATED FROM workshop.yaml ---`. Todo lo de afuera
# (NODE_ENV, comentarios manuales, secciones custom) queda intacto.
#
# Uso desde la raíz del workshop:
#   bash scripts/sync-env.sh           # sincroniza shared + todos los teams
#   bash scripts/sync-env.sh --check   # exit=1 si hay diff (modo CI)
#
# Mapeo:
#   - .env.shared.example: databases.url_env + apis_external[] sin access.
#   - apps/<team>/.env.local.example: apis_external[] con access incluyendo <team>.
#
# Idempotente: correrlo dos veces produce el mismo output.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

CHECK_MODE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --check) CHECK_MODE=1; shift ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "Arg desconocido: $1" >&2; exit 2 ;;
  esac
done

err()  { echo "✗ $*" >&2; }
info() { echo "→ $*"; }
ok()   { echo "✓ $*"; }

# --- pre-checks ---
if ! command -v python3 >/dev/null 2>&1; then
  err "Falta python3 (lo usamos para parsear workshop.yaml)."
  exit 1
fi
if ! python3 -c "import yaml" 2>/dev/null; then
  err "Falta PyYAML. Instalar con: pip3 install --user pyyaml"
  exit 1
fi
if [[ ! -f workshop.yaml ]]; then
  err "workshop.yaml no encontrado en $PROJECT_ROOT. ¿Estás en la raíz del workshop?"
  exit 1
fi

# --- delegar todo a python (parse YAML + reescritura idempotente) ---
# El script python:
#   1. Lee workshop.yaml.
#   2. Calcula vars globales y por team.
#   3. Para cada archivo target, reemplaza el bloque entre markers.
#   4. Si --check, sólo retorna 1 si hay diff (no modifica).
python3 - "$CHECK_MODE" <<'PY'
import os
import sys
import yaml

CHECK = sys.argv[1] == "1"
BEGIN = "# --- BEGIN AUTO-GENERATED FROM workshop.yaml ---"
END = "# --- END AUTO-GENERATED FROM workshop.yaml ---"


def fail(msg):
    print(f"✗ {msg}", file=sys.stderr)
    sys.exit(1)


def info(msg):
    print(f"→ {msg}")


def ok(msg):
    print(f"✓ {msg}")


with open("workshop.yaml") as f:
    d = yaml.safe_load(f)

ws = d.get("workshop", {})
shared = ws.get("shared_infra", {}) or {}
apis = shared.get("apis_external") or []
db_url_env = (shared.get("databases") or {}).get("url_env")
teams = [t["id"] for t in (ws.get("teams") or []) if t.get("id")]

# Globales: databases.url_env + apis sin access.
globals_set = set()
if db_url_env:
    globals_set.add(db_url_env)
for a in apis:
    if a.get("env_var") and not a.get("access"):
        globals_set.add(a["env_var"])

# Team-specific: apis con access incluyendo el team-id.
team_vars = {}
for t in teams:
    team_vars[t] = sorted({
        a["env_var"]
        for a in apis
        if a.get("env_var") and t in (a.get("access") or [])
    })

globals_list = sorted(globals_set)


def render_block(vars_list, source_hint):
    """Genera el contenido entre markers. Cada var como `KEY=`."""
    lines = [BEGIN]
    lines.append("# NO editar a mano: regenerar con `bash scripts/sync-env.sh`.")
    lines.append(f"# Origen: {source_hint}")
    if vars_list:
        for v in vars_list:
            lines.append(f"{v}=")
    else:
        lines.append("# (sin vars declaradas en workshop.yaml para este scope)")
    lines.append(END)
    return "\n".join(lines) + "\n"


def replace_block(path, new_block):
    """Reemplaza bloque entre markers. Si no existen, los appendea.

    Retorna (changed: bool, new_content: str). No escribe en disco.
    """
    if not os.path.exists(path):
        # archivo nuevo: comentario header + block
        new_content = (
            "# Generado automáticamente por scripts/sync-env.sh.\n"
            "# Editá los comentarios/headers libremente; el bloque AUTO-GENERATED\n"
            "# se regenera desde workshop.yaml.\n\n"
            + new_block
        )
        return True, new_content

    with open(path) as f:
        content = f.read()

    if BEGIN in content and END in content:
        before, _, rest = content.partition(BEGIN)
        _, _, after = rest.partition(END)
        # Limpieza: si after empieza con \n, lo conservamos sólo una vez para
        # evitar líneas en blanco múltiples al re-runs.
        after = after.lstrip("\n")
        new_content = before + new_block + ("\n" + after if after else "")
    else:
        # Markers ausentes: appendear con separación.
        sep = "" if content.endswith("\n\n") else ("\n" if content.endswith("\n") else "\n\n")
        new_content = content + sep + new_block

    return new_content != content, new_content


targets = []

# .env.shared.example
shared_block = render_block(
    globals_list,
    "workshop.yaml.shared_infra.databases.url_env + apis_external[] sin access.",
)
targets.append((".env.shared.example", shared_block, len(globals_list)))

# apps/<team>/.env.local.example
for t in teams:
    block = render_block(
        team_vars[t],
        f"workshop.yaml.shared_infra.apis_external[] con access incluyendo \"{t}\".",
    )
    targets.append((f"apps/{t}/.env.local.example", block, len(team_vars[t])))

any_diff = False
for path, block, count in targets:
    changed, new_content = replace_block(path, block)
    if changed:
        any_diff = True
        if CHECK:
            print(f"⚠ {path} desincronizado con workshop.yaml ({count} var(s) declaradas).", file=sys.stderr)
        else:
            with open(path, "w") as f:
                f.write(new_content)
            ok(f"sync {path} ({count} var(s) declarada(s))")
    else:
        if not CHECK:
            ok(f"sin cambios {path} ({count} var(s))")

if CHECK and any_diff:
    print("Correr `bash scripts/sync-env.sh` para sincronizar.", file=sys.stderr)
    sys.exit(1)

if not CHECK:
    print("")
    print("✓ Sync completo. Recordá:")
    print("  - .env.shared y apps/<team>/.env.local NO se tocan (gitignored).")
    print("  - Para que devs traigan los nuevos values: re-correr `bash scripts/join.sh --as <team>`.")
PY
