# 0007 · Modos como ciudadanos de primera clase

- **Status:** Accepted
- **Date:** 2026-04-27
- **Deciders:** Julian Sánchez

## Contexto

Un proyecto puede estar en distintos estados de madurez. La pregunta de diseño: ¿cómo expresa el framework esos estados?

Opciones generales:
- Un **flag implícito** (e.g., basado en presencia/ausencia de archivos: si hay runbook, está en producción).
- Un **enum explícito** declarado por el builder.
- **Sin estado declarado**: el framework siempre aplica todas las reglas, el builder ignora las que no le sirven.

## Decisión

Los **modos** son un campo declarativo de primera clase del PHS:

```yaml
project:
  mode: vibe  # vibe | graduating | production
```

El framework reconoce **3 modos** (`vibe`, `graduating`, `production`). Las reglas, gates, agentes y tooling activos dependen del modo. La transición entre modos es **explícita** (acto del builder, no inferencia automática).

## Alternativas consideradas

### A) Inferir el modo del estado del repo
- "Si hay runbooks, está en production. Si hay quality gates pasados, en graduating. Si no, vibe."

**Rechazado** porque:
- Es magia frágil: un builder podría tener runbooks en `vibe` por su cuenta y ser flaggeado como production sin SLA.
- Decisiones implícitas son deuda técnica (principio 4 del framework).
- Las transiciones son momentos de decisión que merecen registro explícito.

### B) Sin modos, todas las reglas siempre activas
- Un solo set de policies, un solo pipeline, un solo nivel de exigencia.

**Rechazado** porque:
- En modo vibe ese set sería **abrumador** y mata velocidad (anti-principio 2).
- En modo production ese set podría ser **insuficiente** (no exige SLA, runbooks, post-mortems).
- La realidad es que un prototipo de hackathon y un sistema con tráfico real **no deberían medirse contra los mismos gates**.

### C) Más de 3 modos (e.g., spike, mvp, beta, ga, deprecated)
- Más granularidad.

**Rechazado** porque:
- Cada modo extra es un punto de decisión + tooling + docs adicional. Aumento de complejidad sin payoff claro en MVP.
- Los modos deben representar **transiciones reales** que requieren tooling distinto. Las gradaciones internas dentro de un modo se expresan con el **nivel de madurez** (L0–L5), que es ortogonal y observable.

### D) Modos cancelables / paralelos
- Un proyecto puede estar en "vibe" y "graduating" a la vez para distintas dimensiones.

**Rechazado** porque:
- Complejidad explosiva (`2^7 = 128` combinaciones para 7 dimensiones).
- En la práctica, las decisiones operativas son de proyecto entero, no por dimensión.

## Consecuencias

### Positivas
- El modo es **observable y auditable** (un campo del PHS, registrado en git).
- Las transiciones son **eventos explícitos** (`/smart-graduate` no se ejecuta por accidente).
- El tooling puede **rampear su exigencia** sin pelearse con el builder en modo vibe.
- `celeru-pro` puede leer el modo y activar el pipeline correcto sin ambigüedad.

### Negativas
- Un builder distraído puede dejar el modo desactualizado (proyecto en producción real con `mode: vibe`). Mitigación: `doctor.sh` flaggea inconsistencias (e.g., hay runbooks pero `mode: vibe` → warning).
- Hay un campo más que mantener actualizado.

### Reglas de transición (importantes)

1. **vibe → graduating** es un **acto explícito** del builder (corre `/smart-graduate`).
2. **graduating → production** requiere **L4 verificado** (todas las dimensiones ≥4). Lo opera `celeru-pro`.
3. **No existe transición vibe → production directo.** Saltarse graduating es violación de framework.
4. **production → graduating** es regresión válida cuando una dimensión cae a <3 o un incidente lo demanda.

## Implementación

- El PHS schema (`core/phs/schema.ts`) declara `project.mode` como campo requerido.
- `scripts/doctor.sh` valida que `mode` esté presente y sea uno de los 3 valores válidos.
- El plugin `/smart-graduate` en este repo es **signal command** (apunta a celeru-pro). En celeru-pro es el comando real.
- En workshops, el modo aplica al monorepo entero vía `workshop.yaml → workshop.mode`. Cada team debe estar en modo igual o anterior al del workshop (ver `02-modes.md`).

## Referencias

- `docs/framework/00-principles.md` § 1
- `docs/framework/01-maturity-model.md`
- `docs/framework/02-modes.md`
- `core/phs/schema.{yaml,ts}` (a crear en Bloque D)
- ADR 0006: two-distributions
