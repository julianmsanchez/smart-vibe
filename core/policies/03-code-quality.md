# Policy 03 · Code Quality

> **Dimensión:** Code Quality · **Pregunta nuclear:** ¿el código es legible, testeado y mantenible por otra persona?

---

## Principio

**Otra persona (incluyendo el yo de dentro de 6 meses) tiene que poder leer el código y entenderlo sin preguntarle al autor.** El "smart code" que solo el autor entiende es deuda técnica con intereses altos.

---

## Mínimo en `vibe`

- Lo que trae el addon (linter + formatter + tsconfig) **no se desactiva**.
- TS strict ON. Si necesitás `any`, dejá comentario `// any: <razón>`.
- Tests al menos para el happy path de la lógica crítica del MVP.

---

## Checklist (referencia para graduar)

### Linting & formatting
- [ ] ESLint configurado y corre en pre-commit.
- [ ] Prettier configurado, no hay "wars" de formato en PRs.
- [ ] Reglas custom para anti-patrones específicos del proyecto (ej: prohibir `console.log` en `src/`).
- [ ] CI bloquea merge si lint falla.

### Type safety
- [ ] `tsconfig.json` con `strict: true`.
- [ ] `any` solo en límites del sistema (parsers, libs sin tipos), siempre comentado.
- [ ] Tipos derivados con `z.infer` o equivalente cuando hay schema.
- [ ] DTOs entre capas tipados, no `any` ni `unknown` propagado.

### Test coverage
- [ ] Happy path de cada feature crítica testeada.
- [ ] Unhappy paths (input inválido, recurso no existe, dependencia falla) testeados.
- [ ] Tests son rápidos (suite completa en <30s en MVP, <2min en graduating).
- [ ] Coverage mínimo definido y monitoreado al graduar (≥80% en lógica de negocio).

### Naming & readability
- [ ] Nombres descriptivos: `userById` mejor que `getUser`. `pendingOrders` mejor que `data2`.
- [ ] Funciones <50 líneas idealmente.
- [ ] Comentarios explican "por qué", no "qué" (el código ya dice el qué).
- [ ] Sin abreviaturas crípticas (`usr`, `mgr`, `ctx` son OK; `xpg`, `qdj` no).

### Refactoring & dead code
- [ ] Sin código comentado "por si acaso" (eso es lo que es git).
- [ ] Sin imports no usados (lint los caza).
- [ ] Sin funciones no llamadas (lint con `noUnusedLocals`).
- [ ] Refactor periódico cuando un archivo crece o un patrón se repite 3 veces.

---

## Anti-patrones (banderas rojas)

- **`any` en cascada** — un `any` en una API se propaga a todo lo que la usa. Tipá en el origen.
- **`@ts-ignore` sin comentario** — ocultando un bug en lugar de arreglarlo. Si tenés que ignorar, comentá la razón.
- **Tests que testean el mock** — el test pasa porque vos definiste cómo se comporta el mock. No testea nada.
- **God function** — función de 200 líneas con 5 niveles de nesting. Extraé.
- **Comentarios mintiendo** — el código cambió, el comentario no. Peor que sin comentario.
- **Variables descriptivas que mienten** — `validatedUser` cuando no se valida nada. El nombre es contrato.
- **Dead code** — funciones, archivos, branches del if que nunca se ejecutan. Eliminar.
