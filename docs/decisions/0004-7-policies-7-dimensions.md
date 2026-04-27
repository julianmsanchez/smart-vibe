# 0004 · 7 policies = 7 dimensiones de auditoría

- **Status:** Accepted
- **Date:** 2026-04-27
- **Deciders:** Julian Sánchez

## Contexto

El framework define **7 dimensiones de auditoría** (security, architecture, code-quality, data, ops, docs, change-control) y necesita una capa **operativa** que el builder pueda leer en modo vibe (sin agentes pesados) y que sirva como gate en graduating.

Pregunta: ¿cómo se materializan las dimensiones en el repo? ¿Una sola "policy general"? ¿7 policies independientes? ¿15 policies más granulares?

## Decisión

**Mapeo 1-a-1**: 7 dimensiones × 7 policies. Cada dimensión tiene exactamente una policy correspondiente, en el mismo orden:

| # | Dimensión | Policy file |
|---|---|---|
| 1 | Security | `core/policies/01-security.md` |
| 2 | Architecture | `core/policies/02-architecture.md` |
| 3 | Code Quality | `core/policies/03-code-quality.md` |
| 4 | Data | `core/policies/04-data.md` |
| 5 | Operations | `core/policies/05-ops.md` |
| 6 | Documentation | `core/policies/06-docs.md` |
| 7 | Change Control | `core/policies/07-change-control.md` |

Cada policy se entrega en **dos versiones**:
- **Modo vibe** (lo que copia el bootstrap): principios + checklist liviano. Sin gates.
- **Modo graduating** (lo extiende `celeru-pro`): gates 0-5 con sub-criterios.

## Alternativas consideradas

### A) Una policy general
Un solo `core/policy.md` con todo dentro.

**Rechazado** porque:
- Archivo enorme, difícil de mantener parcialmente.
- El builder no puede ignorar una sección sin perder contexto del resto.
- Auditorías cross-dimensión vuelven imposible localizar issues.

### B) Más granular (15+ policies)
Separar "auth" de "input validation" de "secret management" en policies independientes.

**Rechazado** porque:
- Las dimensiones ya cubren la granularidad correcta para el builder.
- Sub-criterios (5 por dimensión, definidos en `05-audit-dimensions.md`) ya proveen la granularidad operativa.
- Más archivos = más overhead sin payoff.

### C) Policies por vertical
Un set por fintech, otro por salud, etc.

**Rechazado** porque:
- Las dimensiones son universales; la verticalización aplica al **contenido específico** dentro de cada policy (compliance frameworks distintos), no a la estructura.
- Verticales se manejan vía `compliance.frameworks` en el PHS y addons opt-in (compliance-fintech, compliance-salud).

### D) Mapping N-a-M
Policies pueden cubrir múltiples dimensiones o viceversa.

**Rechazado** porque:
- Confunde al builder ("¿en qué archivo busco esto?").
- Audits cross-dimension complican el reporting (`05-audit-dimensions.md` asume mapping limpio).

## Consecuencias

### Positivas
- **Navegabilidad**: el builder sabe exactamente dónde buscar.
- **Audits trazables**: cada finding apunta a sub-criterio → dimensión → policy → archivo concreto.
- **Versionado independiente**: una policy puede evolucionar sin tocar las otras.
- **Bootstrap simple**: copiar 7 archivos a `docs/policies/` del proyecto del builder.

### Negativas
- Hay overlap conceptual entre algunas (ej: secret management aparece en security pero también en ops). Mitigación: cada policy hace cross-reference explícito a la otra cuando aplica.
- Si en el futuro se descubre una 8ª dimensión, hay que renombrar. Mitigación: la numeración no es tan rígida como para que duela; la matriz dimensión↔policy es 1-a-1 conceptual, no nominal.

## Implementación

- `core/policies/README.md` lista las 7 con cross-reference a `docs/framework/05-audit-dimensions.md`.
- Cada `0X-<dimension>.md` tiene la misma estructura:
  - **Pregunta nuclear** (de `05-audit-dimensions.md`).
  - **Principios** (modo vibe).
  - **Checklist liviano** (modo vibe).
  - **Anti-patrones a evitar**.
  - **Para graduating**: enlaza a sub-criterios 0-5 que `celeru-pro` ejecuta.

## Referencias

- `docs/framework/05-audit-dimensions.md`
- `core/policies/` (Bloque C en plan operativo)
- `docs/framework/04-golden-rules.md`
