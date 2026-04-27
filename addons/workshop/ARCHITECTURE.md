# Architecture · addon `workshop`

> Cómo se organiza un monorepo workshop. Pensado para que cualquier persona del workshop pueda navegar el repo y entender quién es dueño de qué.

---

## Las dos capas

### Capa 1 — Declarativa: `workshop.yaml`

Vive en la raíz del monorepo. Es **el** SSOT cross-cutting. Lo lee:

- humanos (al onboardear al hackathon),
- agentes Claude (`/smart-workshop status`, `integration-check`),
- `scripts/doctor.sh workshop validate`,
- `celeru-pro` cuando se gradúa.

Declara:

- **`teams[]`** — quién, dónde, qué dominio.
- **`shared_infra`** — APIs externas, DB, storage, secrets, observability.
- **`ui_shared`** — paths a tokens/components del design-system.
- **`fixtures`** — estrategia de mocks/seeds.
- **`versioning`** — workspace-protocol por default.
- **`ci_cd`** — integration check, deployment strategy.

Schema: `core/workshop-spec/`.

### Capa 2 — Concreta: packages cross-cutting

Implementan lo que `workshop.yaml` declara.

| Package | Implementa | Sec. de `workshop.yaml` |
|---|---|---|
| `design-system` | UI compartida (tokens, components, theme) | `ui_shared` |
| `types` | Tipos compartidos | — |
| `auth` | Adapter de auth | — |
| `api-contracts` | Contratos HTTP entre teams | — |
| `config` | ESLint + Prettier + tsconfig | — |
| `infra-contracts` | Tipos de APIs/DB/storage declarados | `shared_infra.{apis_external, databases, storage}` |
| `fixtures` | Seeds + MSW handlers | `fixtures` |

---

## Apps

### `apps/shell/` — Next.js shell

- Monta cada team en `/{team_id}` (config en `workshop.yaml.shell.mounts_teams_at`).
- Importa `ThemeProvider` de `@workshop/design-system/theme`.
- Es el responsable de la UI orquestadora (header, layout, navegación entre teams).
- En v0.1.0 es Next.js. La elección está cerrada por ADR (decisión 6 del SMART_VIBE_PLAN_V2).

### `apps/<team>/`

- Cada team es esencialmente un proyecto `addon: node-ts` standalone que vive dentro del monorepo.
- Tiene su propio `phs.yaml` que referencia `../../workshop.yaml`.
- Consume packages cross-cutting con `import { … } from "@workshop/<pkg>"`.

### `apps/_team-template/`

- Plantilla que el bootstrap clona N veces (una por team).
- No es un team real — empieza con `_` para que no aparezca como team activo.

---

## Flujo de un cambio típico

### Cambio de UI en design-system
1. Editás `packages/design-system/components/Button.tsx`.
2. `pnpm turbo build --filter=design-system` levanta el package.
3. Si es breaking, el PR lockea hasta que los teams afectados migren (policy en `versioning.breaking_change_policy`).

### Cambio de API contract
1. Editás Zod schema en `packages/api-contracts/src/<endpoint>.ts`.
2. Teams consumidores re-typecheck — TS rompe si firma cambió.
3. PR atómico que actualiza package + consumidores.

### Onboarding de team nuevo
1. Bootstrap clona `apps/_team-template/` a `apps/team-X/`.
2. Agregás entry en `workshop.yaml.teams[]`.
3. `apps/team-X/phs.yaml` se genera con `workshop.team_id: team-X`.
4. CODEOWNERS se actualiza automáticamente.

---

## Decisiones del addon

### DB strategy default = `shared-schema-isolated-rows`
Razones: setup más simple en hackathon. Con RLS opcional. Migración a schema-per-team o db-per-team posible después.

### Versioning interno = `workspace-protocol`
Sin SemVer entre packages internos. Todos se mueven juntos. Breaking change = PR atómico que actualiza package + consumidores.

### Comunicación inter-team = HTTP via `api-contracts`
Event bus / messaging queda como TODO Fase 2 (`packages/events/`).

### Migrations owner = `shell`
Hackathon-style. En `corporate-squads` esto se renegocia (TODO en validation-rules).

### Deployment strategy default = `independent-per-team`
Cada team a su target. Shell separado. Evita coupling de release cycles.

### Logger consumido del addon `node-ts`
El logger AsyncLocalStorage vive en `addons/node-ts/`. El workshop solo lo consume desde `apps/<team>/`. El correlation header (`x-correlation-id` por default) se declara en `workshop.yaml.shared_infra.observability` y propaga el shell a cada team.

---

## Cómo se valida coherencia

```bash
# Schema del workshop.yaml
bash scripts/doctor.sh workshop validate workshop.yaml

# Coherencia workshop.mode vs team modes
bash scripts/doctor.sh workshop validate-modes
```

Reglas chequeadas (ver `core/workshop-spec/validation-rules.md`):
- Team ids únicos.
- `apis_external.access` y `storage.access` referencian teams existentes.
- `migrations_owner`, `rollback_owner`, `secrets.rotation_owner` ∈ `{teams[].id, "shell"}`.
- En modo `graduating`, `metrics_enabled: true`.
- Cada `apps/<team>/phs.yaml` referencia el `workshop.yaml` del root.
- Modo del team ≤ modo del workshop.

---

## Out of scope (Fase 2)

- `packages/events/` — bus inter-team.
- `packages/api-clients/` — SDK autogen.
- `corporate-squads` example.
- Style Dictionary integration.
- Storybook integration.
- Vault / SM nativo.
- Remote Turbo cache.

---

## Referencias

- Spec: `core/workshop-spec/`
- Plan aprobado: `~/.claude/plans/parsed-chasing-boole.md`
- Metodología: `docs/framework/10-workshop-mode.md`
