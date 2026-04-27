# PHS · Reglas de validación

> Reglas semánticas y por modo. Complementan al schema (`schema.ts` + `schema.yaml`) que valida estructura. Estas reglas se implementan parcialmente en `scripts/doctor.sh` (vibe) y en celeru-pro (graduating/production).

---

## Reglas estructurales (siempre activas)

Las cubre `phsSchema.safeParse()` directamente:

- `project.name` matchea `^[a-z0-9][a-z0-9-_]*$`.
- `project.mode` ∈ `{vibe, graduating, production}`.
- `project.type` ∈ `{single-team, workshop}`.
- `project.vertical` ∈ `{general, fintech, salud, retail, edu, gobierno, telecom, otro}`.
- `project.tier` ∈ `{startup, corporate}`.
- `project.created_at` formato `YYYY-MM-DD`.
- `addons[]` con al menos 1 elemento, valores en `{node-ts, workshop, compliance, observability-extra}`.
- `decisions[].status` ∈ `{proposed, accepted, deprecated, superseded}`.

---

## Reglas cross-field (siempre activas)

Implementadas en `superRefine`:

1. **type=workshop ⇒ workshop.ref obligatorio.**
   Un PHS de tipo workshop sin referencia al `workshop.yaml` no tiene sentido.

2. **stack.addon=workshop ⇒ project.type=workshop.**
   Inverso: si el addon es workshop, el tipo lo confirma.

---

## Reglas semánticas por modo

### Modo `vibe` (este toolkit)

**Obligatorio (gate):**
- Todos los `required` del schema (cubierto por la parse).
- `addons[]` no vacío.

**Permitido vacío (`~`):**
- `data.primary_db`, `data.cache`, `data.storage`.
- `infra.cloud`, `infra.region`, `infra.deployment`.
- `auth.provider`, `auth.strategy`.
- `decisions[]` puede estar vacío.
- `docs.runbooks_path`.

**`doctor.sh` reporta:**
- `[OK]` por cada campo crítico lleno.
- `[PENDING]` por cada campo opcional vacío. **No bloquea.**

### Modo `graduating` (lo ejerce celeru-pro)

Todo lo de vibe, MÁS:

- `data.primary_db` ≠ `~`.
- `infra.cloud` ≠ `~`, `infra.region` ≠ `~`, `infra.deployment` ≠ `~`.
- `auth.provider` ≠ `~` y `auth.strategy` ≠ `~` (si el proyecto tiene auth).
- `decisions[]` con ≥3 elementos, cubriendo: data, hosting, auth.
- `docs.runbooks_path` ≠ `~` y apunta a directorio existente con ≥1 runbook.
- `compliance.required` resuelto coherentemente:
  - vertical ∈ `{fintech, salud}` ⇒ `required: true` (enforced).
  - tier=`corporate` ⇒ `required: true` (recomendado, warning si false).

`doctor.sh` o equivalente **falla** si algo crítico está vacío.

### Modo `production`

Todo lo de graduating, MÁS:

- `sla.uptime_target`, `sla.rto`, `sla.rpo` ≠ `~`.
- `decisions[]` cubre además: observability, deployment.
- `compliance.frameworks[]` ≠ vacío si `compliance.required: true`.

---

## Reglas para `type: workshop`

Cuando `project.type === "workshop"`:

1. **`workshop.ref` debe resolver a un archivo existente** relativo al PHS.
2. **Modo del team ≤ modo del workshop:**
   - Workshop en `vibe` ⇒ todos los teams en `vibe`.
   - Workshop en `graduating` ⇒ teams en `vibe` o `graduating`.
   - Workshop en `production` ⇒ teams en cualquier modo.
   - Inconsistencia (team en `graduating` con workshop en `vibe`) la reporta `doctor.sh workshop validate` como error.
3. **`stack.addon` debe ser `workshop`** (lo enforcea la regla cross-field).
4. **`data.*` y `auth.*` pueden estar vacíos** porque suelen vivir en `workshop.yaml`.

---

## Auto-derivaciones recomendadas (bootstrap)

`scripts/bootstrap.sh` debería:

- Si vertical=`fintech` o `salud` ⇒ `compliance.required: true` por default.
- Si tier=`corporate` ⇒ `compliance.required: true` por default.
- Si addon=`workshop` ⇒ `project.type: workshop`, scaffold de `workshop.yaml`.
- `created_at` = fecha actual del bootstrap.
- `docs.decisions_path` = `"docs/decisions/"` por default.

El builder puede sobrescribir todo. Auto-derivaciones son sugerencias, no lock-ins.

---

## Errores típicos y mensajes esperados

| Error | Mensaje sugerido |
|---|---|
| `project.name` con espacios | `project.name: slug lowercase, sin espacios. Ejemplo válido: 'mi-proyecto'.` |
| `project.mode` desconocido | `project.mode: debe ser uno de [vibe, graduating, production]. Recibido: 'X'.` |
| `addons[]` vacío | `addons: al menos un addon requerido. En vibe usá 'node-ts' o 'workshop'.` |
| `type=workshop` sin `workshop.ref` | `workshop: bloque requerido cuando project.type=workshop.` |
| `addon=workshop` con `type=single-team` | `stack.addon=workshop solo permitido si project.type=workshop.` |
| `data.primary_db: ~` en `mode=graduating` | `data.primary_db: requerido en modo graduating. Definí la DB primaria.` |

---

## Versionado del schema

- `PHS_SCHEMA_VERSION` empieza en `"1.0"`.
- Cambios backward-compatible (agregar campos opcionales) → bump minor (`1.1`).
- Cambios breaking (renombrar, quitar, cambiar tipo) → bump major (`2.0`) + ADR + sección en CHANGELOG del repo smart-vibe.
- A futuro, agregar `schema_version` al PHS del builder permitirá soportar varias versiones simultáneas en `celeru-pro`.
