# `core/phs/` — PHS (Prototype Handoff Spec)

> Uno de los dos SSOT del Smart Vibe Framework. Define el contrato del archivo `phs.yaml` que vive en la raíz de cada proyecto del builder.

---

## Archivos

| Archivo | Rol |
|---|---|
| `schema.yaml` | Schema canónico **legible**. Para humanos. |
| `schema.ts` | Schema **ejecutable** (Zod). Importable por celeru-pro, doctor.sh, plugin. |
| `example-startup.yaml` | Ejemplo válido — startup en modo vibe (single-team). |
| `example-corporate.yaml` | Ejemplo válido — corporate fintech (compliance auto-true). |
| `example-workshop.yaml` | Ejemplo válido — team dentro de un workshop monorepo. |
| `validation-rules.md` | Reglas semánticas por modo + cross-field + auto-derivaciones. |

---

## Cuándo `schema.yaml` vs `schema.ts`

- **Schema.yaml** es la doc legible. Útil para entender el shape sin leer Zod.
- **Schema.ts** es la fuente de verdad técnica. Si difieren, manda `.ts`.
- Cualquier cambio se aplica a ambos archivos en el mismo commit.

---

## Cómo se usa

### Desde código

```typescript
import { phsSchema, type PHS } from "smart-vibe/core/phs/schema";
import yaml from "yaml";
import fs from "node:fs";

const raw = yaml.parse(fs.readFileSync("phs.yaml", "utf8"));
const result = phsSchema.safeParse(raw);

if (!result.success) {
  console.error(result.error.issues);
  process.exit(1);
}

const phs: PHS = result.data;
```

### Desde CLI

```bash
bash scripts/doctor.sh phs validate phs.yaml
```

### Desde el plugin Claude Code

```
/smart-phs validate
```

---

## Modos y completitud

El **schema** es el mismo para los 3 modos. Lo que varía es **qué campos pueden estar vacíos** sin que la validación falle:

| Modo | Validación |
|---|---|
| `vibe` | Estructura OK + addons[] no vacío. Resto puede estar `~`. |
| `graduating` | Vibe + data + infra + auth + ≥3 ADRs + runbooks. |
| `production` | Graduating + SLA completo + ADRs cubren todas las dimensiones grandes. |

Detalle en `validation-rules.md`.

---

## Relación con `workshop.yaml`

Si el proyecto es `type: workshop`:

- Existe **un `workshop.yaml`** en la raíz del monorepo (SSOT cross-cutting de teams + infra compartida).
- Cada `apps/<team>/phs.yaml` referencia el workshop vía `workshop.ref`.
- Schema del workshop en `core/workshop-spec/`.

---

## Evolución

- Cambios al schema requieren actualizar `schema.yaml` + `schema.ts` + ejemplos + `validation-rules.md` en el mismo commit.
- Breaking changes documentados como ADR en `docs/decisions/` y nota en CHANGELOG.
- `PHS_SCHEMA_VERSION` constante exportada por `schema.ts`.

---

## Referencias

- Descripción metodológica: `docs/framework/03-phs-spec.md`
- Workshop spec: `core/workshop-spec/`
- ADR 0002 (PHS como SSOT): `docs/decisions/0002-phs-as-ssot.md`
