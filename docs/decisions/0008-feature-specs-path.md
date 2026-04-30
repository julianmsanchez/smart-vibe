# 0008 · Path canónico de feature specs en el wiki

- **Status:** Accepted
- **Date:** 2026-04-30
- **Deciders:** Julian Sánchez

## Contexto

Durante el dogfood del workshop addon (2026-04-29) se detectó una inconsistencia: el wiki-skeleton crea `wiki/docs/features/` (con su `_template.md`), pero 6+ refs en plugin/commands y agents apuntaban a `wiki/features/`. La doble convención causa fricción al builder y rompe links generados por slash commands.

Las otras tres carpetas operativas del wiki ya viven todas bajo `wiki/docs/`:
- `wiki/docs/session_summaries/`
- `wiki/docs/implementation_logs/`
- `wiki/docs/SSOT/`
- `wiki/docs/changelog/`

## Decisión

El path canónico de feature specs es **`wiki/docs/features/`**.

Razones:
1. Consistencia con las demás carpetas operativas (session_summaries, implementation_logs, SSOT, changelog).
2. `wiki/` raíz queda reservada para los 2-3 archivos navegacionales (`Home.md`, `RESUME.md`, `ROADMAP.md`, `PRD.md`), no para colecciones.
3. El skeleton ya creaba la carpeta así; alinear el resto al skeleton es el cambio más chico.

## Consecuencias

- Actualizar 6 refs (`plugin/commands/smart-feature.md`, `smart-close-feature.md` x2, `smart-teleport.md`, `smart-implementation-log.md`, `plugin/agents/doc-writer.md`).
- Actualizar `core/playbooks/04-no-readme.md` y `core/wiki-skeleton/docs/changelog/CHANGELOG.md`.
- Actualizar `docs/USER-GUIDE.md`.
- Builders que ya tengan `wiki/features/` legacy: migrar manualmente con `git mv wiki/features wiki/docs/features` (no auto-migration porque smart-vibe no toca proyectos ya generados).

## Alternativas consideradas

- **`wiki/features/` (raíz):** rechazada — inconsistente con el resto de las carpetas operativas.
- **`wiki/docs/features/` + alias `wiki/features/` como symlink:** rechazada — duplica complejidad sin beneficio claro.
