# 0002 · PHS como SSOT del proyecto

- **Status:** Accepted
- **Date:** 2026-04-27
- **Deciders:** Julian Sánchez

## Contexto

El framework necesita un **contrato declarativo** que cualquier herramienta (humana o agente) pueda leer para entender qué es un proyecto sin entrevistar al builder. La pregunta: ¿cómo se materializa ese contrato?

Sin un SSOT explícito, la información del proyecto se dispersa entre:
- README.md (parcial, frecuente desactualizado).
- `package.json` (deps, no decisiones).
- Comentarios de código (efímeros).
- La cabeza del builder (no transferible).

Cuando llega graduating, recolectar esa info es costoso y propenso a errores.

## Decisión

Cada proyecto tiene un **único archivo `phs.yaml`** en su raíz que es la **única fuente autorizada** para metadata del proyecto. El archivo es:

- **YAML** (legible por humanos y agentes).
- **Validado por Zod schema** (`core/phs/schema.ts`) — type-safe, errores tempranos.
- **Versionado en git** — historia de decisiones implícita en commits.
- **Incremental** — campos vacíos en modo vibe son OK; se completan a medida que se toman decisiones.

Cualquier otra herramienta del framework (`doctor.sh`, plugin Claude, `celeru-pro`, addons) **debe leer del PHS**, no inferir del repo.

## Alternativas consideradas

### A) Múltiples archivos pequeños
Un archivo por concepto: `stack.yaml`, `infra.yaml`, `compliance.yaml`, etc.

**Rechazado** porque:
- Cross-references entre archivos son frágiles.
- El builder tiene que recordar qué va dónde.
- Validar consistencia cross-archivo agrega complejidad sin payoff.

### B) Inferir del repo
Sin archivo de spec; cada herramienta infiere de `package.json` + estructura de carpetas.

**Rechazado** porque:
- Decisiones implícitas (vertical, tier, modo) no se pueden inferir.
- Frágil ante refactors (cambia estructura → "el proyecto cambió de tipo").
- Imposible de auditar.

### C) Archivo TOML / JSON
En lugar de YAML.

**Rechazado** YAML porque:
- TOML es menos idiomático para nesting profundo.
- JSON sin comentarios → fricción para que el builder anote por qué decidió X.
- YAML + Zod es el balance correcto: humano-legible + machine-validable.

### D) Spec en `package.json` (custom field)
```json
{ "smartVibe": { "mode": "vibe", ... } }
```

**Rechazado** porque:
- Mezcla metadata de toolchain (Node, deps) con metadata de proyecto.
- Stacks no-Node no tendrían dónde poner el PHS.
- Limita la expresividad del formato.

## Consecuencias

### Positivas
- **Un solo lugar donde mirar** para entender el proyecto.
- **Auditable**: cambios al PHS van por git, con commit messages descriptivos.
- **Type-safe**: errores de schema se detectan antes de runtime.
- **Stack-agnóstico**: funciona para Node, Python, Rust, etc.
- **Habilita graduación automatizada**: `celeru-pro` lee PHS y arranca pipeline sin entrevista.

### Negativas
- Es un archivo más para mantener actualizado.
- Si el builder lo deja desactualizado, "el repo dice una cosa y el código otra" — se mitiga con `doctor.sh` que detecta inconsistencias.

### Mitigaciones operativas
- El bootstrap pre-llena 18 campos basados en las 4 preguntas.
- `/smart-phs validate` corre en cualquier momento sin bloquear.
- En `graduating`, el pipeline F1 valida y reporta gaps antes de avanzar.

## Implementación

- Schema: `core/phs/schema.{yaml,ts}`.
- Validation rules: `core/phs/validation-rules.md`.
- Spec metodológica: `docs/framework/03-phs-spec.md`.
- Validador: `scripts/doctor.sh phs validate <file>` y `/smart-phs validate`.

## Referencias

- `docs/framework/00-principles.md` § 3
- `docs/framework/03-phs-spec.md`
- ADR 0007 (modes) — el campo `mode` del PHS es central para esa decisión.
