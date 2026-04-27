# 10 · Workshop Mode (multi-team con Turborepo)

> El **workshop mode** es uno de los dos `type` de proyecto (el otro es `single-team`). Está diseñado para **hackathons, squads paralelos o equipos multi-product** que comparten infra, UI y políticas pero construyen apps independientes.

> Implementado en el addon `addons/workshop/` con Turborepo + pnpm workspaces. Activado en el bootstrap eligiendo `type: workshop`.

---

## Cuándo usar workshop mode

**Sí, cuando…**
- Hay 2+ equipos trabajando en el mismo evento o squad.
- Comparten **al menos una de**: design system, auth, API contracts, observability, deployment pipeline.
- Se beneficia de un *shell* común que monta a cada team en una sub-ruta.
- Querés estandarizar `tooling` (eslint, tsconfig, prettier) cross-team.

**No, cuando…**
- Hay un solo equipo, una sola app → usá `single-team`.
- Los equipos no comparten nada → repos separados.
- El proyecto es comercial multi-tenant (es otro patrón, no workshop).

---

## Estructura del monorepo generado

```
hackathon-2026/
├── workshop.yaml                  # SSOT cross-cutting (teams, infra, UI, secrets, ...)
├── package.json                   # raíz con scripts pnpm/turbo
├── pnpm-workspace.yaml
├── turbo.json
├── .env.shared.example
├── CODEOWNERS                     # asigna ownership por team
├── .github/
│   └── workflows/
│       ├── ci.yml                 # CI base
│       └── integration-check.yml  # cross-team integration check
│
├── apps/
│   ├── shell/                    # Next.js. Monta /{team_id} y consume design-system
│   │   └── phs.yaml
│   ├── team-1/                   # cada team es un addon node-ts
│   │   └── phs.yaml
│   ├── team-2/
│   │   └── phs.yaml
│   └── team-3/
│       └── phs.yaml
│
├── packages/
│   ├── design-system/            # tokens, components, assets, theme
│   ├── types/                    # tipos compartidos
│   ├── auth/                     # adapter de auth
│   ├── api-contracts/            # contratos HTTP entre teams
│   ├── config/                   # eslint/prettier/tsconfig compartidos
│   ├── infra-contracts/          # tipos derivados de workshop.yaml (APIs externas, DB, storage)
│   └── fixtures/                 # seeds + msw-handlers
│
└── docs/
    └── workshop/
        ├── secrets-strategy.md
        ├── data-strategy.md
        ├── ui-shared.md
        ├── observability.md
        ├── versioning.md
        ├── local-dev.md
        ├── deployment.md
        └── team-communication.md
```

---

## Las dos capas del addon workshop

### Capa 1 — `workshop.yaml` (SSOT declarativo)

Hermano del PHS, pero a nivel **monorepo**. Lo lee:
- humanos (onboarding hackathon),
- agentes (`/smart-workshop status`, `/smart-workshop integration-check`),
- `scripts/doctor.sh workshop validate`,
- `celeru-pro` al graduar.

**Schema (resumen):**

```yaml
workshop:
  name: hackathon-2026
  type: hackathon          # hackathon | corporate-squads | multi-product
  mode: vibe               # vibe | graduating | production
  shell:
    framework: next.js
    mounts_teams_at: "/{team_id}"
    theme_provider_pkg: "@workshop/design-system/theme"

  teams:
    - id: team-1
      members: ["alice", "bob"]
      domain: "checkout"
      app_path: apps/team-1
      api_prefix: "/api/team-1"

  shared_infra:
    apis_external:
      - name: openai
        env_var: OPENAI_API_KEY
        access: ["team-1", "team-2"]
        budget_usd_monthly: 50
    databases:
      strategy: "shared-schema-isolated-rows"   # | schema-per-team | db-per-team
      url_env: DATABASE_URL
      migrations_owner: shell
      isolation: row-level-security             # | none
    storage:
      - bucket: workshop-uploads
        provider: s3
        access: ["team-1"]
    secrets:
      shared_file: .env.shared.example
      strategy: "dotenv-local"                  # | aws-secrets-manager | vault
      rotation_owner: shell
    observability:
      logger: pino
      log_format: json
      correlation_header: x-correlation-id
      destination: stdout                       # | cloudwatch | datadog
      metrics_enabled: false                    # true en graduating

  ui_shared:
    design_system_pkg: "@workshop/design-system"
    tokens_path: packages/design-system/tokens
    components_path: packages/design-system/components
    assets_path: packages/design-system/assets

  fixtures:
    seeds_path: packages/fixtures/seeds
    mocks_strategy: msw                          # | none

  versioning:
    strategy: workspace-protocol                 # workspace:* en package.json
    breaking_change_policy: "PR locks until all teams migrate"

  ci_cd:
    integration_check: enabled
    deployment_strategy: "independent-per-team"
    rollback_owner: shell
```

Schema canónico en `core/workshop-spec/schema.yaml` (Zod en `schema.ts`).

### Capa 2 — Packages cross-cutting

Implementan lo declarado en `workshop.yaml`:

| Package | Rol | Qué expone |
|---|---|---|
| `design-system` | UI compartida | tokens (JSON), components (Button, Input...), assets, ThemeProvider |
| `types` | Tipos compartidos | TS types/interfaces que cruzan teams |
| `auth` | Adapter de auth | login/logout/session, abstract sobre el provider real |
| `api-contracts` | Contratos HTTP entre teams | OpenAPI / Zod schemas de endpoints inter-team |
| `config` | Tooling compartido | `eslint-base.cjs`, `eslint-react.cjs`, `prettier.config.cjs`, `tsconfig.base.json` |
| `infra-contracts` | Tipos de infra declarada | tipos derivados de `workshop.yaml` para `apis_external`, `databases`, `storage` |
| `fixtures` | Mocks + seeds | seed data + msw handlers para dev local |

---

## Flujo del builder en workshop

### 1. Bootstrap

```bash
bash scripts/bootstrap.sh
# o
npx smart-vibe init

# Preguntas:
# 1. ¿Tipo? → workshop
# 2. ¿Tier? → startup
# 3. ¿Vertical? → general
# 4. ¿Cuántos teams? → 3
# 5. ¿Nombres y dominios de cada team?
```

Output: monorepo con shell, 3 apps de team, 7 packages compartidos, workshop.yaml pre-poblado.

### 2. Setup local

```bash
cd hackathon-2026
pnpm install

# Dev cruzado (shell + team-1):
pnpm turbo dev --filter=shell --filter=...team-1
```

### 3. Cada team trabaja en `apps/<team>/`

- Como si fuera un proyecto `node-ts` standalone.
- Consume packages cross-cutting con `import { ... } from "@workshop/design-system"`.
- Tiene su `phs.yaml` propio que referencia el `workshop.yaml` global.

### 4. Integración cross-team

- Cambios al design-system → PR único, todos los teams se rebasean.
- API contracts → versioning con `workspace:*`. Breaking change = PR lock hasta que todos migren.
- `pnpm turbo build` corre solo lo afectado.

### 5. Graduación

`/smart-workshop graduate-all` (lo opera celeru-pro):
- F1 (discovery) corre **una vez** para `workshop.yaml` + N PHS de teams.
- F2-F6 corren **por team en paralelo**.
- F7 produce **un handoff por team** + uno consolidado.

---

## Decisiones del addon workshop

### DB strategy default
**`shared-schema-isolated-rows`** con Row Level Security opcional.

Razones:
- Setup más simple en hackathon (un solo Postgres).
- Aislación lógica suficiente con RLS.
- Migración a `schema-per-team` o `db-per-team` posible si crece.

### Versioning interno
**`workspace:*`** sin SemVer entre packages internos.

Razones:
- En MVP, todos los teams están en el mismo monorepo y se mueven juntos.
- Breaking change = PR atómico que actualiza package + consumidores.
- SemVer interno = ceremonial sin payoff en hackathon.

### Comunicación inter-team
**HTTP via `api-contracts`** en MVP.

Event bus / messaging queda como TODO Fase 2 (en `packages/events/`, no incluido en v0.1.0).

### Migrations owner
**El `shell`** es dueño de las migraciones consolidadas.

Cada team puede crear migraciones bajo su namespace; el shell las consolida en una single source para la DB compartida.

### Deployment strategy default
**`independent-per-team`** — cada team se deploya a su propio target.

`shell` se deploya separado. Esto evita coupling de release cycles.

---

## Validación

```bash
# Validar workshop.yaml schema
bash scripts/doctor.sh workshop validate workshop.yaml

# Validar inconsistencia entre workshop.mode y team modes
bash scripts/doctor.sh workshop validate-modes
```

`doctor.sh` flaggea si:
- Algún team declara `mode: graduating` cuando workshop está en `vibe`.
- Algún team referencia un `workshop.yaml` con path incorrecto.
- `apis_external.access` lista un team que no existe en `teams[]`.
- `storage.access` lista un team que no existe.
- `migrations_owner` apunta a un team/shell inexistente.

---

## Diferencias clave vs `single-team`

| Aspecto | single-team | workshop |
|---|---|---|
| Estructura | Repo plano, un addon | Monorepo Turborepo |
| SSOT | `phs.yaml` | `phs.yaml` por team + `workshop.yaml` raíz |
| Tooling | Por proyecto | Compartido en `packages/config` |
| Deployment | Único | Independent-per-team |
| Graduación | `/smart-graduate` | `/smart-workshop graduate-all` |

---

## Out of scope para v0.1.0 (TODO Fase 2)

- `packages/events/` — bus inter-team.
- `packages/api-clients/` — autogen desde api-contracts.
- `example-corporate-squads.yaml` para `core/workshop-spec/`.
- Soporte de `db-per-team` con orquestación CDK.
- Style Dictionary integration en `design-system`.
- Storybook para `design-system/components`.
- Vault / AWS Secrets Manager integration.
- Remote Turbo cache.

---

## Referencias

- Schema: `core/workshop-spec/schema.{yaml,ts}`
- Plan aprobado completo: `~/.claude/plans/parsed-chasing-boole.md`
- Addon root: `addons/workshop/`
- Plugin commands: `plugin/commands/smart-workshop.md`
