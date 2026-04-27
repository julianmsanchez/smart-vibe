# 06 · Pipeline de 7 Fases

> El **pipeline de graduación** es la secuencia de 7 fases con quality gates que un proyecto recorre cuando entra a modo `graduating`. Cada fase se enfoca en una dimensión y termina con un gate explícito. Si una fase no pasa su gate, no se avanza.

> **smart-vibe (este toolkit) NO ejecuta el pipeline.** Solo lo documenta. Lo opera **`celeru-pro`** (privado, comercial). En modo vibe, las fases existen como referencia para que el builder sepa qué viene cuando decida graduar.

---

## Visión general

```
[ vibe / L1-L2 ]
       │
       │  /smart-graduate (en celeru-pro)
       ▼
┌────────────────────────────────────────────┐
│  F1 · Discovery & PHS validation           │
│  F2 · Architecture review                  │
│  F3 · Security & compliance audit          │
│  F4 · Data & ops hardening                 │
│  F5 · Code quality & test coverage         │
│  F6 · Operational readiness                │
│  F7 · Handoff & deliverables               │
└──────────┬─────────────────────────────────┘
           │
           ▼
[ production / L4 ]
```

Cada fase produce un **output** (registro auditable) y se cierra con un **quality gate**. El gate consulta los sub-criterios de la dimensión correspondiente (ver `05-audit-dimensions.md`) y exige que el mínimo sea ≥4.

Pueden correrse fases **en paralelo** cuando son independientes (ej: F2 y F3), pero las dependencies se respetan estrictamente (F7 requiere las 6 anteriores cerradas).

---

## Fase 1 · Discovery & PHS validation

**Foco:** entender qué es el proyecto y validar que el PHS está completo.

### Inputs
- `phs.yaml` del proyecto.
- `workshop.yaml` (si type=workshop).
- Estado actual del repo (commits, archivos, dependencias).

### Actividades
- Validar PHS contra schema (Zod). Reportar campos vacíos críticos.
- Confirmar `project.mode` con el builder (declarar la intención).
- Catalogar stack actual, dependencias, infra existente.
- Detectar inconsistencias evidentes (ej: PHS dice `data.primary_db: postgres` pero no hay client en deps).

### Output
- `deliverables/01-discovery.md` — resumen del proyecto, gaps detectados.
- PHS actualizado (si fue necesario).

### Quality gate
- PHS pasa validación strict (no campos críticos vacíos).
- `project.mode` declarado y confirmado como `graduating`.
- Inventario de stack/infra completo.

**Si falla:** vuelve al builder con lista priorizada de campos a completar.

---

## Fase 2 · Architecture review

**Foco:** dimensión 2 (Architecture). Confirmar que la estructura sostiene los requisitos.

### Inputs
- Output de F1.
- Código fuente.
- ADRs existentes en `docs/decisions/`.

### Actividades
- Mapeo de capas y módulos.
- Detección de coupling/cohesion problems.
- Análisis del path de escalabilidad implícito.
- Auditoría de las ADRs presentes vs decisiones realmente tomadas.
- Generación de ADRs faltantes (con confirmación del builder) para decisiones que solo existen en código.

### Output
- `deliverables/02-architecture.md` — reporte 0-5 por sub-criterio.
- ADRs nuevas (si hizo falta) en `docs/decisions/`.

### Quality gate
- Sub-criterios 2.1–2.5 todos en ≥4.
- Todas las decisiones grandes (data, hosting, auth, deployment, observability) tienen ADR.

---

## Fase 3 · Security & compliance audit

**Foco:** dimensión 1 (Security) + compliance frameworks declarados en PHS.

### Inputs
- Output de F1, F2.
- `phs.compliance.frameworks` (PCI-DSS, HIPAA, SOC2, GDPR, etc.).
- `vertical` y `tier` del PHS.

### Actividades
- SCA (software composition analysis) — vulnerabilidades CRITICAL/HIGH.
- DAST/SAST básico según stack.
- Review de auth/authz.
- Audit de secret management.
- Compliance checklist según frameworks declarados.
- Pen-test ligero en endpoints críticos (lo opera celeru-pro con agentes especializados).

### Output
- `deliverables/03-security.md` — reporte con findings clasificados (ver `08-risk-taxonomy.md`).
- Lista de remediation items priorizada.

### Quality gate
- 0 findings **CRITICAL** abiertos.
- Sub-criterios 1.1–1.5 todos en ≥4.
- Compliance frameworks declarados pasan checklist.

**Si falla con CRITICAL:** la graduación se bloquea hasta remediar. CRITICAL no se promete-se-arregla-después.

---

## Fase 4 · Data & ops hardening

**Foco:** dimensiones 4 (Data) y 5 (Operations).

### Inputs
- Output de F1, F2, F3.
- Schemas de DB (si aplica).
- Configuración de logging, monitoring, alerting.
- Configuración de deployment.

### Actividades
- **Data:**
  - Validar migraciones reversibles.
  - Probar backup + restore al menos una vez.
  - Clasificar PII y validar retention policies.
- **Ops:**
  - Configurar logger estructurado con correlation IDs.
  - Definir SLOs y alertas.
  - Validar deployment automatizado (CI/CD).
  - Documentar y ensayar rollback.

### Output
- `deliverables/04-data-ops.md` — reportes 0-5 de ambas dimensiones.
- Runbook de backup/restore probado.
- Runbook de rollback probado.

### Quality gate
- Sub-criterios 4.1–4.5 todos en ≥4.
- Sub-criterios 5.1–5.5 todos en ≥4.
- Backup + restore ensayado y registrado.
- Rollback ensayado y registrado.

---

## Fase 5 · Code quality & test coverage

**Foco:** dimensión 3 (Code Quality).

### Inputs
- Código fuente completo.
- Tests existentes.
- Linter/formatter config.

### Actividades
- Linter en CI como blocker.
- Cobertura de tests medida (target: ≥80% en lógica de negocio).
- Tipo strict (TS) o equivalente.
- Detección de dead code.
- Refactor priorizado de hot spots de complejidad.

### Output
- `deliverables/05-code-quality.md` — reporte 0-5.
- PRs de remediación cuando hay refactors necesarios.

### Quality gate
- Sub-criterios 3.1–3.5 todos en ≥4.
- Linter verde en CI como blocker.
- Cobertura ≥80% en lógica de negocio (configurable por proyecto).

---

## Fase 6 · Operational readiness

**Foco:** dimensión 6 (Documentation) + ensayo final de operación.

### Inputs
- Outputs de F1–F5.
- Runbooks generados en F4.

### Actividades
- README, CLAUDE.md, ADRs revisados y actualizados.
- API docs generadas (OpenAPI o equivalente).
- Runbooks por incidente común (no solo deploy/backup):
  - Performance degradation.
  - Auth provider down.
  - Data corruption.
  - DDoS / rate limit hit.
- Game day: ensayo de incidente con el equipo operativo.
- SLA / SLO firmados (si aplica).

### Output
- `deliverables/06-ops-readiness.md` — checklist completa.
- Runbooks finales en `docs/runbooks/`.
- SLA/SLO documentados (si aplica) en `docs/sla.md`.

### Quality gate
- Sub-criterios 6.1–6.5 todos en ≥4.
- Game day ejecutado al menos una vez con resultado registrado.
- SLA/SLO firmados (si tier corresponde).

---

## Fase 7 · Handoff & deliverables

**Foco:** dimensión 7 (Change Control) + entrega final.

### Inputs
- Outputs de F1–F6.
- Registro completo en `deliverables/`.

### Actividades
- Validar Conventional Commits + branching strategy desde el inicio del pipeline.
- CHANGELOG generado y actualizado.
- Tag de versión `vX.Y.Z` (SemVer).
- Generación del **handoff package**: documento ejecutivo que resume estado del proyecto, riesgos residuales, plan de monitoreo en producción.
- Cambio explícito de `project.mode` a `production` en PHS.
- Activación de re-audits periódicas (calendario en `celeru-pro`).

### Output
- `deliverables/07-handoff.md` — documento ejecutivo.
- `CHANGELOG.md` actualizado.
- Tag `vX.Y.Z`.
- PHS con `mode: production`.
- Calendario de re-audits configurado.

### Quality gate
- Sub-criterios 7.1–7.5 todos en ≥4.
- `deliverables/` contiene 01–07 completos.
- Tag de release creado.
- `mode: production` declarado y validado.

---

## Quality gates: comportamiento

### Pasar gate
La fase cierra. Se avanza a la siguiente.

### Fallar gate
- **Si el delta es chico:** plan de remediación con dueño y deadline. La fase queda *en remediación*, no abierta. Cuando se cierra el plan, se re-evalúa el gate.
- **Si el delta es grande:** la fase se reabre completa. El proyecto vuelve al builder con plan priorizado.
- **Si hay un CRITICAL en F3:** la graduación se **bloquea** hasta remediar. No hay workaround.

### Saltar gate
**No existe.** Saltarse un gate viola principio 1 (modos como ciudadanos de primera) y vuelve a `vibe → production` directo, que es exactamente lo que el framework previene.

---

## ¿Por qué 7 fases y no menos / más?

El plan v2 (`SMART_VIBE_PLAN_V2.md`) llegó a 7 después de iterar:
- **Menos de 7** colapsa dimensiones que tienen tooling, agentes y trade-offs distintos (ej: security ≠ data).
- **Más de 7** subdivide dimensiones sin payoff (ej: separar "auth" de "input validation" como fases distintas las hace operativamente confusas).

Las 7 fases mapean 1-a-1 a las 7 dimensiones (con F1 y F7 cubriendo trazabilidad cross-fase).

---

## Workshop y pipeline

En workshops, el pipeline corre con `/smart-workshop graduate-all` (lo opera `celeru-pro`). Se gradúan todos los teams al mismo tiempo, pero cada team tiene su propia auditoría.

- F1 corre **una vez** a nivel monorepo (valida `workshop.yaml` + N PHS de teams).
- F2–F6 corren **por team en paralelo**, con auditoría individual.
- F7 produce **un handoff package por team** + uno consolidado del workshop.

Detalle en `10-workshop-mode.md`.

---

## Referencias

- Dimensiones y sub-criterios: `05-audit-dimensions.md`
- Risk taxonomy (CRITICAL/HIGH/MEDIUM/LOW): `08-risk-taxonomy.md`
- Output artifacts esperados: `09-output-artifacts.md`
- Modelo de madurez: `01-maturity-model.md`
- Modos: `02-modes.md`
