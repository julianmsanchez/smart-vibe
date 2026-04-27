# `apps/_team-template/`

> Template que el bootstrap clona N veces (una por team del workshop). Empieza con `_` para que pnpm/turbo no lo trate como un team activo.

## Cómo se usa

Al correr `bash scripts/bootstrap.sh` con `type=workshop` y `teams=3`, el script:

1. Lee este template.
2. Clona a `apps/team-checkout/`, `apps/team-search/`, etc. (según los nombres provistos).
3. Reemplaza `{{TEAM_ID}}`, `{{TEAM_DOMAIN}}`, `{{TEAM_API_PREFIX}}` en cada copia.
4. Genera `apps/<team>/phs.yaml` referenciando `../../workshop.yaml`.

## Qué hereda

Cada team es esencialmente un proyecto `addon: node-ts` standalone:

- `tsconfig.json` extiende `@workshop/config/tsconfig.base.json`.
- `package.json` con scripts `dev`, `build`, `lint`, `test`.
- `src/` con la misma estructura del addon node-ts (services, lib, config, middleware).
- `phs.yaml` con `project.type: workshop` y `workshop.ref: ../../workshop.yaml`.

## Qué consume del monorepo

- `@workshop/design-system` (UI tokens + components).
- `@workshop/types` (tipos compartidos).
- `@workshop/auth` (adapter de auth).
- `@workshop/api-contracts` (contratos HTTP).
- `@workshop/config` (eslint, prettier, tsconfig).
- `@workshop/infra-contracts` (tipos de APIs externas, DB, storage).
- `@workshop/fixtures` (mocks + seeds).

## Por qué `_` al inicio

- Convención visible — humanos saben que es template.
- pnpm-workspace.yaml puede usar `apps/[!_]*` si el orchestrador lo necesita ignorar.
- Turbo lo skippea con un filter explícito.

> **TODO Bloque F-base commit 56:** este README es placeholder. El template real (con `package.json.tmpl`, `tsconfig.json`, `src/` estructura mínima) se completa cuando el bootstrap lo necesite. Ver `~/.claude/plans/parsed-chasing-boole.md`.
