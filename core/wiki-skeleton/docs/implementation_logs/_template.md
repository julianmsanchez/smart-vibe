# Implementation Log — YYYY-MM-DD — <feature-slug>

> Log detallado de la implementación de una feature concreta. Más profundo que un session summary, menos formal que una ADR. Útil para entender el "por qué" técnico de una elección que vino con trade-offs.

- **Feature:** _nombre corto_
- **Fecha de inicio:** YYYY-MM-DD
- **Fecha de cierre:** YYYY-MM-DD
- **Estado final:** done / shipped / partially-done
- **Commits clave:** _hashes_

---

## Problema que resuelve

> ¿Qué necesidad había? ¿Por qué ahora?

---

## Approach elegido

> Cómo se decidió implementar. Si hay ADR formal, link y resumen.

---

## Trade-offs aceptados

> Lo que no se hizo y por qué.

- _Trade-off 1 — alternativa descartada y razón_

---

## Implementación

### Estructura de cambios

> Qué archivos se tocaron, en qué orden, y por qué.

- `src/...` — cambio + razón
- `tests/...` — qué se cubrió
- `docs/...` — qué se documentó

### Detalles técnicos relevantes

> Algoritmos no-obvios, queries SQL críticas, abstracciones internas. Solo lo que un colaborador futuro NO va a entender solo leyendo el código.

---

## Lo que salió mal

> Errores cometidos durante la implementación, dead-ends, intentos descartados. Honestidad ayuda a futuros yo.

---

## Lo que se aprendió

> Insights generalizables. Patrones que se pueden reutilizar.

---

## Tests

> Qué se cubrió, qué no se cubrió y por qué.

---

## Operacional / runbook

> Si la feature requiere operación especial (config, monitoring, alertas), describirlo. Si crece, abrir runbook dedicado en el repo.

---

## Próximos pasos

> Refactors pendientes, optimizaciones que quedaron para después, follow-ups conocidos.

- [ ] _Item 1_
