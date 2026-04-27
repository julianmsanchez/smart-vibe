# 0005 · Conventional Commits obligatorio desde día 1

- **Status:** Accepted
- **Date:** 2026-04-27
- **Deciders:** Julian Sánchez

## Contexto

Cualquier proyecto en modo vibe va a acumular cientos de commits durante su vida. Cuando llega graduating, `celeru-pro` necesita **leer la historia** para:
- Reconstruir decisiones tomadas en el journey.
- Generar CHANGELOG automáticamente.
- Detectar breaking changes (para SemVer).
- Identificar momentos de regresión en dimensiones.
- Mapear features a fases del pipeline.

Si los commits son `wip`, `stuff`, `more changes`, **toda esa información se pierde**. Recuperarla requiere entrevistar al builder, lo cual contradice el principio de PHS como SSOT (ADR 0002).

## Decisión

**Conventional Commits es obligatorio desde el primer commit** en cualquier proyecto smart-vibe. La convención específica:

```
<type>(<scope opcional>): <subject corto en imperativo>

<body opcional explicando "por qué">

<footer opcional con BREAKING CHANGE / Closes #N / etc.>
```

**Tipos válidos:**
- `feat` — nueva funcionalidad.
- `fix` — bug fix.
- `docs` — solo docs.
- `style` — formato (no afecta lógica).
- `refactor` — cambio interno sin cambio de comportamiento.
- `test` — agregar/modificar tests.
- `chore` — tareas de tooling, deps, config.
- `ci` — cambios al pipeline CI/CD.
- `perf` — mejora de performance.
- `build` — cambios al sistema de build.
- `revert` — revertir un commit anterior.

Spec completa: https://www.conventionalcommits.org/.

**Granularidad recomendada:** un commit por **bundle coherente**, no por archivo suelto. Un bundle es un grupo de cambios que avanzan un objetivo concreto.

## Alternativas consideradas

### A) Sin convención obligatoria
"Que el builder use lo que quiera, en graduating se reorganiza."

**Rechazado** porque:
- Reorganizar history retroactivamente es destructivo (cambia hashes, rompe referencias, requiere force-push).
- En la práctica, los builders nunca reorganizan; la deuda se acumula.
- celeru-pro tendría que hacer NLP sobre commit messages caóticos para extraer info.

### B) Conventional Commits "recomendado pero no forzado"
**Rechazado** porque:
- "Recomendado" en práctica = ignorado bajo presión.
- La convención solo aporta valor si es consistente.

### C) Otra convención (gitmoji, angular subset, etc.)
**Rechazado** porque:
- Conventional Commits es estándar de facto, ecosistema enorme (commitlint, semantic-release, conventional-changelog).
- Tooling existente para generar CHANGELOG, detectar breaking, etc.
- Aprender otra convención = barrera para colaboradores nuevos.

### D) Hooks que rechacen commits no-convencionales
**Considerado, no implementado en MVP.** Razones:
- Bootstrap ya complejo; agregar `husky` + `commitlint` aumenta deps y fricción.
- En modo vibe preferimos cultura sobre tooling.
- `doctor.sh` chequea los últimos N commits y reporta como warning, no como blocker.
- En graduating, `celeru-pro` puede agregar el hook real si lo necesita.

## Consecuencias

### Positivas
- **CHANGELOG automatizable** (`conventional-changelog-cli` o equivalente).
- **SemVer informado** por commits (`feat` = minor, `fix` = patch, `BREAKING CHANGE` = major).
- **Auditoría trazable** — un finding puede mapear a commits específicos.
- **Onboarding de colaboradores fácil** — leen el log y entienden el progreso.
- **Compatibilidad con tooling estándar** (semantic-release, release-please, etc.).

### Negativas
- Curva de aprendizaje para builders que no la conocen. Mitigación: el bootstrap incluye un primer commit como ejemplo + `CLAUDE.md.tmpl` lo recuerda.
- Requiere disciplina en momentos de prisa. Mitigación: `chore: wip` es válido como tipo si se hace squash antes de merge.

### Mitigaciones operativas
- El plugin Claude Code (`/smart-feature`) sugiere commit messages en formato Conventional.
- `CLAUDE.md.tmpl` incluye sección dedicada con ejemplos.
- En graduating, F7 valida que **al menos los últimos 30 commits** sigan la convención.

## Implementación

- `CLAUDE.md.tmpl` (Bloque C) documenta la convención con ejemplos.
- `docs/framework/04-golden-rules.md` § Regla 3 lo refuerza como obligación.
- `scripts/doctor.sh` chequea los últimos 10 commits y reporta no-conformidad como info en vibe.
- En modo graduating (celeru-pro), se exige conformidad estricta.

## Excepciones permitidas en modo vibe

- Commits durante un spike exploratorio pueden ser `chore: wip` y squash al final.
- Commits de merge (`Merge branch ...`) no requieren tipo (lo genera git automáticamente).
- Commits del bootstrap inicial pueden agruparse como `chore: init repo + ...`.

## Referencias

- Spec: https://www.conventionalcommits.org/
- `docs/framework/04-golden-rules.md` § Regla 3
- ADR 0002: PHS como SSOT (la historia git complementa al PHS como journal de decisiones)
