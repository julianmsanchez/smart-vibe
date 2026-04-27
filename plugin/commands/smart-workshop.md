---
name: smart-workshop
description: Subcomandos para el addon workshop (Turborepo multi-team). init, status, integration-check.
---

# /smart-workshop

Comandos específicos del addon `workshop`. Sólo aplican si el proyecto es de tipo `workshop` (declarado en `phs.yaml.type` y/o existe `workshop.yaml`).

## Subcomandos

### `/smart-workshop init`

Bootstrap del addon workshop dentro de un proyecto smart-vibe existente.

Hace:
1. Pregunta cuántos teams (default 2).
2. Pregunta IDs de los teams.
3. Pregunta nombre del shell owner (para CODEOWNERS).
4. Copia `addons/workshop/` aplicando templates con esos valores.
5. Crea `workshop.yaml` skeleton con los teams declarados.
6. Crea `apps/<team>/` para cada team con README placeholder.
7. Sugiere correr `pnpm install` y `pnpm turbo dev`.

### `/smart-workshop status`

Reporta estado del workshop:
- Teams declarados vs `apps/` reales (detecta mismatches).
- Completitud del manifest (`workshop.yaml`).
- Packages compartidos en uso (consumidores por team).
- Conflictos pendientes (PRs abiertos que tocan packages compartidos).

### `/smart-workshop integration-check`

Corre checks cross-team:
- Validación schema `workshop.yaml`.
- `pnpm -r typecheck` (rompe si un team consume schema obsoleto de otro).
- Build del shell con todos los teams.
- Filter de extracción (chequeo de leftovers en archivos del workshop).

Es el mismo check que corre `addons/workshop/.github/workflows/integration-check.yml.tmpl` en CI.

### `/smart-workshop validate`

Sólo valida `workshop.yaml` (más liviano que `integration-check`). Llama a `bash scripts/doctor.sh workshop validate <path>`.

### `/smart-workshop add-team <id>`

Agrega un team nuevo:
1. Edita `workshop.yaml.teams[]`.
2. Crea `apps/<id>/` desde `apps/_team-template/`.
3. Edita `CODEOWNERS` agregando dueño del team (pregunta).
4. Recuerda al usuario instalar deps y declarar el `api_prefix`.

## Cuándo usar

- `init` → al adoptar el addon workshop.
- `status` → para ver de un pantallazo cómo está el monorepo.
- `integration-check` → antes de mergear cambios que tocan algo compartido.
- `validate` → en CI o como pre-commit.
- `add-team` → al sumar un team nuevo (hackathon día 2, corporate-squad nuevo, etc.).

## Onboarding de un dev nuevo (NO usa este plugin)

Para que un dev se una a un workshop ya bootstrapeado se usa `bash scripts/join.sh --as <team-id>` desde la raíz del clone — **no** un subcomando del plugin. El `join.sh` viaja embebido en el repo del workshop (lo copia el bootstrap del organizer desde `addons/workshop/scripts/join.sh.tmpl`), así dev y organizer comparten exactamente la misma versión.

Este plugin sólo se usa **post-join**, principalmente para `/smart-workshop status` e `/smart-workshop integration-check`. Detalle del flujo en [`docs/QUICKSTART.md`](../../docs/QUICKSTART.md), escenario C.

## Implementación

- `init` → invoca `bash scripts/bootstrap.sh --addon workshop`.
- `status` / `validate` / `integration-check` → invocan `bash scripts/doctor.sh workshop <subcomando>`.
- `add-team` → script interactivo que edita YAML preservando comentarios.
