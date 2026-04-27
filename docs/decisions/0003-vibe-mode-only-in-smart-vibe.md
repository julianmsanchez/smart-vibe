# 0003 · smart-vibe sólo implementa modo vibe

- **Status:** Accepted
- **Date:** 2026-04-27
- **Deciders:** Julian Sánchez

## Contexto

El Smart Vibe Framework define 3 modos: `vibe`, `graduating`, `production`. La pregunta: **¿qué partes del framework implementa este repo (smart-vibe MIT)?**

Si smart-vibe implementa los 3 modos, no hay diferenciación con `celeru-pro` y se pierde el modelo de "una metodología, dos distribuciones" (ADR 0006). Si smart-vibe implementa solo vibe pero no documenta los otros, el builder pierde visibilidad de hacia dónde apunta.

## Decisión

`smart-vibe` (este repo) **sólo implementa el modo `vibe`**. Los modos `graduating` y `production` se **documentan** completamente en `docs/framework/` (parte pública de la metodología) pero su **implementación operativa** (agentes, pipeline runner, audit engine, runbook generators, observability integrations) vive en `celeru-pro`.

Lo que esto implica concretamente:

| Componente | smart-vibe | celeru-pro |
|---|---|---|
| Documentación del framework (`docs/framework/`) | ✅ completa | ❌ consume |
| Bootstrap (`scripts/bootstrap.sh`, `npx smart-vibe init`) | ✅ | ❌ |
| `doctor.sh` para checks de modo vibe | ✅ | ❌ extiende |
| Plugin: `/smart-bootstrap`, `/smart-phs`, `/smart-doctor`, `/smart-policy`, `/smart-workshop` | ✅ | ❌ |
| Plugin: `/smart-graduate` | ✅ **signal command** | ✅ **comando real** |
| Audit 0-5 engine | ❌ | ✅ |
| Pipeline runner (7 fases) | ❌ | ✅ |
| Agentes pesados (auditor, security-auditor, etc.) | ❌ | ✅ |
| Runbook generators | ❌ | ✅ |
| Re-audit periodicas | ❌ | ✅ |

## Alternativas consideradas

### A) smart-vibe implementa los 3 modos
**Rechazado** porque:
- Mezcla MIT + propietario en un repo (ADR 0006).
- Los agentes pesados de graduating/production requieren conocimiento confidencial de auditorías y compliance que no se puede publicar.
- No hay incentivo económico para sostener mantenimiento del modo production sin un modelo comercial.

### B) smart-vibe sólo implementa vibe Y documentación de vibe
- `docs/framework/` solo cubre `00-principles`, `04-golden-rules` y referencias a vibe.
- Documentación de graduating/production vive en `celeru-pro`.

**Rechazado** porque:
- El builder en vibe pierde visibilidad de qué viene después.
- "Para entender la metodología completa, comprá celeru-pro" es lock-in retórico.
- La metodología pública es un activo OSS valioso por sí solo (terceros pueden implementar graduating si quieren).

### C) smart-vibe implementa vibe + `/smart-graduate` real
**Rechazado** porque:
- Cualquier implementación real de graduate necesita los agentes pesados que viven en celeru-pro.
- Implementarlos en smart-vibe requeriría duplicar privado en público o publicar info comercial.

## Consecuencias

### Positivas
- **Distribución MIT limpia**: no hay archivos con licencia mezclada.
- **Adopción comunitaria sin fricción**: vibe funciona standalone.
- **Metodología pública abierta**: terceros pueden implementar graduating sin ser celeru-pro.
- **Modelo de negocio claro**: vibe → graduating es la transición comercial.
- **`/smart-graduate` como signal command**: orienta al builder con respeto, no como upsell agresivo.

### Negativas
- Hay que mantener **dos repos sincronizados** cuando cambia el PHS schema o las dimensiones de auditoría.
- El builder en vibe puede frustrarse si "quiere graduar y no puede sin pagar". Mitigación: el signal command muestra `--keep-vibe` y la opción de implementar graduating manualmente siguiendo `06-pipeline.md`.

### Mitigaciones
- `core/phs/schema.{yaml,ts}` y `core/workshop-spec/schema.{yaml,ts}` son MIT y `celeru-pro` los consume como dependencia.
- Cambios al schema requieren bump de versión + nota en CHANGELOG; celeru-pro lee la versión y se adapta.
- `docs/framework/06-pipeline.md`, `05-audit-dimensions.md`, `08-risk-taxonomy.md` son **suficientemente detallados** para una implementación tercera.

## Implementación

- Plugin command `/smart-graduate.md` en este repo es signal (apunta a celeru-pro).
- En celeru-pro, el mismo nombre de comando sobreescribe con la versión real.
- `scripts/doctor.sh` solo chequea reglas del modo vibe; modos avanzados son no-op con mensaje informativo.

## Referencias

- ADR 0006: two-distributions
- ADR 0007: modes-as-first-class
- `docs/framework/02-modes.md`
