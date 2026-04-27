# Workshop Spec · Reglas de validación

> Reglas semánticas y por modo del `workshop.yaml`. Complementan al schema (`schema.ts`) que valida estructura.

---

## Reglas estructurales (siempre activas)

Las cubre `workshopSchema.safeParse()`:

- `workshop.name` matchea `^[a-z0-9][a-z0-9-_]*$`.
- `workshop.type` ∈ `{hackathon, corporate-squads, multi-product}`.
- `workshop.mode` ∈ `{vibe, graduating, production}`.
- `teams[]` ≥1 con shape válido.
- `shared_infra.databases.strategy` ∈ `{shared-schema-isolated-rows, schema-per-team, db-per-team}`.
- `secrets.strategy` ∈ `{dotenv-local, aws-secrets-manager, vault, doppler}`.
- `observability.logger` ∈ `{pino, winston, bunyan, otro}`.
- `versioning.strategy` ∈ `{workspace-protocol, semver-internal}`.

---

## Reglas cross-field (siempre activas)

Implementadas en `superRefine`:

1. **team ids únicos** — no puede haber dos teams con el mismo `id`.
2. **`apis_external[].access[]`** — cada elemento debe ser un `team.id` válido.
3. **`storage[].access[]`** — cada elemento debe ser un `team.id` válido.
4. **`migrations_owner`** debe ser `"shell"` o un `team.id` existente.
5. **`rollback_owner`** debe ser `"shell"` o un `team.id` existente.
6. **`secrets.rotation_owner`** debe ser `"shell"` o un `team.id` existente.
7. **`mode: graduating` ⇒ `observability.metrics_enabled: true`** — sin métricas no se gradúa.

---

## Reglas semánticas por modo

### Modo `vibe`

**Obligatorio:**
- Todo lo del schema (teams ≥1, shell, shared_infra, ui_shared, fixtures, versioning, ci_cd).

**Permitido suelto:**
- `apis_external` puede estar vacío (no hay APIs externas declaradas).
- `storage` puede estar vacío.
- `databases.isolation` puede ser `none` (en hackathon corto).
- `metrics_enabled: false` está OK.

### Modo `graduating`

Todo lo de vibe, MÁS:

- `metrics_enabled: true` (cubierto por superRefine).
- `databases.isolation` debería ser `row-level-security` salvo que `strategy=db-per-team` (warning, no error).
- `secrets.strategy` no debería ser `dotenv-local` (warning — recomendar Vault o cloud SM).
- `ci_cd.integration_check: enabled`.

### Modo `production`

Todo lo de graduating, MÁS:

- `secrets.strategy` ∈ `{aws-secrets-manager, vault, doppler}` (no `dotenv-local`).
- `observability.destination` ≠ `stdout` (debe haber agregador real).
- `versioning.strategy` puede mantenerse `workspace-protocol` si todo el workshop deploya junto, pero `semver-internal` es válido.

---

## Reglas para coherencia con PHS de teams

Estas se chequean por `doctor.sh workshop validate-modes` (no por el schema).

1. **Cada team del workshop tiene un `apps/<id>/phs.yaml`.**
2. **Cada `phs.yaml` de team:**
   - `project.type === "workshop"`.
   - `workshop.ref` apunta al `workshop.yaml` del root (path resolvable).
   - `workshop.team_id` matchea su carpeta y un `team.id` declarado.
   - `stack.addon === "workshop"`.
3. **Modo del team ≤ modo del workshop** (precedencia: vibe < graduating < production):
   - workshop=`vibe` ⇒ teams en `vibe`.
   - workshop=`graduating` ⇒ teams en `vibe` o `graduating`.
   - workshop=`production` ⇒ teams en cualquier modo.

---

## Auto-derivaciones recomendadas (bootstrap)

`scripts/bootstrap.sh` cuando type=workshop debería:

- Generar `workshop.yaml` con `mode: vibe`, `type: hackathon` por default.
- Crear N entries en `teams[]` (donde N = respuesta a "¿cuántos teams?").
- Pre-poblar `app_path: apps/<id>` y `api_prefix: /api/<id>` por convención.
- `shared_infra.databases.strategy: shared-schema-isolated-rows` por default.
- `shared_infra.databases.isolation: row-level-security` por default.
- `secrets.strategy: dotenv-local` (modo vibe).
- `observability.logger: pino`, `log_format: json`, `destination: stdout`.
- `fixtures.mocks_strategy: msw`.
- `versioning.strategy: workspace-protocol`.
- `ci_cd.deployment_strategy: independent-per-team`.

El builder ajusta lo que necesite. Defaults eligen "lo más común para hackathon".

---

## Errores típicos y mensajes esperados

| Error | Mensaje sugerido |
|---|---|
| `apis_external[i].access[j]` con team inexistente | `team 'X' referenciado en apis_external[i].access pero no existe en teams[]. Agregalo o quitá la referencia.` |
| `migrations_owner: 'team-x'` con team-x inexistente | `migrations_owner: 'team-x' no es 'shell' ni un team_id válido.` |
| `mode: graduating` con `metrics_enabled: false` | `modo graduating requiere observability.metrics_enabled: true.` |
| Dos teams con mismo id | `team ids deben ser únicos. Duplicado: 'X'.` |

---

## Versionado del schema

- `WORKSHOP_SCHEMA_VERSION` empieza en `"1.0"`.
- Mismo régimen que PHS: minor para additive, major para breaking + ADR + CHANGELOG.
- Estos schemas (PHS y workshop) versionan independientemente, pero idealmente avanzan en lockstep.

---

## Out of scope para v0.1.0 (Fase 2)

- Validación de `queues_buses[]` shape (reservado, hoy `array of unknown`).
- Validación de `example-corporate-squads.yaml` (queda para Fase 2).
- Validación de `team-communication.md` policies (texto libre por ahora).
