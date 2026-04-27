# `core/workshop-spec/` — Workshop Spec

> Segundo SSOT del Smart Vibe Framework (el primero es `core/phs/`). Define el contrato del archivo `workshop.yaml` que vive en la raíz de cada **monorepo** generado por el addon `workshop`.

---

## Archivos

| Archivo | Rol |
|---|---|
| `schema.yaml` | Schema canónico **legible**. Para humanos. |
| `schema.ts` | Schema **ejecutable** (Zod). Importable por celeru-pro, doctor.sh, plugin. |
| `example-hackathon.yaml` | Ejemplo válido — hackathon de 3 teams con DB compartida + RLS. |
| `validation-rules.md` | Reglas semánticas + cross-field + por modo + auto-derivaciones. |

---

## Cuándo aplica

Solo si `phs.yaml.project.type === "workshop"`. Cada team del monorepo tiene su propio `apps/<team>/phs.yaml` que **referencia** el `workshop.yaml` global vía `workshop.ref`.

```
hackathon-2026/
├── workshop.yaml          ← este SSOT
├── apps/
│   ├── team-checkout/
│   │   └── phs.yaml       ← referencia ../../workshop.yaml
│   ├── team-search/
│   │   └── phs.yaml
│   └── team-recs/
│       └── phs.yaml
└── packages/
    ├── design-system/
    ├── auth/
    ├── api-contracts/
    ├── config/
    ├── infra-contracts/
    ├── fixtures/
    └── types/
```

---

## Qué declara `workshop.yaml`

| Sección | Contenido |
|---|---|
| `workshop.{name,type,mode}` | Identidad y modo del monorepo. |
| `shell` | Cómo el shell Next.js monta a cada team. |
| `teams[]` | Lista de teams: id, dominio, app_path, api_prefix, members. |
| `shared_infra.apis_external[]` | APIs externas compartidas (con whitelist por team y budget). |
| `shared_infra.databases` | Strategy (RLS / schema-per-team / db-per-team) + URL env + migrations_owner. |
| `shared_infra.storage[]` | Buckets con provider y whitelist por team. |
| `shared_infra.secrets` | Strategy (dotenv local / Vault / SM) + rotation owner. |
| `shared_infra.observability` | Logger, formato, correlation header, destination, métricas. |
| `ui_shared` | Paths a tokens, components, assets del design-system. |
| `fixtures` | Path a seeds + estrategia de mocks (MSW). |
| `versioning` | Strategy interna entre packages (workspace-protocol por default). |
| `ci_cd` | Integration check, deployment strategy, rollback owner. |

---

## Cómo se usa

### Desde código

```typescript
import { workshopSchema, type Workshop } from "smart-vibe/core/workshop-spec/schema";
import yaml from "yaml";
import fs from "node:fs";

const raw = yaml.parse(fs.readFileSync("workshop.yaml", "utf8"));
const result = workshopSchema.safeParse(raw);

if (!result.success) {
  console.error(result.error.issues);
  process.exit(1);
}

const workshop: Workshop = result.data;
```

### Desde CLI

```bash
bash scripts/doctor.sh workshop validate workshop.yaml
bash scripts/doctor.sh workshop validate-modes
```

### Desde el plugin Claude Code

```
/smart-workshop status
/smart-workshop integration-check
```

---

## Modos

Como con PHS, el schema es el mismo en los 3 modos pero las reglas semánticas varían:

| Modo | Restricciones extra |
|---|---|
| `vibe` | Estructura OK. APIs externas y storage pueden estar vacíos. `metrics_enabled: false` permitido. |
| `graduating` | `metrics_enabled: true`. RLS recomendado. Secrets no-`dotenv-local`. Integration check enabled. |
| `production` | Secrets en cloud SM/Vault. Observability con destination real (no stdout). |

Detalle en `validation-rules.md`.

---

## Relación con PHS de teams

Cada `apps/<team>/phs.yaml`:

- `project.type === "workshop"`.
- `workshop.ref` apunta al `workshop.yaml`.
- `workshop.team_id` matchea uno de `teams[].id`.
- `stack.addon === "workshop"`.
- **Su `mode` ≤ modo del workshop.**

Inconsistencias las reporta `doctor.sh workshop validate-modes`.

---

## Out of scope para v0.1.0 (TODO Fase 2)

- `example-corporate-squads.yaml`.
- Soporte completo de `queues_buses[]` (hoy reservado, sin shape).
- Soporte de `db-per-team` con orquestación CDK.
- Validación de `team-communication.md` policies.

---

## Referencias

- Descripción metodológica: `docs/framework/10-workshop-mode.md`
- Plan completo aprobado: `~/.claude/plans/parsed-chasing-boole.md`
- PHS spec (hermano): `core/phs/`
- Addon implementation: `addons/workshop/`
