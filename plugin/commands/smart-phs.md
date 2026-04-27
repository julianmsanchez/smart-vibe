---
name: smart-phs
description: Crea, edita o valida el phs.yaml del proyecto actual.
---

# /smart-phs

Maneja el Prototype Handoff Spec (PHS) del proyecto. SSOT a nivel proyecto.

## Subcomandos

### `/smart-phs init`
Crea un `phs.yaml` skeleton si no existe. Útil para retrofit en proyecto existente.

### `/smart-phs validate`
Corre validación Zod del `phs.yaml`. Reporta:
- Campos requeridos faltantes (en modo vibe sólo warnings; en graduating son errores).
- Constraints cross-field (`type=workshop ⇒ workshop.ref required`, etc.).
- Sugerencias de auto-derivación (vertical → tier, mode → policies activas).

### `/smart-phs add-decision <título>`
Agrega una entrada a `decisions[]` con timestamp + autor. Recuerda mantener decisiones cortas (1-3 líneas).

### `/smart-phs show`
Imprime el PHS formateado con highlights del modo actual.

## Cuándo usar

- Después de `/smart-bootstrap` para completar el PHS.
- Cada vez que tomás una decisión arquitectónica → `add-decision`.
- Antes de un `/smart-graduate` → `validate`.

## Implementación

- `init` → escribe `phs.yaml` desde `core/phs/example-startup.yaml` (template más permisivo).
- `validate` → carga `core/phs/schema.ts` y corre `phsSchema.safeParse()` sobre el YAML parseado.
- `add-decision` → edita `phs.yaml` agregando entry a `decisions[]` (mantiene comentarios via yaml-ast-parser).
- `show` → imprime YAML con secciones agrupadas y warnings de campos vacíos.

## Modo vibe vs graduating

- **vibe:** validación es permisiva. Campos vacíos son OK.
- **graduating:** todos los campos requeridos en `validation-rules.md` deben estar llenos.
- **production:** owned por celeru-pro.
