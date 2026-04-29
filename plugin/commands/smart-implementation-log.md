---
name: smart-implementation-log
description: Genera entry técnico en wiki/docs/implementation_logs/ desde el contexto de la sesión.
---

# /smart-implementation-log

Captura una nota técnica detallada de cómo se implementó algo, para que
el próximo dev (o vos en 3 meses) entienda el "por qué" sin tener que
leer el diff.

Es complementario a `/smart-close-feature`:
- `/smart-close-feature` → resumen ejecutivo en `wiki/docs/session_summaries/`.
- `/smart-implementation-log` → nota técnica profunda en `wiki/docs/implementation_logs/`.

No siempre se necesitan los dos. Para implementaciones complejas o
arriesgadas (auth, pagos, jobs distribuidos, migraciones), usar este.

## Argumentos

- `<slug>` — kebab-case del tema. Ej: `auth-jwt-refresh`, `stripe-webhook-handler`.
- `--from-session` — usa el contexto de la sesión actual (default).
- `--from-commit <sha>` — usa el contexto de un commit específico.

## Qué genera

Crea `wiki/docs/implementation_logs/<YYYY-MM-DD>-<slug>.md` con el siguiente template:

```markdown
# Implementation log: <slug>

- **Fecha:** <YYYY-MM-DD>
- **Autor:** <git config user.name>
- **Commit(s):** <sha1>, <sha2>
- **Feature(s) afectada(s):** <link a wiki/features/...>
- **Modo del proyecto:** vibe | graduating

## Contexto

¿Qué problema resolvía? ¿Por qué surgió la necesidad ahora?

## Opciones evaluadas

1. **<Opción A>** — pros/contras concretos.
2. **<Opción B>** — pros/contras concretos.

## Decisión y justificación

Cuál se eligió y por qué. Linkear ADR si la decisión amerita uno.

## Implementación

Pasos concretos:
1. ...
2. ...

Archivos clave:
- `src/...` — qué hace y por qué así.

## Trade-offs aceptados

Lo que **no** se hizo bien a propósito (deuda consciente). Ej:
- "Cache en memoria, no Redis. OK para vibe; revisar en graduating."
- "Sin rate limit. Tracked en TODO `<link>`."

## Cómo verificar que funciona

Comandos / pasos para que otro confirme la implementación end-to-end.

## Riesgos conocidos

Listar fallas posibles con probabilidad/impacto cuali (low/med/high).

## Próximos pasos

- [ ] ...
- [ ] ...
```

## Implementación

1. Lee contexto de la sesión / commit:
   - `git log` y `git show` para captar archivos tocados.
   - `phs.yaml` para mode/stack.
   - Wiki existente para no duplicar.
2. LLM extrae del transcript de la sesión: problema, opciones, decisión.
3. Pregunta antes de escribir secciones que no se pueden deducir
   (ej. trade-offs aceptados conscientemente, riesgos cuali).
4. Genera el `.md` y lo abre para review humano.
5. Pregunta si actualizar `wiki/INDEX.md` para linkear el log.
6. Sugiere si la decisión amerita un ADR formal en `docs/adr/`.

## NO hace

- Auto-commitear el log. Lo deja sin staged para que el dev revise.
- Inventar trade-offs / riesgos sin contexto explícito (los marca como TODO).
- Generar implementation log para cambios triviales (refactor de una función, fix typo).

## Cuándo usar

- Después de implementar algo complejo / arriesgado / atípico.
- Cuando la justificación no encaja en el commit message.
- Antes de un handoff (`/smart-graduate`, transición de equipo).
- Para features que tocan compliance, seguridad, o data sensible.

## Cuándo NO usar

- Cambios triviales. Para eso, el commit message alcanza.
- Hot-fixes urgentes. Documentar después.
- Features experimentales que probablemente se reviertan.

## Relación con otros comandos

- `/smart-feature` abre una feature.
- `/smart-close-feature` la cierra (resumen ejecutivo).
- `/smart-implementation-log` agrega la nota técnica profunda cuando hace falta.
- ADRs en `docs/adr/` → para decisiones arquitectónicas con consecuencias estables.
- Implementation logs en `wiki/docs/implementation_logs/` → para captura cronológica de cómo se hizo algo.
