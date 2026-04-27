# Playbooks

> Guías de respuesta a hallazgos comunes detectados por `doctor.sh` o por audits manuales.

Cada playbook documenta un patrón que aparece seguido en proyectos vibe y cómo resolverlo. Son cortos, ejecutables, y sirven tanto a humanos como a agentes.

## Estructura de un playbook

Cada archivo tiene 5 secciones:

1. **Síntoma** — qué se ve en el repo o en los logs.
2. **Por qué pasa** — causa raíz frecuente.
3. **Severidad** — `critical` / `high` / `medium` / `low`.
4. **Fix** — pasos concretos, ejecutables.
5. **Prevención** — cómo evitar reincidencia.

## Playbooks vigentes

| # | Playbook | Severidad | Cuándo aplica |
|---|---|---|---|
| 01 | `hardcoded-secrets.md` | critical | Hay API keys/tokens en código o logs |
| 02 | `weak-auth.md` | high | Auth ausente o débil en endpoints sensibles |
| 03 | `no-tests.md` | medium | Feature sin tests automatizados |
| 04 | `no-readme.md` | medium | README ausente o desactualizado |
| 05 | `no-env-example.md` | high | Faltan vars documentadas → onboarding roto |

## Cuándo usar

- `doctor.sh` reporta uno de estos hallazgos → seguir el playbook.
- Audit manual antes de `/smart-graduate`.
- Onboarding de un dev nuevo que pregunta "¿cómo arreglo X?".

## Cómo agregar un playbook nuevo

1. Identificar el patrón (debe haber ocurrido 3+ veces para justificar entry).
2. Crear archivo `<NN>-<slug>.md` con las 5 secciones.
3. Agregarlo a la tabla de arriba.
4. Si hace falta detección automática, agregar regla a `scripts/doctor.sh`.
