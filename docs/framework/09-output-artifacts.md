# 09 · Output Artifacts (`deliverables/`)

> El pipeline de graduación produce artefactos auditables. Todos viven en `deliverables/` en el repo del builder. Este doc define **qué archivos** produce cada fase, **qué contienen** y **cómo se versionan**.

> Estos artefactos los **genera `celeru-pro`** durante el pipeline. `smart-vibe` solo los documenta. En modo vibe no existen — empiezan a existir cuando el proyecto entra a `graduating`.

---

## Estructura final de `deliverables/`

```
mi-proyecto/
└── deliverables/
    ├── README.md                 # índice + estado actual del pipeline
    ├── 01-discovery.md           # Fase 1
    ├── 02-architecture.md        # Fase 2
    ├── 03-security.md            # Fase 3
    ├── 04-data-ops.md            # Fase 4
    ├── 05-code-quality.md        # Fase 5
    ├── 06-ops-readiness.md       # Fase 6
    ├── 07-handoff.md             # Fase 7 (documento ejecutivo)
    │
    ├── audit-scores.yaml         # 7 dimensiones × 5 sub-criterios × 0-5
    ├── findings.yaml             # todos los hallazgos del pipeline
    │
    ├── runbooks/                 # generados o validados durante pipeline
    │   ├── deploy.md
    │   ├── rollback.md
    │   ├── backup-restore.md
    │   ├── incident-auth-down.md
    │   └── ...
    │
    └── attachments/              # outputs de herramientas (logs, reports)
        ├── sca-report-2026-04-27.json
        ├── coverage-2026-04-27.json
        └── ...
```

---

## Convenciones generales

### Versionado
- Todo `deliverables/` está bajo git, commiteado por `celeru-pro` con commits Conventional (`audit:`, `feat:`, etc.).
- Cada archivo lleva fecha en encabezado y registro de re-runs cuando aplica.

### Idempotencia
- Re-correr una fase **actualiza** el archivo correspondiente, no crea uno nuevo.
- El historial está en git.

### Inmutabilidad post-graduación
- Una vez tagueada `vX.Y.Z` con `mode: production`, los archivos de `deliverables/` se vuelven **read-only** salvo en re-audits explícitas. Modificarlos requiere ADR + bump de versión.

---

## `01-discovery.md`

**Producido por:** Fase 1 (Discovery & PHS validation).

**Contenido:**
- Resumen del proyecto extraído del PHS.
- Inventario de stack, dependencias, infra existente.
- Lista de gaps detectados (PHS incompleto, decisiones implícitas).
- Estado inicial: módulos, líneas de código, tests existentes.

**Plantilla:**
```markdown
# 01 · Discovery — mi-proyecto

- **Fecha:** 2026-04-27
- **Modo declarado:** graduating
- **Auditor:** celeru-pro v0.x

## Resumen
Una línea sobre qué hace el proyecto.

## Stack inventoriado
- Lenguaje: TypeScript 5.x
- Runtime: Node 20
- Framework: Express
- DB: Postgres (Supabase managed)
- Auth: Supabase Auth
- Hosting: Vercel + Supabase

## PHS gaps
- `infra.region` vacío.
- `sla.uptime_target` vacío (esperado si tier=startup).
- 0 ADRs en `docs/decisions/`.

## Inventario de código
- 12,500 LOC, 87 archivos TS.
- Cobertura tests: 42%.
- Linter: ESLint configurado, 0 errores.

## Conclusión
Listo para Fase 2. Bloqueantes: 0.
```

---

## `02-architecture.md`

**Producido por:** Fase 2.

**Contenido:**
- Reporte 0-5 por sub-criterio de dimensión 2 (Architecture).
- Mapeo de capas y módulos.
- ADRs presentes y faltantes (con propuesta de las nuevas).
- Findings clasificados.

**Sección clave:**
```markdown
## Score 0-5

| Sub-criterio | Score | Notas |
|---|---|---|
| 2.1 Separation of concerns | 4 | Capas claras, no circular imports |
| 2.2 Coupling & cohesion | 3 | `services/` tiene módulos demasiado grandes |
| 2.3 Scalability path | 4 | Serverless cubre carga proyectada |
| 2.4 Error handling | 2 | Errores propagados sin contexto |
| 2.5 ADRs cubiertas | 1 | Solo 1 ADR escrita; faltan 4 grandes |

## Quality gate
**FAIL** — sub-criterios 2.4 y 2.5 en <4. Plan de remediación abajo.
```

---

## `03-security.md`

**Producido por:** Fase 3.

**Contenido:**
- Reporte 0-5 de dimensión 1 (Security).
- Findings clasificados (CRITICAL/HIGH/MEDIUM/LOW) — ver `08-risk-taxonomy.md`.
- Compliance checklist según frameworks declarados.
- Output de SCA, SAST, DAST.

**CRITICAL findings se listan al tope** con bloque rojo:
```markdown
## ⛔ CRITICAL findings

### F3-SEC-001 — Secret commiteado en historia
- ... (ver formato en `08-risk-taxonomy.md`)
```

---

## `04-data-ops.md`

**Producido por:** Fase 4.

**Contenido:**
- Reportes 0-5 de dimensiones 4 (Data) y 5 (Ops).
- Validación de migraciones reversibles.
- **Registro de backup + restore ensayado** (timestamp, datos restaurados, RTO real).
- **Registro de rollback ensayado** (timestamp, versión rolleada, tiempo total).
- Logger config validada.
- SLO/alertas definidas.

---

## `05-code-quality.md`

**Producido por:** Fase 5.

**Contenido:**
- Reporte 0-5 de dimensión 3.
- Cobertura de tests por módulo.
- Output del linter (en CI como blocker).
- Métricas de complejidad ciclomática.
- Lista de refactors recomendados (con priority).

---

## `06-ops-readiness.md`

**Producido por:** Fase 6.

**Contenido:**
- Reporte 0-5 de dimensión 6 (Documentation).
- Lista de runbooks generados/validados.
- **Game day report:** ensayo de incidente con resultado.
- SLA/SLO firmados (si tier corresponde).
- Calendario de re-audits propuesto.

---

## `07-handoff.md`

**Producido por:** Fase 7. Es el **documento ejecutivo**.

**Contenido:**
- Resumen del proyecto: qué hace, stack, infra.
- Estado de las 7 dimensiones (tabla resumen).
- Lista de **riesgos residuales aceptados** (MEDIUM/LOW como debt).
- Plan de monitoreo en producción.
- Calendario de re-audits.
- Equipo operativo y owners.
- Tag de release y CHANGELOG.

**Plantilla:**
```markdown
# 07 · Handoff Package — mi-proyecto vX.Y.Z

- **Fecha de handoff:** 2026-04-27
- **Tag:** v1.0.0
- **Modo:** production
- **Tier:** startup

## Resumen ejecutivo
Una línea sobre qué hace.

## Estado por dimensión

| Dimensión | Score promedio | Mínimo | Status |
|---|---|---|---|
| 1. Security | 4.4 | 4 | ✅ |
| 2. Architecture | 4.2 | 4 | ✅ |
| ... | | | |

## Riesgos residuales
- F2-002 (MEDIUM): refactor de `services/orders.ts` pendiente. Dueño: Juan. Target: 60d post-handoff.
- ...

## Plan de monitoreo
- Alertas configuradas: uptime, latencia p95, error rate.
- Re-audit calendar: trimestral (Q3 2026, Q4 2026, Q1 2027).
- Game day periodicidad: semestral.

## Equipo operativo
- On-call: Ana, Pedro.
- Owner runbooks: Ana.
- Release manager: Pedro.
```

---

## `audit-scores.yaml`

Archivo machine-readable con scores 0-5 por sub-criterio, generado al final del pipeline.

```yaml
audit:
  date: 2026-04-27
  version: v1.0.0
  mode_target: production
  scores:
    security:
      "1.1_secret_management": 5
      "1.2_authn_authz": 4
      "1.3_input_validation": 4
      "1.4_dependency_security": 4
      "1.5_logs_pii": 5
    architecture:
      "2.1_separation_of_concerns": 4
      ...
```

Lo consume:
- `celeru-pro` para regression detection en re-audits.
- `doctor.sh` para reportar nivel.
- Dashboards de portfolio (multi-proyecto) que tenga el operador.

---

## `findings.yaml`

Archivo machine-readable con todos los hallazgos del pipeline, en estructura de `08-risk-taxonomy.md`.

```yaml
findings:
  - id: F3-SEC-001
    severity: CRITICAL
    dimension: security
    sub_criterion: "1.1"
    owasp: A02
    title: "Secret commiteado en historia"
    found_in_phase: F3
    status: resolved
    owner: juan
    resolution_commit: a8b3c4d
    resolution_date: 2026-04-22
  - id: F2-ARCH-005
    severity: MEDIUM
    ...
```

---

## `runbooks/`

Carpeta con runbooks operativos. Mínimo en L4:

- `deploy.md` — cómo desplegar.
- `rollback.md` — cómo rollbackear.
- `backup-restore.md` — cómo restaurar.
- `incident-<scenario>.md` — uno por incidente común identificado en F6.

Cada runbook tiene:
- Prerequisitos.
- Pasos numerados con comandos exactos.
- Validación post-ejecución.
- Troubleshooting si falla.
- Última fecha de ensayo + resultado.

---

## `attachments/`

Outputs raw de herramientas (no son lectura humana, son evidencia auditable):
- `sca-report-<date>.json`
- `sast-report-<date>.html`
- `coverage-<date>.json`
- `pen-test-summary-<date>.pdf` (si aplica)
- ...

---

## Re-audits y diff

En `production`, re-audits periódicas generan **diff contra el handoff baseline**. Si una dimensión cae <4, la re-audit produce un nuevo `0X-<phase>-rerun-<date>.md` y el proyecto regresa a `graduating`.

---

## Referencias

- Pipeline: `06-pipeline.md`
- Risk taxonomy: `08-risk-taxonomy.md`
- Dimensiones: `05-audit-dimensions.md`
