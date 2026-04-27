# 03 · PHS — Prototype Handoff Spec

> El **PHS** es el contrato YAML+Zod que vive en `phs.yaml` en la raíz de cada proyecto del builder. Es uno de los dos SSOT (single source of truth) del framework. Este doc define qué es, qué campos contiene, cómo se valida y cómo se relaciona con `workshop.yaml`.

> El **schema canónico** vive en `core/phs/schema.yaml` (legible) y `core/phs/schema.ts` (Zod, importable). Este doc es la descripción metodológica; el schema es la fuente de verdad técnica.

---

## ¿Qué es el PHS y por qué existe?

Un prototipo en modo vibe acumula decisiones implícitas: stack elegido, vertical, hosting asumido, addons activos. Cuando llega el momento de graduar (modo `graduating`), `celeru-pro` —o cualquier herramienta de transición— necesita **un único archivo** que responda *qué es este proyecto*. Sin eso, hay que entrevistar al builder.

El PHS resuelve eso. Es **el contrato que hace posible la graduación automatizada**.

Beneficios secundarios:
- El builder se ve forzado a hacer las decisiones explícitas (principio 4).
- `doctor.sh` puede chequear consistencia (`mode: production` con runbooks ausentes → warning).
- La metadata del proyecto vive **en el repo** (versionada en git), no en una herramienta externa.

---

## Ubicación

```
mi-prototipo/
├── phs.yaml          ← acá, en la raíz
├── README.md
├── CLAUDE.md
├── ...
```

En workshops:

```
hackathon-2026/
├── workshop.yaml             ← SSOT cross-cutting (a nivel monorepo)
├── apps/
│   ├── team-1/
│   │   └── phs.yaml          ← PHS por team, referencia el workshop.yaml
│   ├── team-2/
│   │   └── phs.yaml
│   └── shell/
│       └── phs.yaml
└── ...
```

---

## Estructura conceptual

El PHS está agrupado en secciones lógicas. Schema final en `core/phs/schema.yaml`; este resumen es estable a nivel concepto.

```yaml
# phs.yaml

# === Identidad y modo ===
project:
  name: mi-prototipo
  mode: vibe                  # vibe | graduating | production  (campo crítico)
  type: single-team           # single-team | workshop
  vertical: general           # general | fintech | salud | retail | edu | gobierno | telecom | otro
  tier: startup               # startup | corporate
  created_at: 2026-04-27
  description: |
    Una línea sobre qué hace el proyecto.

# === Referencia a workshop (solo si type=workshop) ===
workshop:
  ref: ../../workshop.yaml    # path relativo al monorepo root
  team_id: team-1             # solo si esta app es de un team

# === Stack ===
stack:
  language: typescript
  runtime: node@20
  framework: express          # o next, hono, etc.
  package_manager: pnpm
  addon: node-ts              # node-ts | workshop

# === Persistencia ===
data:
  primary_db: ~               # vacío en vibe; obligatorio en graduating
  cache: ~
  storage: ~

# === Hosting / infra ===
infra:
  cloud: ~                    # aws | gcp | azure | vercel | cloudflare | ~
  region: ~
  deployment: ~               # serverless | container | vm | static | ~

# === Auth ===
auth:
  provider: ~                 # supabase-auth | auth0 | cognito | clerk | custom | ~
  strategy: ~                 # oauth | password | magic-link | passkeys | ~

# === Compliance (configurable por vertical/tier) ===
compliance:
  required: false             # auto-true en vertical=fintech|salud o tier=corporate
  frameworks: []              # ["pci-dss", "hipaa", "soc2", "gdpr", ...]

# === Addons activos ===
addons:
  - node-ts                   # base addon
  # - compliance              # opt-in por vertical
  # - observability-extra     # opt-in

# === Decisiones grandes (referencia a ADRs) ===
decisions:
  - id: 0001
    title: stack-base
    file: docs/decisions/0001-stack-base.md
    status: accepted

# === SLA (solo si mode=production) ===
sla:
  uptime_target: ~            # ej: 99.5%
  rto: ~                      # recovery time objective
  rpo: ~                      # recovery point objective
  business_hours: ~

# === Wiki / docs ===
docs:
  wiki_path: mi-prototipo.wiki/
  runbooks_path: ~            # obligatorio en graduating
  decisions_path: docs/decisions/
```

---

## Reglas de validación por modo

El mismo PHS schema aplica los **3 modos**, pero la **completitud exigida** varía:

### Modo vibe (lo que aplica este toolkit)

**Obligatorio (campos críticos):**
- `project.name`
- `project.mode` (debe ser `"vibe"`)
- `project.type`
- `project.vertical`
- `project.tier`
- `stack.language`, `stack.runtime`, `stack.framework`, `stack.addon`
- `addons` (al menos uno)

**Permitido vacío:**
- `data.*`, `infra.*`, `auth.*`, `compliance.*`, `decisions[]`, `sla.*`, `docs.runbooks_path`

`doctor.sh` reporta los pendientes pero **no falla** en modo vibe.

### Modo graduating

Todo lo de vibe, más:
- `data.primary_db` (al menos)
- `infra.cloud`, `infra.region`, `infra.deployment`
- `auth.provider`, `auth.strategy`
- Al menos 3 ADRs en `decisions[]`
- `docs.runbooks_path` apunta a directorio existente con ≥1 runbook
- `compliance.required` y `compliance.frameworks` resueltos según vertical/tier

`doctor.sh` (vía celeru-pro) **falla** si algo crítico está vacío.

### Modo production

Todo lo de graduating, más:
- `sla.uptime_target`, `sla.rto`, `sla.rpo` declarados
- `decisions[]` cubre al menos: data, hosting, auth, observability, deployment

---

## Relación con workshop.yaml

En proyectos `type: workshop`:

- Existe **un `workshop.yaml`** en la raíz del monorepo. Es el SSOT cross-cutting (teams, infra compartida, UI compartida, secrets, observability, versioning, CI/CD).
- Cada `apps/<team>/phs.yaml` referencia el workshop vía `workshop.ref`.
- El campo `project.mode` del PHS individual debe ser **igual o anterior** al modo del workshop:
  - workshop en `vibe` → todos los teams en `vibe`.
  - workshop en `graduating` → teams pueden estar en `vibe` o `graduating`.
  - Inconsistencia (team en `graduating` con workshop en `vibe`) la flaggea `doctor.sh workshop validate`.

Detalle del workshop.yaml en `core/workshop-spec/` y `10-workshop-mode.md`.

---

## Ciclo de vida del PHS

1. **Bootstrap** (`scripts/bootstrap.sh`) genera `phs.yaml` con campos pre-llenados según las 4 preguntas.
2. **Modo vibe** — el builder completa campos a medida que toma decisiones. Algunos quedan vacíos (es OK).
3. **`/smart-phs validate`** — chequea estado actual sin bloquear.
4. **`/smart-graduate`** — el signal command verifica que el PHS esté completo antes de orientar a celeru-pro.
5. **Modo graduating** — celeru-pro lee el PHS, ejecuta el pipeline. Si encuentra inconsistencias, falla con plan de remediación.
6. **Modo production** — el PHS se mantiene como contrato vivo. Cambios mayores actualizan el PHS y reactivan auditoría de la dimensión afectada.

---

## Ejemplo mínimo (modo vibe, single-team)

```yaml
project:
  name: vibe-tracker
  mode: vibe
  type: single-team
  vertical: general
  tier: startup
  created_at: 2026-04-27
  description: |
    Tracker simple de objetivos personales con sync entre dispositivos.

stack:
  language: typescript
  runtime: node@20
  framework: express
  package_manager: pnpm
  addon: node-ts

addons:
  - node-ts

data:
  primary_db: ~
  cache: ~
  storage: ~

infra:
  cloud: ~
  region: ~
  deployment: ~

auth:
  provider: ~
  strategy: ~

compliance:
  required: false
  frameworks: []

decisions: []

docs:
  wiki_path: vibe-tracker.wiki/
  decisions_path: docs/decisions/
```

Este PHS es **válido en modo vibe** aunque tenga campos vacíos. `doctor.sh` reportará "8 campos pendientes" como info, no como error.

---

## Validación

```bash
# CLI
bash scripts/doctor.sh phs validate phs.yaml

# Plugin Claude Code
/smart-phs validate
```

Comportamiento esperado:
- **vibe** + estructura válida + campos críticos llenos → `OK` con lista de pendientes.
- Estructura inválida (campos no reconocidos, tipos mal) → `ERROR` con mensaje del schema.
- **graduating** + algún campo crítico vacío → `ERROR` (no se gradúa).

---

## Evolución del schema

- Cambios al schema requieren bump de versión + nota en CHANGELOG del repo.
- El campo `phs.schema_version` (a futuro) permite que `celeru-pro` lea PHS de distintas versiones sin romperse.
- Cambios breaking se documentan como ADR.

---

## Referencias

- Schema canónico: `core/phs/schema.yaml`, `core/phs/schema.ts`
- Validation rules detalladas: `core/phs/validation-rules.md`
- Ejemplos: `core/phs/example-{startup,corporate,workshop}.yaml`
- Workshop SSOT: `core/workshop-spec/schema.yaml`, `10-workshop-mode.md`
- ADR de PHS: a crear si surge cambio breaking (futuro)
