# wiki-skeleton

> Esqueleto de la **wiki paralela** que el bootstrap copia al proyecto del builder. Si tu repo se llama `mi-proyecto`, el bootstrap genera `mi-proyecto.wiki/` (junto al repo, no dentro). Es la wiki que vive como repo paralelo en GitHub Wiki o como folder hermana.

> En modo vibe, la wiki es **opcional pero recomendada**. Es donde se acumula contexto operativo (resúmenes de sesión, logs de implementación, features detalladas) que no encaja como ADR ni como código. En `graduating`, la wiki se vuelve fuente para la fase F1 (Discovery).

---

## Estructura

```
mi-proyecto.wiki/
├── Home.md                 # landing — qué es, cómo navegar, links
├── PRD.md                  # (sugerido) qué producto + para quién (conceptual)
├── ROADMAP.md              # objetivos, milestones, parking lot
├── RESUME.md               # resumen ejecutivo + estado actual
└── docs/
    ├── session_summaries/  # un archivo por sesión de trabajo
    │   └── _template.md
    ├── implementation_logs/  # logs detallados de implementación de features
    │   └── _template.md
    ├── features/           # specs de features individuales
    │   └── _template.md
    ├── teleport/           # contexto para reanudar trabajo (SESSION_CONTEXT)
    │   └── SESSION_CONTEXT.md
    └── SSOT/               # single sources of truth secundarios (no PHS, sino datos operativos)
        └── _README.md
```

---

## Filosofía

La wiki **complementa** —no reemplaza— al PHS, ADRs y código:

| Información | Va en |
|---|---|
| Decisión arquitectónica grande | ADR (`docs/decisions/`) |
| Metadata del proyecto (stack, modo, decisiones) | PHS (`phs.yaml`) |
| Cómo se hace algo (operacional) | Runbook (`docs/runbooks/`) |
| Resumen de qué se hizo en una sesión | `wiki/docs/session_summaries/` |
| Log detallado de implementar una feature | `wiki/docs/implementation_logs/` |
| Spec de una feature en flight | `wiki/docs/features/` |
| **Qué producto se construye y para quién (conceptual)** | **`wiki/PRD.md` (sugerido, opcional)** |
| Estado actual + qué viene | `wiki/RESUME.md` |
| Contexto para reanudar (teleport entre sesiones) | `wiki/docs/teleport/` |

---

## Cuándo updateás cada cosa

- **Antes de codear (sugerido, opcional):** llenar `PRD.md` con app overview, personas, KPIs y out-of-scope. Te ahorra scope creep después.
- **Después de una sesión de coding:** un `session_summary` en `docs/session_summaries/`.
- **Cuando completás una feature:** un `implementation_log` en `docs/implementation_logs/`.
- **Antes de empezar una feature compleja:** una spec en `docs/features/`.
- **Cuando cambia el rumbo del proyecto:** updatear `RESUME.md` y `ROADMAP.md` (y `PRD.md` si afecta scope).
- **Cuando vas a parar y querés reanudar después:** updatear `docs/teleport/SESSION_CONTEXT.md`.

---

## Variables de placeholder

Los `.tmpl` usan estos placeholders que el bootstrap reemplaza:

- `{{PROJECT_NAME}}` — nombre del proyecto.
- `{{PROJECT_TAGLINE}}` — una línea sobre qué hace.
- `{{TODAY}}` — fecha en formato `YYYY-MM-DD`.
- `{{MODE}}` — `vibe` por default en bootstrap.
- `{{TIER}}`, `{{VERTICAL}}`, `{{ADDON}}`.

Los archivos `_template.md` (sin `.tmpl`) son **plantillas que el builder copia manualmente** cada vez que crea un nuevo session summary, log, etc.
