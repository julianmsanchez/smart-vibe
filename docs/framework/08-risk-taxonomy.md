# 08 · Risk Taxonomy

> Taxonomía estandarizada para clasificar **hallazgos** (findings) que aparecen en auditorías, ya sea en `graduating` (pipeline de 7 fases) o en re-audits de `production`. La taxonomía determina **qué tan rápido** debe remediarse un hallazgo y **si bloquea o no** la graduación.

> En modo **vibe**, esta taxonomía no aplica directamente (no hay auditorías formales). Es referencia para que el builder entienda lo que viene en `graduating`.

---

## Las 4 categorías

| Nivel | Significado | SLA de remediación | Bloquea graduación |
|---|---|---|---|
| **CRITICAL** | Riesgo inminente de daño grave (pérdida de datos, brecha de seguridad explotable, downtime catastrófico) | Inmediato | **Sí, sin excepción** |
| **HIGH** | Riesgo serio que puede materializarse en producción próxima | ≤7 días | Sí, salvo plan de mitigación firmado |
| **MEDIUM** | Riesgo conocido pero contenido o de impacto medio | ≤30 días | No (se documenta como debt) |
| **LOW** | Mejora deseable, deuda técnica menor | Best effort | No |

---

## CRITICAL — definición y ejemplos

**Definición:** un hallazgo es CRITICAL si **al menos una** de estas condiciones se cumple:
- Permite **acceso no autorizado a datos** sensibles o sistemas.
- Permite **ejecución de código remoto** sin autenticación.
- Causa **pérdida de datos irreversible** en operación normal.
- **Viola compliance** declarado (PCI-DSS, HIPAA, GDPR, etc.) en forma demostrable.
- Causa **downtime total** sin posibilidad de recovery razonable.

**Ejemplos:**
- Secret de producción commiteado al repo (incluso si se rotó después, debe documentarse el incidente).
- SQL injection en endpoint público.
- Backup/restore nunca probado en proyecto de tier corporate.
- Auth con bypass conocido.
- Falta de encriptación at-rest en datos clasificados como PII.
- Endpoint sin rate limiting que permite DoS desde cliente.

**Comportamiento del pipeline:**
- En F3 (security): un CRITICAL **bloquea graduación**. No hay workaround. Hay que remediar antes de avanzar.
- En modo `production`: una re-audit que detecta CRITICAL **regresa el proyecto a graduating** automáticamente.

---

## HIGH — definición y ejemplos

**Definición:** un hallazgo es HIGH si **al menos una** de estas condiciones se cumple:
- Permite **escalada de privilegios** o acceso lateral.
- Causa **degradación severa** del servicio bajo carga normal.
- Falta un control documentado en compliance pero hay compensaciones.
- Causa **pérdida parcial** de datos en escenarios anormales (ej: race conditions).
- Vulnerabilidad SCA con score CVSS ≥7.0.

**Ejemplos:**
- Logger que escribe passwords (aunque rota cada 1h).
- Migración no reversible en producción.
- CORS demasiado permisivo en endpoints autenticados.
- Falta de rate limiting en endpoint autenticado (no bloquea pero acelera abuso).
- Dependencia con vulnerabilidad HIGH conocida sin mitigación.
- Backup configurado pero RTO/RPO no validados.

**Comportamiento del pipeline:**
- Bloquea graduación **salvo** que haya **plan de mitigación firmado** con dueño y deadline ≤7 días post-graduación.
- En `production`: dispara alerta y plan de remediación obligatorio.

---

## MEDIUM — definición y ejemplos

**Definición:** un hallazgo es MEDIUM si:
- Falta un control deseable pero no crítico (defense in depth).
- Causa **degradación menor** o solo en escenarios edge.
- Vulnerabilidad SCA CVSS 4.0–6.9 con vector explotable.
- Requiere acción del builder pero no bloquea operación normal.

**Ejemplos:**
- Falta de Content Security Policy (CSP) en frontend.
- Logs sin correlation IDs.
- Tests de integración faltantes para flow secundario.
- Falta de alerting por SLO específico (uptime sí está; latencia no).
- ADR faltante para una decisión mediana.

**Comportamiento del pipeline:**
- No bloquea graduación.
- Se documenta como **debt** en `deliverables/` con dueño y target de remediación.
- Re-audit periódica chequea progreso.

---

## LOW — definición y ejemplos

**Definición:** un hallazgo es LOW si:
- Es mejora deseable de mejor práctica.
- No tiene impacto operativo medible en horizonte 6m.
- Solo afecta DX (developer experience) o legibilidad.

**Ejemplos:**
- Comentarios desactualizados en código.
- Función pública sin doc.
- Linter rule podría agregarse para anti-patrón visto.
- `.dockerignore` con entradas redundantes.
- Variable de entorno con nombre poco claro.

**Comportamiento del pipeline:**
- No bloquea, no tiene SLA.
- Se anota en `deliverables/` como sugerencia.

---

## Mapeo a OWASP Top 10 (2021)

Cuando un hallazgo es de seguridad, se etiqueta con la categoría OWASP correspondiente:

| OWASP | Nombre | Severidad típica en este framework |
|---|---|---|
| A01 | Broken Access Control | CRITICAL si explotable, HIGH si requiere auth |
| A02 | Cryptographic Failures | CRITICAL si datos en claro, HIGH si algoritmo débil |
| A03 | Injection | CRITICAL en endpoints públicos, HIGH si autenticado |
| A04 | Insecure Design | HIGH a MEDIUM según contexto |
| A05 | Security Misconfiguration | MEDIUM a HIGH según exposición |
| A06 | Vulnerable & Outdated Components | según CVSS de la dep concreta |
| A07 | Identification & Authentication Failures | CRITICAL si bypass, HIGH si MFA opcional donde debe ser obligatorio |
| A08 | Software & Data Integrity Failures | HIGH a CRITICAL según supply chain risk |
| A09 | Security Logging & Monitoring Failures | MEDIUM a HIGH (afecta detección) |
| A10 | Server-Side Request Forgery (SSRF) | HIGH a CRITICAL |

**Regla:** la severidad final es el **máximo** entre la categoría OWASP y la evaluación del agente auditor según contexto del proyecto (un mismo issue puede ser MEDIUM en startup tier y HIGH en corporate).

---

## Hallazgos no-security

Para hallazgos en otras dimensiones (architecture, data, ops, etc.), la severidad se determina por:
- **CRITICAL:** bloquea operación normal o causa pérdida irreversible.
- **HIGH:** degradación severa o blocker para SLA.
- **MEDIUM:** debt deseable de pagar pre-producción.
- **LOW:** mejora best-effort.

Ejemplos:
- "Backup nunca probado en tier corporate" → **CRITICAL** (data).
- "Migración no reversible" → **HIGH** (data).
- "Falta runbook de rollback ensayado" → **HIGH** (ops, en graduating).
- "ADR faltante para decisión grande" → **MEDIUM** (architecture).
- "Comentarios desactualizados" → **LOW** (docs).

---

## Cómo se reporta un hallazgo

Estructura mínima en `deliverables/<fase>.md`:

```markdown
### F-XYZ-001 — Título corto

- **Severidad:** CRITICAL
- **Dimensión:** Security (1.1 Secret management)
- **OWASP:** A02 Cryptographic Failures
- **Encontrado en:** Fase F3 · Security audit
- **Descripción:** OPENAI_API_KEY commiteado en commit a3f4c12 del 2026-03-15.
  Aunque se rotó, el secret estuvo expuesto 2h en repo privado.
- **Reproducción:** `git log --all -p | grep -i "sk-"` muestra el match.
- **Impacto:** rotación obligatoria; ventana de exposición a registrar.
- **Remediación:** rotar secret, agregar pre-commit hook, documentar incidente.
- **SLA:** inmediato (CRITICAL).
- **Dueño:** Juan Pérez.
- **Status:** open / in-progress / resolved / accepted-as-debt
- **Resolución:** [fecha + commit cuando aplique]
```

---

## Status de hallazgos

| Status | Significado |
|---|---|
| `open` | Detectado, sin asignación. |
| `in-progress` | Asignado, dueño trabajando. |
| `resolved` | Remediado y verificado por auditor. |
| `accepted-as-debt` | Solo para MEDIUM/LOW. Documentado, dueño firmó aceptación, deadline de revisión definido. |
| `false-positive` | Auditor confirma que no aplica al contexto del proyecto. |

CRITICAL **no puede** estar en `accepted-as-debt`. HIGH solo con plan de mitigación firmado.

---

## Anti-patrones

- **Re-clasificar a la baja sin justificación.** El auditor pone severidad; el builder puede objetar con argumentos de contexto, pero la decisión final queda registrada con razón.
- **Cerrar como "false-positive" sin verificación.** False positive requiere reproducción fallida documentada.
- **Aceptar HIGH como debt sin plan.** No es debt aceptado; es bloqueante de graduación.
- **Pasar CRITICAL a HIGH "porque ya rotamos".** El histórico de exposición sigue siendo CRITICAL hasta documentar el incidente.

---

## Referencias

- Pipeline (donde aparecen los hallazgos): `06-pipeline.md`
- Output artifacts (cómo se entregan): `09-output-artifacts.md`
- Dimensiones (cómo se mapean los hallazgos a sub-criterios): `05-audit-dimensions.md`
- OWASP Top 10 2021: https://owasp.org/Top10/
