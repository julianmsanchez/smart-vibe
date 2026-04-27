# Policies — modo `vibe`

> Una **policy** por cada una de las 7 dimensiones de auditoría. En este repo (smart-vibe) las policies son la versión **liviana**: principios + checklist + anti-patrones. No son enterprise; ese tier vive en `celeru-pro`.

> **Regla general:** en modo `vibe` solo hace falta cumplir los **principios** (las 5 reglas de oro mapean acá). Los **checklists** son referencia que el builder usa al planear graduación.

---

## Mapeo dimensión → policy

| # | Dimensión | Policy |
|---|---|---|
| 1 | Security | [`01-security.md`](01-security.md) |
| 2 | Architecture | [`02-architecture.md`](02-architecture.md) |
| 3 | Code Quality | [`03-code-quality.md`](03-code-quality.md) |
| 4 | Data | [`04-data.md`](04-data.md) |
| 5 | Operations | [`05-ops.md`](05-ops.md) |
| 6 | Documentation | [`06-docs.md`](06-docs.md) |
| 7 | Change Control | [`07-change-control.md`](07-change-control.md) |

---

## Anatomía de cada policy

Cada policy tiene 4 secciones:

1. **Principio** — la idea nuclear en 1-2 oraciones. Esto sí es ley en cualquier modo.
2. **Mínimo en `vibe`** — qué tiene que cumplir un proyecto modo vibe, mapeado a las 5 reglas.
3. **Checklist** — referencias con `[ ]` para cuando el builder se prepara a graduar. No es gate en vibe.
4. **Anti-patrones** — formas concretas de violar el principio. Reconocerlas ayuda más que repetir el principio.

---

## Cómo se aplican

- **En `vibe`:** las policies son **referencia**. El builder/agente las consulta cuando dudan si algo está bien hecho. No hay auditoría automática.
- **En `graduating`** (smart-vibe NO ofrece este modo, lo hace celeru-pro): las policies se convierten en **gates 0-5** ejecutados por el pipeline. Ver `docs/framework/05-audit-dimensions.md`.
- **En `production`** (también celeru-pro): re-audits periódicas usan estas policies como base.

---

## Por qué son livianas en smart-vibe

Smart Vibe es para **prototipos**. Pedir cobertura de tests >80% o RTO/RPO documentados a un MVP de 1 semana es absurdo. Las policies acá codifican el mínimo razonable para que el código no esté podrido y la graduación a celeru-pro sea posible sin reescribir el proyecto.

Si alguna policy te parece pobre, probablemente tu proyecto ya superó vibe y deberías estar en `graduating`.
