# 00 · Principios del Smart Vibe Framework

> Los principios que sostienen toda la metodología. Si alguna decisión técnica del framework parece arbitraria, probablemente esté justificada por uno de estos principios. Si la contradice, es bug, no feature.

---

## 1. Modos como ciudadanos de primera

Un proyecto siempre está en uno de tres modos: `vibe`, `graduating`, `production`. Los modos progresan secuencialmente, sin atajos:

```
vibe ─→ graduating ─→ production
```

- **vibe** — velocidad máxima, bases mínimas. Lo cubre `smart-vibe` (este toolkit).
- **graduating** — transición ordenada a producción. Lo cubre `celeru-pro`.
- **production** — operación con SLA. Lo cubre `celeru-pro`.

El modo es un campo del PHS (`project.mode`), no una convención. El bootstrap siempre arranca en `vibe`. No se puede saltar a `graduating` sin pasar por la transición.

## 2. Bases mínimas, velocidad máxima

En modo vibe, el framework **previene landmines, no impone procesos**. Las únicas reglas que aplican son las **5 Reglas de Oro** (ver `04-golden-rules.md`). Todo lo demás —políticas, dimensiones de auditoría, pipeline— vive como referencia hacia graduating, no como gate obligatorio.

El builder vibea libre. El framework asegura que cuando decida graduar no encuentre el código en estado irrecuperable.

## 3. PHS como SSOT (Single Source of Truth)

Cada proyecto tiene un `phs.yaml` en su raíz. Es el **Prototype Handoff Spec**: contrato YAML+Zod que declara stack, vertical, decisiones, modo, addons activos, etc.

- En modo vibe el PHS puede tener campos vacíos (work-in-progress).
- En modo graduating el PHS debe estar completo y validado.
- En workshops, hay un **segundo SSOT a nivel monorepo** (`workshop.yaml`) y cada `apps/<team>/phs.yaml` lo referencia.

El PHS es lo que hace posible que `celeru-pro` (u otra herramienta) tome el proyecto y lo gradúe sin entrevistar al builder.

## 4. Builder ownership: hacer las decisiones explícitas, no tomarlas por el builder

El framework **no decide por vos** qué stack usar, qué cloud, qué DB. Lo que hace es **forzar que la decisión sea explícita** y quede registrada (en el PHS, en una ADR, en `decisions/`). Decisiones implícitas son deuda técnica que aparece de noche.

Corolario: cuando un comando del plugin pregunta algo, está documentando una decisión, no haciendo busywork.

## 5. Templates sobre magic

`smart-vibe` genera archivos concretos en el repo del builder (CLAUDE.md, policies, addons, plugin commands). No hay runtime mágico que intercepte llamadas o reescriba código en vivo.

- Lo que ves en disco es lo que corre.
- El builder puede borrar, modificar o reemplazar cualquier archivo generado.
- El framework no se actualiza solo: re-correr `bootstrap` o `pnpm build:templates` es explícito.

Esto facilita debugging, audit y graduación. La contracara es que las upgrades de framework son manuales (aceptable en modo vibe).

## 6. Una metodología, dos distribuciones

El **Smart Vibe Framework** (la metodología) es uno solo. Vive en `docs/framework/` y es la fuente de verdad.

Se distribuye en dos paquetes complementarios:

| Distribución | Modos | Licencia | Audiencia |
|---|---|---|---|
| `smart-vibe` (este repo) | vibe | MIT | builders, vibers, hackathons |
| `celeru-pro` | graduating, production | Comercial | proyectos camino a producción real |

Lo que está en `docs/framework/` aplica a ambos. Lo que está en `core/`, `addons/`, `plugin/` es la implementación del modo vibe.

## 7. Las 7 dimensiones existen desde el día 1, pero pesan distinto en cada modo

Las 7 dimensiones de auditoría —security, architecture, code-quality, data, ops, docs, change-control— se mapean 1-a-1 a las 7 policies. Existen siempre, pero su exigencia varía con el modo:

- **vibe:** policies en modo "vibe" (principios + checklist liviano, sin gates).
- **graduating:** auditoría 0-5 con sub-criterios, debe alcanzar nivel L4 antes de producción.
- **production:** auditorías periódicas para mantener nivel L4+.

Detalle en `05-audit-dimensions.md` y `core/policies/`.

## 8. Conventional Commits + journal de decisiones

El framework asume que el repo del builder usa **Conventional Commits**. Es la base para que `celeru-pro` pueda generar changelogs, detectar breaking changes y rastrear decisiones cuando llegue el momento de graduar.

Decisiones grandes se documentan como ADRs (`docs/decisions/000X-<slug>.md`). Decisiones chicas viven en el commit message.

## 9. Vertical y tier configuran defaults, no comportamiento

El bootstrap pregunta `vertical` (fintech, salud, retail, etc.) y `tier` (startup, corporate). Estas respuestas configuran **defaults sensatos** (e.g., fintech activa addon de compliance), pero **no inhabilitan comportamiento**. El builder puede sobrescribir cualquier default editando el PHS.

## 10. Idioma: español por defecto, inglés en código

Documentación, comentarios y commit messages en español neutro. Identificadores de código y logs estructurados en inglés (compatibilidad con tooling y comunidad global).

---

## Cómo usar estos principios

- Si estás diseñando una feature del framework: justificála contra estos 10 principios. Si no encaja, repensá el diseño.
- Si estás auditando una contribución externa: chequeá que no contradiga ningún principio.
- Si encontrás contradicciones entre principios y código: el principio gana, el código es bug.

Los principios son estables. Cambiarlos requiere ADR explícita.
