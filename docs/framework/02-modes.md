# 02 · Modos: vibe / graduating / production

> Los modos son ciudadanos de primera clase del framework (principio 1, ver `00-principles.md`). Este doc define cada modo, sus criterios de entrada/salida, qué tooling aplica y cómo se transita entre ellos.

---

## Resumen

| Modo | Foco | Quién lo implementa | Nivel típico | Quality gates |
|---|---|---|---|---|
| **vibe** | Velocidad. Bases mínimas. | `smart-vibe` (este toolkit) | L0–L2 | 5 Reglas de Oro |
| **graduating** | Transición a producción. | `celeru-pro` | L3 | 7 dimensiones × 0-5 |
| **production** | Operación con SLA. | `celeru-pro` | L4–L5 | Re-audits periódicas |

El modo se declara en el PHS (`project.mode`). El bootstrap **siempre** arranca en `vibe` — no se puede saltar a `graduating` sin pasar por la transición.

---

## Modo vibe

### Foco
Que el builder construya rápido, sin ceremonia. El framework previene **landmines** (no secrets, hay git, hay README, hay PHS) pero no impone procesos pesados.

### Quién lo opera
`smart-vibe` (este toolkit). 100% público, MIT, sin servicios externos obligatorios.

### Reglas activas
- **5 Reglas de Oro** (ver `04-golden-rules.md`).
- Las 7 policies existen pero en **modo vibe** (principios + checklist liviano, sin gates).

### Tooling disponible
- `scripts/bootstrap.sh` — scaffolding inicial.
- `scripts/doctor.sh` — checks livianos.
- Plugin Claude Code: `/smart-bootstrap`, `/smart-phs`, `/smart-policy`, `/smart-doctor`, `/smart-graduate` (signal), `/smart-workshop`.
- Addons: `node-ts`, `workshop`.

### Criterios de entrada
Cualquier proyecto nuevo. Ejecutar `bash scripts/bootstrap.sh` lo deja en modo vibe automáticamente.

### Criterios de salida (a graduating)
- PHS completo (todos los campos críticos llenos).
- Builder declara intención de graduar (corre `/smart-graduate`).
- Sin secretos en repo.
- Conventional Commits aplicados desde el inicio.

### Cuándo NO salir
- Mientras el proyecto sea exploratorio.
- En hackathons (workshop mode), excepto si el ganador decide graduar.
- Cuando los usuarios no son reales todavía.

---

## Modo graduating

### Foco
Llevar el prototipo de modo vibe a estar **listo para producción real**. El énfasis es **descubrir y resolver deuda técnica invisible** antes de que tenga consecuencias.

### Quién lo opera
`celeru-pro` (privado, comercial). `smart-vibe` solo emite el signal `/smart-graduate` que orienta al builder hacia `celeru-pro`.

### Reglas activas
- Todo lo de modo vibe, más:
- 7 policies en **modo graduating** (gates obligatorios, no solo principios).
- Pipeline de 7 fases con quality gates entre fases (ver `06-pipeline.md`).
- Risk taxonomy: ningún issue **CRITICAL** abierto al final.
- Auditoría 0-5 en cada dimensión × 5 sub-criterios (ver `05-audit-dimensions.md`).

### Tooling disponible
- Todo lo de modo vibe, más:
- Agentes de auditoría: `auditor`, `security-auditor`, `infra-auditor`, etc.
- Comandos: `/smart-graduate` (real), `/smart-audit`, `/smart-pipeline`.
- Generación automatizada de `deliverables/` (runbooks, ADRs faltantes, runbooks de DR).

### Criterios de entrada
- Proyecto en modo vibe con PHS completo.
- Builder corre `/smart-graduate` y `celeru-pro` está instalado.
- Decisión explícita de avanzar (es la transición, no se hace por accidente).

### Criterios de salida (a production)
- Las 7 dimensiones puntuadas en **≥4** (nivel L4).
- Quality gates de las 7 fases pasados.
- 0 issues **CRITICAL** abiertos.
- Runbooks operativos escritos y ensayados al menos una vez.
- Deployment automatizado (CI/CD verde).
- Backup + restore probado.
- SLA definido (uptime objetivo, RTO, RPO).

### Salida fallida
Si una dimensión queda en <3 al final del pipeline, **no se gradúa**. Vuelve a modo graduating con plan de remediación. Es válido (y saludable) iterar.

---

## Modo production

### Foco
Operar el sistema con **SLA activo**. Cualquier cambio mayor reactiva quality gates de la dimensión afectada.

### Quién lo opera
`celeru-pro` (con SLA contractual, runbooks vivos, observability monitoreada).

### Reglas activas
- Todo lo de graduating, más:
- Auditorías periódicas (trimestrales o anuales) para mantener nivel L4+.
- Post-mortems documentados de incidentes.
- Cambios mayores → re-auditar la dimensión afectada antes de mergear.

### Tooling disponible
- Todo lo de graduating, más:
- Comandos de operación: `/smart-incident`, `/smart-postmortem`, `/smart-audit-periodic`.
- Integraciones de observability + alerting.

### Criterios de entrada
Salida exitosa de modo graduating con todas las dimensiones ≥4.

### Criterios de regresión (vuelta a graduating)
- SLA incumplido por ≥1 trimestre sin plan de remediación.
- Una dimensión cae a <3 (audit periódica).
- Refactor mayor que afecta arquitectura o data layer.

---

## Transiciones

```
        bootstrap
            │
            ▼
       ┌─────────┐
       │  vibe   │ ◄────────┐
       └────┬────┘          │
            │ /smart-graduate
            │ (signal vibe → real graduating)
            ▼                │
       ┌─────────────┐       │
       │ graduating  │ ──────┘ (gate fallido → vuelve a graduating con plan)
       └────┬────────┘
            │ pipeline OK + L4
            ▼
       ┌─────────────┐
       │ production  │ ──────┐
       └────┬────────┘       │
            │ regresión       │
            └─────────────────┘
                              │
                              ▼
                         (vuelve a graduating)
```

**Reglas de transición:**

1. **vibe → graduating** es un **acto explícito** del builder (`/smart-graduate`). No ocurre por inferencia.
2. **graduating → production** requiere **L4 verificado** por `celeru-pro`. No es declarativo.
3. **production → graduating** puede ser **reactivo** (incidente) o **proactivo** (auditoría periódica detectó regresión).
4. **No existe vibe → production directo.** Saltarse graduating es violación de principio (ver `00-principles.md` § 1).

---

## Cómo declara el modo el PHS

```yaml
# phs.yaml
project:
  name: mi-prototipo
  mode: vibe         # ← acá. Valores: vibe | graduating | production
  vertical: general
  tier: startup
```

`scripts/doctor.sh` valida que `project.mode` esté presente. Si está vacío, falla con mensaje claro.

`celeru-pro` lee este campo para decidir qué pipeline activar.

---

## Workshop y modos

En workshops (multi-team con Turborepo), el modo aplica al **monorepo entero** vía `workshop.yaml → workshop.mode`. Todos los teams están en el mismo modo a la vez. Para graduar, se usa `/smart-workshop graduate-all` (lo opera `celeru-pro`).

Cada `apps/<team>/phs.yaml` puede declarar su propio `project.mode`, pero debe ser **igual o anterior** al modo del workshop. Un team en `graduating` dentro de un workshop en `vibe` es inconsistencia y `doctor.sh` lo flaggea.

---

## Referencia cruzada

- Principios: `00-principles.md`
- Modelo de madurez (L0–L5): `01-maturity-model.md`
- PHS spec: `03-phs-spec.md`
- 5 Reglas de Oro: `04-golden-rules.md`
- 7 dimensiones: `05-audit-dimensions.md`
- Pipeline: `06-pipeline.md`
- Workshop mode: `10-workshop-mode.md`
