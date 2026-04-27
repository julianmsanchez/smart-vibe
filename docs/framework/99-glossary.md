# 99 · Glosario

> Términos que aparecen recurrentemente en el Smart Vibe Framework, ordenados alfabéticamente. Si un concepto te confunde, busca acá primero.

---

### ADR (Architecture Decision Record)
Documento corto que registra una decisión arquitectónica, su contexto y sus consecuencias. Vive en `docs/decisions/000X-<slug>.md`. Una buena ADR responde: ¿qué se decidió? ¿por qué? ¿qué alternativas se descartaron? ¿qué cambia esta decisión?

### Addon
Módulo opcional que se agrega al proyecto del builder en el bootstrap. Aporta scaffolding específico (estructura, dependencias, configs). En `smart-vibe` v0.1.0 hay dos: `node-ts` (single-team con Express + TS + Vitest) y `workshop` (Turborepo multi-team). Los addons son **opt-in** y **no se mezclan**: un proyecto activa uno solo.

### Auditoría 0-5
Sistema de puntuación usado en modo `graduating`. Cada una de las **7 dimensiones** se evalúa contra **5 sub-criterios**, cada sub-criterio recibe un puntaje 0-5. El nivel de la dimensión es el promedio (o el mínimo, según política). Detalle en `05-audit-dimensions.md`. Solo `celeru-pro` ejecuta auditorías 0-5; en modo vibe los sub-criterios viven como referencia.

### Bootstrap
Acto de crear un proyecto nuevo desde cero usando `smart-vibe`. Se ejecuta con `bash scripts/bootstrap.sh` o `npx smart-vibe init`. Hace 4 preguntas (tipo, tier, vertical, addon) y genera el repo en modo `vibe`.

### Builder
La persona que usa `smart-vibe` para construir un prototipo. Sinónimo aceptable: **viber**. No confundir con "developer" en sentido tradicional — el builder vibea con IA, no necesariamente programa línea por línea.

### CeleruIA
Servicio comercial operado por Celeru SAS BIC que ofrece graduación a producción para proyectos en modo vibe. Es el operador de `celeru-pro`. URL: https://celeru.co/celeruia.

### celeru-pro
Distribución privada del Smart Vibe Framework. Implementa los modos `graduating` y `production`. NO se scaffoldea desde `smart-vibe`. Es el destino del signal `/smart-graduate`.

### Conventional Commits
Convención de mensajes de commit con prefijo de tipo (`feat:`, `fix:`, `docs:`, `chore:`, etc.). Es **obligatoria** en cualquier proyecto smart-vibe — sostiene Conventional Commits desde el bootstrap. Spec: https://www.conventionalcommits.org/.

### Decisión cerrada
Decisión documentada explícitamente (en PHS, ADR o commit message) y aceptada por el builder. Lo opuesto a "decisión implícita", que es deuda técnica.

### Dimensión
Una de las 7 categorías de auditoría: `security`, `architecture`, `code-quality`, `data`, `ops`, `docs`, `change-control`. Cada dimensión tiene una policy correspondiente. Detalle: `05-audit-dimensions.md`.

### Doctor
Script (`scripts/doctor.sh`) y comando del plugin (`/smart-doctor`) que valida el estado del proyecto. En modo vibe corre checks livianos (5 reglas + integridad PHS). Es **idempotente**: se puede correr cuantas veces se quiera.

### Graduating
Modo de transición de prototipo a producción. Activo cuando `phs.project.mode = "graduating"`. Lo opera `celeru-pro`.

### Landmine
Problema latente que no rompe ahora pero rompe en producción (secrets en repo, sin tests del happy path, sin observability, decisiones implícitas). El framework en modo vibe está diseñado para **prevenir landmines**, no para imponer disciplina enterprise.

### Modo
Uno de los 3 estados posibles de un proyecto: `vibe`, `graduating`, `production`. Se declara en `phs.project.mode`. Detalle: `02-modes.md`.

### Nivel (de madurez)
Uno de los 6 estados observables: L0 (chaos), L1 (vibe), L2 (disciplined vibe), L3 (graduating), L4 (production-ready), L5 (production-mature). Detalle: `01-maturity-model.md`.

### PHS (Prototype Handoff Spec)
Contrato YAML+Zod que vive en `phs.yaml` en la raíz del proyecto. Declara stack, vertical, tier, modo, addons activos, decisiones, etc. Es el **SSOT** (single source of truth) del proyecto. En modo vibe permite campos vacíos; en graduating exige completitud. Schema canónico en `core/phs/schema.yaml`.

### Pipeline (de graduación)
Secuencia de 7 fases con quality gates entre fases que `celeru-pro` ejecuta cuando un proyecto entra a modo `graduating`. Cada fase aborda una dimensión. Detalle: `06-pipeline.md`.

### Plugin (Claude Code)
Conjunto de comandos `/smart-*` instalables en Claude Code que el builder usa día a día. Vive en `plugin/` del repo `smart-vibe`. Comandos principales: `/smart-bootstrap`, `/smart-phs`, `/smart-doctor`, `/smart-policy`, `/smart-graduate`, `/smart-workshop`.

### Policy
Documento que define principios + checklist de una dimensión. Hay 7 policies (una por dimensión). En modo vibe se entregan como **policies en modo vibe** (principios + checklist liviano, sin gates). En modo graduating, las policies se vuelven gates de auditoría.

### Production
Modo de operación con SLA activo. `phs.project.mode = "production"`. Lo opera `celeru-pro`. No se llega por bootstrap — solo por graduación exitosa.

### Quality gate
Check obligatorio entre fases del pipeline de graduación. Si falla, no se avanza a la siguiente fase. Existen solo en modos `graduating` y `production`.

### Risk taxonomy
Clasificación de issues en 4 niveles: `CRITICAL`, `HIGH`, `MEDIUM`, `LOW`. Mapeada a OWASP cuando aplica. Detalle: `08-risk-taxonomy.md`.

### RPO (Recovery Point Objective)
Cantidad máxima de datos (medida en tiempo) que se aceptaría perder en un incidente de DR. Ej: RPO = 1h significa "se aceptan hasta 60 minutos de datos perdidos". Se declara en SLA (modo production).

### RTO (Recovery Time Objective)
Tiempo máximo aceptable de indisponibilidad después de un incidente antes de restaurar el servicio. Ej: RTO = 4h significa "después de un incidente, el servicio debe volver en ≤4 horas". Se declara en SLA (modo production).

### Runbook
Documento operativo que describe cómo responder a una situación específica (deploy, rollback, incidente, recovery). En modo `graduating` se exige al menos un runbook ensayado. En `production`, runbooks vivos son obligatorios.

### Shell (en workshop)
La app Next.js raíz del addon `workshop` que monta a cada team en una sub-ruta `/{team_id}`. Es el orquestador de UI compartida en hackathons multi-team.

### SLA (Service Level Agreement)
Acuerdo formal sobre niveles de servicio: uptime objetivo, RTO, RPO, ventanas de mantenimiento. Solo aplica en modo `production`.

### SLO (Service Level Objective)
Objetivo numérico interno (ej: "99.5% uptime mensual") que sostiene un SLA. SLOs sin SLA son válidos en `graduating`; SLAs sin SLOs medibles son humo.

### smart-vibe
Este repo. Distribución pública (MIT) del Smart Vibe Framework. Implementa el modo `vibe`.

### Smart Vibe Framework
La metodología. Vive en `docs/framework/` de este repo. Es la fuente de verdad metodológica. Implementada por `smart-vibe` (vibe) + `celeru-pro` (graduating, production).

### SSOT (Single Source of Truth)
Documento o archivo que es la única fuente autorizada para una clase de información. En `smart-vibe` hay dos SSOTs: `phs.yaml` (a nivel proyecto) y `workshop.yaml` (a nivel monorepo, solo addon `workshop`).

### Tier
Categoría comercial proyectada del proyecto. En el bootstrap se elige entre `startup` (<50K usuarios, sin compliance estricto) y `corporate` (regulado, alta disponibilidad). Configura defaults; no inhabilita comportamiento.

### Vertical
Industria o dominio del proyecto. En el bootstrap se elige entre `fintech`, `salud`, `general`, `retail`, `edu`, `gobierno`, `telecom`, `otro`. Algunas verticales activan addons de compliance por default.

### Vibe
Modo inicial de cualquier proyecto. Foco en velocidad, bases mínimas. `phs.project.mode = "vibe"`. Lo opera `smart-vibe`.

### Viber
Sinónimo de **builder**. Persona que vibea código con IA.

### Workshop
Tipo de proyecto multi-team con UI común (ideal para hackathons o squads paralelos). Implementado con Turborepo + pnpm workspaces. Cada team vive en `apps/<team>/`. Comparten `packages/` cross-cutting (design-system, types, auth, api-contracts, config, infra-contracts, fixtures). Tiene su propio SSOT cross-cutting: `workshop.yaml`.

### workshop.yaml
SSOT cross-cutting a nivel monorepo (sólo en addon `workshop`). Declara teams, infra compartida (APIs externas, DBs, storage), UI compartida, secrets, observability, versioning, CI/CD. Schema en `core/workshop-spec/schema.yaml`. Hermano del PHS (que es a nivel proyecto/app).

---

## Términos que NO usamos (y por qué)

- **"Production-ready" como sustantivo:** preferimos hablar de **L4** (preciso, medible). "Production-ready" se usa solo como adjetivo descriptivo.
- **"MVP":** ambiguo. Hablamos de **modo vibe** (cualitativo) y **L1/L2** (medible).
- **"Sprint" / "story points":** smart-vibe no asume metodología ágil específica. El builder usa lo que prefiera.
- **"Best practices":** preferimos citar el principio o la dimensión que lo justifica.
