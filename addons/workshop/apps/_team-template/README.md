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

## Estructura mínima (v0.2.2)

```
_team-template/
├── package.json.tmpl        # name @workshop/{{TEAM_ID}}, deps a @workshop/*
├── tsconfig.json            # extends @workshop/config/tsconfig
├── .eslintrc.cjs            # extends @workshop/config/eslint-base
├── .env.local.example       # vars team-specific (synceadas desde workshop.yaml)
├── README.md                # este archivo
└── src/
    ├── index.ts.tmpl        # Express en /api/{{TEAM_ID}}, puerto {{TEAM_PORT}}
    └── routes/
        └── health.ts        # GET /api/{{TEAM_ID}}/health
```

`bootstrap.sh` copia este árbol a `apps/<team>/`, renderiza los `.tmpl` con
`{{TEAM_ID}}` y `{{TEAM_PORT}}` (3001+ secuencial), y borra `_team-template/`
implícitamente porque ya no se referencia (`pnpm-workspace.yaml` filtra `apps/*`
sin el guion bajo, y `apps/_team-template/` queda como referencia para
`/smart-workshop add-team`).

> Si el workshop crece (más routes, fixtures propios, schemas Zod del team),
> el equipo extiende a partir de este skeleton sin tocar `_team-template/`.
