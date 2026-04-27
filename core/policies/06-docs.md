# Policy 06 · Documentation

> **Dimensión:** Documentation · **Pregunta nuclear:** ¿otra persona puede entender, correr y operar este proyecto?

---

## Principio

**Documentación = capacidad de transferir el proyecto.** Si nadie más puede levantar, modificar y deployar el sistema sin que vos estés online, la doc está rota — sin importar cuántos archivos `.md` haya.

---

## Mínimo en `vibe`

Mapeo a las 5 reglas:

- **Regla 4 — README + CLAUDE.md.** Ambos presentes y útiles.
  - **README.md** del proyecto: 1) qué es en 2 líneas, 2) cómo correrlo localmente, 3) stack y comandos básicos.
  - **CLAUDE.md** del proyecto: lo genera el bootstrap, hay que mantenerlo cuando cambian convenciones.
- **Regla 5 — ADRs para decisiones grandes.** Mínimo 1 ADR si se cambió algún default del addon.

---

## Checklist (referencia para graduar)

### README
- [ ] Pitch en 2-3 oraciones (qué hace, para quién).
- [ ] Setup local: prereqs, comandos para levantar (idealmente <5 comandos).
- [ ] Stack listado con versiones de mayor.
- [ ] Comandos comunes: `dev`, `test`, `build`, `lint`, `db:migrate`.
- [ ] Troubleshooting de problemas comunes ("si ves error X, hacé Y").
- [ ] Link a deployment doc o runbook si aplica.

### CLAUDE.md
- [ ] Mantenido al día (no `{{PLACEHOLDER}}` sin reemplazar).
- [ ] Convenciones del proyecto (naming, branching, commits).
- [ ] Restricciones (qué NO hacer en este repo).
- [ ] Links a planes operativos vigentes si aplica.

### ADRs
- [ ] ADR para cada decisión grande (data, auth, hosting, framework).
- [ ] Cada ADR usa el template `docs/decisions/_template.md`.
- [ ] ADRs cross-referencian (si una invalida otra, queda explícito).
- [ ] ADRs viejas marcadas como `Status: superseded` cuando aplique.

### API / interface docs
- [ ] OpenAPI generado (`zod-to-openapi`, `tsoa`, etc.) o equivalente.
- [ ] Ejemplos de request/response para cada endpoint.
- [ ] Códigos de error documentados.

### Operational docs (runbooks)
- [ ] Runbook de deploy (cómo deployar, cómo rollback).
- [ ] Runbook por incidente común ("DB caída", "API externa caída").
- [ ] Cada runbook ensayado al menos 1 vez.

---

## Anti-patrones (banderas rojas)

- **README "TODO"** — documentación postergada indefinidamente. El README se escribe al inicio, no al final.
- **Doc desactualizada** — peor que sin doc. Quien la lee asume que dice la verdad.
- **Comandos mágicos** — "hay que correr X y luego Y, pero solo si Z". Eso es script, no doc.
- **ADRs como changelog** — una ADR es una decisión, no un commit. Si no hay alternativas consideradas y trade-offs, no es ADR.
- **"Pregúntame"** — la doc dice "si tenés dudas, escribime". Eso es propietarismo de conocimiento, no doc.
- **Docs de implementación en código** — comentar cada línea con `// asigna user a x`. Redundante. Comentar solo el "por qué".
- **Wiki paralela divorciada** — en `wiki/` hay info que ya cambió en `src/` pero nadie sincronizó. La wiki es solo para lo que NO vive en código.
