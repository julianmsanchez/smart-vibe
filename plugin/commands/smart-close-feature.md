---
name: smart-close-feature
description: Workflow de cierre de una feature — commit + session_summary + update RESUME + update ROADMAP.
---

# /smart-close-feature

Cierra una feature de forma consistente: hace el commit, genera el resumen
de sesión, actualiza `wiki/RESUME.md` y `wiki/ROADMAP.md`, y deja todo
listo para que la próxima sesión arranque con contexto.

Es el complemento de `/smart-feature` (que la abre).

## Argumentos

- `<nombre>` — slug de la feature que se está cerrando. Si se omite,
  intenta deducir del branch actual o del último entry en
  `wiki/docs/features/`.

## Qué hace

1. **Verifica estado:**
   - `git status` debe mostrar cambios coherentes con la feature.
   - `bash scripts/doctor.sh --quiet` debe estar limpio (warns OK, fails no).
   - Tests del módulo deben pasar (corre `{{PACKAGE_MANAGER}} test <pattern>`).
2. **Genera commit:**
   - Mensaje siguiendo Conventional Commits (`feat(<scope>): <descripción>`).
   - Pregunta antes de commitear si hay archivos staged que no parecen
     parte de la feature.
3. **Session summary:**
   - Crea `wiki/docs/session_summaries/<YYYY-MM-DD>-<nombre>.md` con:
     decisiones tomadas, archivos tocados, qué quedó pendiente.
4. **Update RESUME.md:**
   - Sección "Última sesión" → reemplazar con resumen 1-liner.
   - Sección "TODOs activos" → quitar los completados, agregar nuevos.
5. **Update ROADMAP.md:**
   - Marcar la feature como ✅ si está completa, 🟡 si quedó parcial.
6. **Sugerencia siguiente paso:** una línea con el próximo movimiento.

## Implementación (orden)

```
1. git status + git diff --cached            → captar scope real
2. doctor + tests                            → validar que cierra limpio
3. preguntar al user si querés correr /smart-review primero
4. generar commit (con mensaje editable)
5. crear session_summary
6. update RESUME.md (sed o LLM-edit)
7. update ROADMAP.md
8. mostrar próximo paso sugerido
```

## NO hace

- Push automático. Sólo commit local. El push lo decidís vos.
- Tag de release. Eso es manual o `/smart-graduate`.
- Borrar la feature del wiki. Las features quedan documentadas aunque se cierren.

## Cuándo usar

- Terminás una feature y querés cerrarla limpio.
- Antes de pasar a la siguiente feature, para no acumular contexto.
- Antes de dejar el proyecto unas semanas (próxima sesión arranca con RESUME al día).

## Cuándo NO usar

- Si los tests no pasan: arreglá primero, después cerrá.
- Cambios cross-feature: no encajan en una sola entry de wiki/docs/features/.
- Si estás en mitad de un refactor grande: usá commits intermedios.

## Relación con otros comandos

- `/smart-feature <nombre>` abre la feature.
- `/smart-close-feature <nombre>` la cierra. Simétrico.
- `/smart-summary` da una vista global; `/smart-close-feature` toca solo lo de esta feature.
- `/smart-implementation-log` (separado) genera la nota técnica detallada
  cuando la implementación amerita más que un session_summary.
