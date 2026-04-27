---
name: smart-bootstrap
description: Bootstrap interactivo de un nuevo proyecto smart-vibe (single-team o workshop multi-team).
---

# /smart-bootstrap

Inicia un proyecto nuevo desde cero con el Smart Vibe Framework. Hace 4 preguntas y genera todo el scaffolding.

## Qué hace

1. Pregunta:
   - **Nombre del proyecto** (slug, kebab-case).
   - **Tipo** (`single-team` o `workshop`).
   - **Vertical** (general, fintech, salud, retail, edu, gobierno, telecom, otro).
   - **Package manager** (pnpm / npm / yarn).
2. Crea el directorio del proyecto.
3. Copia templates de `core/templates/` (CLAUDE.md, wiki/, policies/).
4. Inicializa el `phs.yaml` con `mode: vibe`.
5. Si es `workshop`: copia `addons/workshop/` y arranca `workshop.yaml` skeleton.
6. Si es `single-team` con stack node-ts: copia `addons/node-ts/`.
7. Inicializa git, primer commit `chore: smart-vibe bootstrap`.

## Cuándo usar

- Empezar un proyecto desde cero.
- Validar el toolkit en un sandbox.

## Cuándo NO usar

- El directorio ya tiene código. Para retrofit usar `/smart-phs` directamente.

## Equivalente fuera del repo (1 prompt en carpeta vacía)

Si todavía no clonaste smart-vibe, podés invocar el mismo flujo desde una sesión Claude Code recién abierta sobre carpeta vacía con curl-pipe-bash:

```bash
curl -fsSL https://raw.githubusercontent.com/julianmsanchez/smart-vibe/main/scripts/install.sh \
  | bash -s -- --type single-team --name <name> --addon node-ts
```

Esto cachea el repo en `~/.smart-vibe/dist/` y forwardea los flags a `bootstrap.sh`. Ver [`docs/QUICKSTART.md`](../../docs/QUICKSTART.md) para los 3 escenarios soportados.

## Implementación

Ejecuta `bash scripts/bootstrap.sh` con los valores capturados como flags:

```bash
bash scripts/bootstrap.sh \
  --name <nombre> \
  --type <single-team|workshop> \
  --vertical <vertical> \
  --pm <pnpm|npm|yarn>
```

Después del bootstrap, sugerí al usuario abrir el `phs.yaml` y completar el campo `decisions[]` con las primeras 5-10 decisiones del proyecto.
