# 05 · 7 Dimensiones de Auditoría

> Las **7 dimensiones** son los ejes contra los que se mide la madurez de un proyecto. Cada dimensión se mapea 1-a-1 a una **policy** en `core/policies/` y se evalúa con **5 sub-criterios** puntuados 0-5.

> En modo **vibe**, las dimensiones son **referencia** (informan al builder hacia dónde apuntar al graduar). En modo **graduating**, son **gates** (la auditoría 0-5 se ejecuta y debe alcanzar L4 para producción). En modo **production**, son **re-audits periódicas**.

---

## Las 7 dimensiones

| # | Dimensión | Pregunta nuclear | Policy correspondiente |
|---|---|---|---|
| 1 | **Security** | ¿El sistema resiste ataques esperables y maneja secretos correctamente? | `core/policies/01-security.md` |
| 2 | **Architecture** | ¿La estructura del sistema es coherente, escalable y comprensible? | `core/policies/02-architecture.md` |
| 3 | **Code Quality** | ¿El código es legible, testeado y mantenible por otra persona? | `core/policies/03-code-quality.md` |
| 4 | **Data** | ¿Los datos están modelados, persistidos, respaldados y migrables? | `core/policies/04-data.md` |
| 5 | **Operations** | ¿El sistema es observable, deployable y recuperable? | `core/policies/05-ops.md` |
| 6 | **Documentation** | ¿Otra persona puede entender, correr y operar este proyecto? | `core/policies/06-docs.md` |
| 7 | **Change Control** | ¿Los cambios son trazables, reversibles y comunicables? | `core/policies/07-change-control.md` |

---

## Escala de puntuación (0-5)

Cada sub-criterio recibe una nota:

| Nota | Significado | Equivalente |
|---|---|---|
| **0** | Ausente. No hay rastro del control. | Pre-vibe / chaos |
| **1** | Mínimo. Existe en forma básica, sin estructura. | Modo vibe (parte de las 5 reglas de oro) |
| **2** | Iniciado. Estructura existe pero incompleta o inconsistente. | Vibe maduro (L2) |
| **3** | Operativo. Cumple su función en happy path. | Graduating en proceso |
| **4** | Robusto. Maneja casos no felices, está documentado y probado. | **Mínimo aceptable para producción** |
| **5** | Excelente. Mejor práctica de la industria, mejorado iterativamente. | Production-mature |

**Regla de gate (graduating):** una dimensión pasa si **todos** sus 5 sub-criterios están en **≥4**. Una dimensión fallida bloquea graduación hasta que se remedie.

> Nota: `smart-vibe` documenta las dimensiones y sub-criterios pero **no ejecuta auditoría 0-5**. Eso lo hace `celeru-pro`. En vibe, las policies de `core/policies/` aplican una versión **liviana** (principios + checklist).

---

## Dimensión 1 · Security

**Pregunta nuclear:** ¿El sistema resiste ataques esperables y maneja secretos correctamente?

### Sub-criterios

| Sub-criterio | 0-1 | 2-3 | 4-5 |
|---|---|---|---|
| **1.1 Secret management** | Secretos en repo o chat | `.env` ignorado, `.env.example` presente | Secrets manager (Vault, AWS SM, etc.), rotación documentada |
| **1.2 Authentication & authorization** | Sin auth o auth con bugs evidentes | Auth funcional en happy path | Auth con tests, roles/permisos auditados, MFA donde aplique |
| **1.3 Input validation & output encoding** | Sin validación de inputs externos | Validación en endpoints críticos | Validación sistemática + protección contra OWASP top-10 |
| **1.4 Dependency security** | Sin escaneo, deps desactualizadas | `npm audit` o equivalente revisado periódicamente | SCA automatizado en CI, vulnerabilidades CRITICAL = blocker |
| **1.5 Logs & PII** | Logs con datos sensibles | Logs estructurados, no se loguean passwords | Logs auditados, PII tagueada, retención definida, GDPR-aware |

### Foco en vibe
Cumplir Regla 2 ("no hay secretos en el repo"). Es la única exigencia activa. El resto son referencia.

---

## Dimensión 2 · Architecture

**Pregunta nuclear:** ¿La estructura del sistema es coherente, escalable y comprensible?

### Sub-criterios

| Sub-criterio | 0-1 | 2-3 | 4-5 |
|---|---|---|---|
| **2.1 Separation of concerns** | God objects, archivos de 2k líneas | Capas mínimas (controller/service/data) | Capas claras, deps unidireccionales, no circular imports |
| **2.2 Coupling & cohesion** | Acoplamiento fuerte entre módulos no relacionados | Módulos por dominio identificables | Bounded contexts claros, contracts entre módulos |
| **2.3 Scalability path** | Sin pensamiento sobre escala | Identificación de bottlenecks principales | Horizontal scaling probado o vía serverless, plan de growth claro |
| **2.4 Error handling strategy** | `try/catch` ad-hoc, errores silenciados | Error types definidos, errores propagados con contexto | Error taxonomy completa, retries, circuit breakers donde aplique |
| **2.5 ADRs cubiertas** | Decisiones implícitas | 2-3 ADRs principales escritas | ADRs cubren todas las decisiones grandes (data, hosting, auth, deployment, observability) |

### Foco en vibe
Estructura de carpetas razonable (lo da el addon). ADRs para decisiones grandes (Regla 5). Resto es referencia.

---

## Dimensión 3 · Code Quality

**Pregunta nuclear:** ¿El código es legible, testeado y mantenible por otra persona?

### Sub-criterios

| Sub-criterio | 0-1 | 2-3 | 4-5 |
|---|---|---|---|
| **3.1 Linting & formatting** | Sin linter, code style inconsistente | ESLint + Prettier configurados | Linter en CI como blocker, reglas custom para anti-patrones |
| **3.2 Type safety** | JS sin tipos, `any` por todos lados | TS con mayoría de tipos, algunos `any` | TS strict, `any` solo justificado, generics donde aplique |
| **3.3 Test coverage** | Sin tests | Happy path cubierto | Happy + unhappy paths, integration tests, ≥80% coverage en lógica de negocio |
| **3.4 Naming & readability** | Variables `x`, `tmp`, `data2` | Nombres legibles, comentarios donde haga falta | Convenciones consistentes, código auto-documentado, comentarios solo donde explican "por qué" |
| **3.5 Refactoring & dead code** | Código muerto, copy-paste evidente | Algo de cleanup periódico | Refactor continuo, no hay código muerto, complejidad ciclomática controlada |

### Foco en vibe
Lo que trae el addon (linter + tsconfig + ejemplos de tests). Si el builder rompe esto, lo está haciendo activamente.

---

## Dimensión 4 · Data

**Pregunta nuclear:** ¿Los datos están modelados, persistidos, respaldados y migrables?

### Sub-criterios

| Sub-criterio | 0-1 | 2-3 | 4-5 |
|---|---|---|---|
| **4.1 Data model definido** | Sin schema, JSON ad-hoc | Schema en migraciones | Schema versionado, foreign keys, constraints, índices |
| **4.2 Migrations** | `ALTER TABLE` manuales en prod | Migraciones como archivos | Migraciones automatizadas, reversibles, probadas en staging |
| **4.3 Backup & restore** | Sin backups | Backups manuales periódicos | Backups automatizados, restore probado al menos 1 vez |
| **4.4 PII & data classification** | Sin clasificación | PII identificada, no se loguea | Data classification, retention policies, derecho de eliminación (GDPR/LATAM equivalente) |
| **4.5 Data integrity** | Sin validación | Validación en app layer | Validación app + DB constraints + tests de integridad |

### Foco en vibe
Declarar `data.primary_db` en PHS si lo hay. Lo demás es referencia.

---

## Dimensión 5 · Operations (Ops)

**Pregunta nuclear:** ¿El sistema es observable, deployable y recuperable?

### Sub-criterios

| Sub-criterio | 0-1 | 2-3 | 4-5 |
|---|---|---|---|
| **5.1 Logging** | `console.log` | Logger estructurado (json) | Correlation IDs, niveles, sampling, destination configurable |
| **5.2 Metrics & monitoring** | Sin métricas | Métricas básicas (uptime, latency) | RED/USE metrics, dashboards, percentiles |
| **5.3 Alerting** | Sin alertas | Alertas por uptime | Alertas por SLO, runbook por alerta, escalation path |
| **5.4 Deployment automation** | Deploy manual | CI/CD básico | CD con quality gates, blue-green o canary, rollback automatizado |
| **5.5 Disaster recovery** | Sin plan | Plan documentado | Plan + ensayo periódico, RTO/RPO conocidos y respetados |

### Foco en vibe
Logger estructurado (lo trae el addon `node-ts`). Lo demás es para graduating.

---

## Dimensión 6 · Documentation

**Pregunta nuclear:** ¿Otra persona puede entender, correr y operar este proyecto?

### Sub-criterios

| Sub-criterio | 0-1 | 2-3 | 4-5 |
|---|---|---|---|
| **6.1 README** | Ausente o vacío | Setup + comandos básicos | README completo: pitch, setup, stack, comandos, troubleshooting |
| **6.2 CLAUDE.md** | Ausente | Generado por bootstrap, sin actualizar | Mantenido al día, cubre convenciones del proyecto |
| **6.3 ADRs** | Sin decisiones documentadas | 2-3 ADRs grandes | Todas las decisiones grandes documentadas, cross-referencias entre ADRs |
| **6.4 API / interface docs** | Sin docs de API | Endpoints listados | OpenAPI/JSON schema generado + ejemplos de uso |
| **6.5 Operational docs (runbooks)** | Sin runbooks | Runbook de deploy | Runbooks por incidente común, cada uno ensayado |

### Foco en vibe
README + CLAUDE.md (Regla 4). ADRs para decisiones grandes (Regla 5). El resto es referencia.

---

## Dimensión 7 · Change Control

**Pregunta nuclear:** ¿Los cambios son trazables, reversibles y comunicables?

### Sub-criterios

| Sub-criterio | 0-1 | 2-3 | 4-5 |
|---|---|---|---|
| **7.1 Version control hygiene** | Commits caóticos, archivos no commiteados | Conventional Commits, git limpio | Commits atómicos, mensajes descriptivos, squash de WIPs antes de merge |
| **7.2 Branching strategy** | Trabajo en main sin orden | Feature branches o trunk-based consistente | Estrategia documentada, PRs con review |
| **7.3 CHANGELOG** | Sin changelog | Manual y desactualizado | Mantenido en cada release, formato semántico |
| **7.4 Versioning** | Sin versiones | Tags ad-hoc | SemVer riguroso, breaking changes señalados |
| **7.5 Release process** | "Push a main" como release | Release manual con notas | Release automatizado, notas generadas de Conventional Commits, rollback plan por release |

### Foco en vibe
Conventional Commits (Regla 3). Lo demás es referencia.

---

## Cómo se compone el nivel de madurez

El **nivel** del proyecto (L0–L5) es función de las puntuaciones por dimensión.

Regla simplificada (formal en `01-maturity-model.md`):
- **L1** — todas las dimensiones con al menos un sub-criterio en 1+ (las 5 reglas cumplidas).
- **L2** — todas las dimensiones promedio ≥2.
- **L3** — todas las dimensiones promedio ≥3 (modo `graduating` activo).
- **L4** — todas las dimensiones promedio **y mínimo** ≥4 (apto para `production`).
- **L5** — todas las dimensiones promedio ≥4.5 + sostenido en el tiempo + post-mortems documentados.

Nota: en `graduating` se aplica la **regla del mínimo** (no promedio), porque un sub-criterio en 2 puede ser un landmine de producción aunque el resto esté en 5.

---

## ¿Qué pasa si una dimensión queda baja?

- **En vibe:** nada. Es info para que el builder sepa hacia dónde apuntar.
- **En graduating:** auditoría falla, no se gradúa. Plan de remediación priorizado por sub-criterio más bajo.
- **En production:** re-audit periódica detecta regresión. Si una dimensión cae <3, regresión a `graduating` con plan.

---

## Referencias

- Policies (una por dimensión): `core/policies/`
- Modelo de madurez: `01-maturity-model.md`
- Pipeline de graduación: `06-pipeline.md`
- Risk taxonomy (cómo se reportan los hallazgos): `08-risk-taxonomy.md`
- Output artifacts (qué entrega el pipeline): `09-output-artifacts.md`
