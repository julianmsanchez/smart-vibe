# Feature Spec — <feature-name>

> Spec ligera de una feature antes/durante implementación. Si la feature es grande, esta spec es el lugar donde piensa el plan; si es chica, podés saltearte este paso. NO confundir con ADR (la ADR registra una decisión arquitectónica; esta spec describe una feature).

- **Feature:** _nombre_
- **Status:** drafting / committed / in-progress / shipped / cancelled
- **Owner:** _tu / Claude / otro_
- **Target:** _milestone si aplica_

---

## ¿Qué problema resuelve?

> 1-2 oraciones. Si no podés explicarlo en 2 oraciones, el problema no está claro todavía.

---

## ¿A quién le sirve?

> User / persona / role. Concreto, no "todos".

---

## Comportamiento esperado

> Cómo se ve el feature funcionando. Idealmente con happy path + 2-3 unhappy paths.

### Happy path
1. _Paso 1_
2. _Paso 2_
3. _Resultado esperado_

### Unhappy paths
- _Cuando X falla → resultado_
- _Cuando Y está vacío → resultado_

---

## API / interfaces

> Si la feature toca contratos públicos, listalos.

```
GET /api/...
POST /api/...
```

---

## Cambios al modelo de datos

> Si hay schema migration, anotalo.

```sql
-- migration X
ALTER TABLE ...
```

---

## UI (si aplica)

> Mockup, descripción textual, link a Figma.

---

## Out of scope

> Cosas que la feature NO va a cubrir (para evitar scope creep).

- _Item explícitamente fuera_

---

## Dependencies

> Bloqueado por o bloquea a.

- Bloqueado por: _otra feature / spec_
- Bloquea a: _otra feature / spec_

---

## Tests planeados

- [ ] Happy path
- [ ] Unhappy: X falla
- [ ] Unhappy: Y vacío
- [ ] Edge case: ...

---

## Notas

> Cualquier contexto que aporte. Después de implementar, mover lo relevante a un implementation_log.
