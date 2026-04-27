# Smart Vibe Framework — Documentación metodológica

> Esta carpeta es la **fuente de verdad** del Smart Vibe Framework. Define los principios, modos, reglas, dimensiones, pipeline y artefactos que sostienen toda la metodología. Es **independiente de la implementación**: lo que está acá aplica a `smart-vibe` (modo vibe) y a `celeru-pro` (graduating + production).

> Si una pieza de código del repo contradice algo de acá, gana la documentación. Cambios estructurales requieren ADR explícita en `docs/decisions/`.

---

## Cómo leer esta carpeta

Si sos **builder** que recién arranca:
1. `00-principles.md` — los 10 principios que sostienen todo.
2. `04-golden-rules.md` — las únicas 5 reglas que aplican en modo vibe.
3. `02-modes.md` — entender los 3 modos.
4. `99-glossary.md` — cuando un término te confunda.

Si vas a **graduar** un proyecto:
1. `01-maturity-model.md` — saber qué nivel apuntás.
2. `06-pipeline.md` — las 7 fases que vas a recorrer.
3. `05-audit-dimensions.md` — qué se mide en cada fase.
4. `08-risk-taxonomy.md` — cómo se reportan los hallazgos.
5. `09-output-artifacts.md` — qué entregables salen del pipeline.

Si estás **implementando una alternativa a celeru-pro**:
- Toda esta carpeta es la spec. Los archivos `05`, `06`, `08`, `09` son los más densos.

Si trabajás en un **workshop multi-team**:
- `10-workshop-mode.md` (con detalle del addon).

---

## Índice

### Fundamentos
| Archivo | Contenido |
|---|---|
| [`00-principles.md`](./00-principles.md) | 10 principios del framework. Si algo parece arbitrario, está acá. |
| [`01-maturity-model.md`](./01-maturity-model.md) | Niveles L0–L5 + mapeo a modos. |
| [`02-modes.md`](./02-modes.md) | vibe / graduating / production: foco, criterios, transiciones. |
| [`99-glossary.md`](./99-glossary.md) | Términos del framework, alfabético. |

### Spec del proyecto
| Archivo | Contenido |
|---|---|
| [`03-phs-spec.md`](./03-phs-spec.md) | PHS (`phs.yaml`): contrato YAML+Zod por proyecto. |
| [`04-golden-rules.md`](./04-golden-rules.md) | Las 5 reglas obligatorias en modo vibe. |

### Auditoría y graduación
| Archivo | Contenido |
|---|---|
| [`05-audit-dimensions.md`](./05-audit-dimensions.md) | 7 dimensiones × 5 sub-criterios × 0-5. |
| [`06-pipeline.md`](./06-pipeline.md) | 7 fases con quality gates (lo opera celeru-pro). |
| [`07-architecture-decisions.md`](./07-architecture-decisions.md) | Defaults recomendados por tier/vertical. |
| [`08-risk-taxonomy.md`](./08-risk-taxonomy.md) | CRITICAL/HIGH/MEDIUM/LOW + mapeo OWASP. |
| [`09-output-artifacts.md`](./09-output-artifacts.md) | Estructura de `deliverables/`. |

### Modos especiales
| Archivo | Contenido |
|---|---|
| [`10-workshop-mode.md`](./10-workshop-mode.md) | Workshop (multi-team Turborepo) — addon, `workshop.yaml`, packages cross-cutting. |

---

## Cross-referencias importantes

```
Modos (02)  ─── declaran ───▶  Mode field del PHS (03)
                                        │
                                        ▼
                              Reglas activas en vibe (04)
                                        │
                                        ▼
                              Dimensiones aplicables (05)
                                        │
                                        ▼
                              Pipeline en graduating (06)
                                        │
                                        ▼
                              Hallazgos clasificados (08)
                                        │
                                        ▼
                              Deliverables generados (09)
                                        │
                                        ▼
                              Defaults recomendados (07)
```

El **Modelo de Madurez** (`01`) es transversal: mide qué tan lejos llegó el proyecto en el camino vibe → graduating → production.

El **Workshop Mode** (`10`) es ortogonal: aplica solo a `type: workshop` y agrega un SSOT extra (`workshop.yaml`).

---

## Estado del documento

Esta carpeta acompaña a `smart-vibe v0.1.0` (pre-release). Cambios estructurales se registran como ADRs en `docs/decisions/`.

Hoy aplican las ADRs:
- 0001 — monorepo structure
- 0002 — PHS como SSOT
- 0003 — smart-vibe sólo implementa modo vibe
- 0004 — 7 policies = 7 dimensiones
- 0005 — Conventional Commits obligatorio
- 0006 — two distributions (smart-vibe MIT + celeru-pro privado)
- 0007 — modes as first-class

---

## Mantenimiento

- Cambios al framework requieren **PR + ADR** correspondiente.
- Cuando una afirmación de un archivo cambie, actualizá también las cross-references.
- El glosario (`99`) se actualiza con cada término nuevo introducido en otros archivos.
- Si una pieza queda obsoleta, **no se borra**: se marca `> [DEPRECATED v0.x.y]` y se referencia el reemplazo.
