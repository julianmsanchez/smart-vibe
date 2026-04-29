# Changelog

Todos los cambios notables de `smart-vibe` se documentan acá.

Formato basado en [Keep a Changelog](https://keepachangelog.com/es/1.1.0/).
Versionado [SemVer](https://semver.org/lang/es/).

## [Unreleased]

### Added
- `chore(scripts)` — `scripts/check-docs.sh` + `scripts/install-hooks.sh` + `.github/workflows/check-docs.yml`. Enforcer de la "Regla de documentación viva": commits `feat`/`fix` que tocan paths user-facing (`scripts/`, `addons/`, `plugin/`, `core/{phs,workshop-spec,policies,templates}/`, `docs/framework/`) deben actualizar `CHANGELOG.md` en el mismo commit. Local vía `commit-msg` hook (opt-in con `bash scripts/install-hooks.sh`); CI vía workflow en PRs. Escape hatch: `SKIP_DOCS_CHECK=1`.

---

## [0.1.5] — 2026-04-28

### Added
- `feat(graduate)` — `/smart-graduate` redesign como diagnóstico read-only con 3 categorías (crítico / recomendado / inventario). Sin umbrales arbitrarios; reporta hechos. Genera `docs/graduate-handoff.md` para consumir en celeru-pro.
- `scripts/graduate.sh` — companion bash script con 7 critical checks + 7 recommended + 9 inventory metrics. Embebido en bootstrap (single-team + workshop).
- `CHANGELOG.md` raíz (Keep a Changelog en español).
- `docs/PHASES.md` — resumen de Fase 1 (entregada) / Fase 2 (pendiente) / Fase 3 (lejano) + scope out-of-scope (celeru-pro).

### Changed
- `CLAUDE.md` raíz: sección "Planes operativos" ahora referencia explícitamente `~/.claude/plans/hazy-sniffing-hearth.md` y `parsed-chasing-boole.md`, y apunta a `docs/PHASES.md` como referencia rápida.

### Fixed
- `fix(scripts)` — bootstrap corre `sync-env.sh` post-workshop para evitar drift entre `.env.shared.example` y `workshop.yaml` en el primer commit.

---

## [0.1.4] — 2026-04-28

### Added
- `feat(scripts)` — `scripts/sync-env.sh` auto-sync `.env.*.example` desde `workshop.yaml`. Cierra el TODO de v0.1.2 (mapeo manual `apis_external[].access` → archivos env). Soporta `--check` para CI.
- `feat(bootstrap)` — wizard de requirements opcional para single-team (módulos, problema, KPIs).
- `feat(bootstrap)` — pre-poblar `wiki/PRD.md §3` con módulos del wizard + next-steps con `/smart-graduate`.
- `feat(bootstrap)` — seed `docs/{decisions,playbooks}` + ADR template + `phs.yaml.decisions[]` hint.

### Changed
- `feat(scripts)` — bootstrap render coverage: placeholders, spec URL, tier explícito en `phs.yaml`.
- `refactor(scripts)` — `doctor.sh` single-source: se copia en runtime (no se duplica en addons).

---

## [0.1.2] — 2026-04-27

### Added
- `feat(addon-workshop)` — modelo env **two-layer**: globales en `.env.shared.example` (commiteado, raíz), team-specific en `apps/<team>/.env.local.example` (commiteado, por team). Mapeo declarativo desde `workshop.yaml.shared_infra.apis_external[].access`.
- `feat(addon-workshop)` — `ORGANIZER-CHECKLIST.md.tmpl` con 4 pasos (~5–10 min) para orientar al organizer post-bootstrap.
- `feat(addon-workshop)` — `README.md.tmpl` workshop-aware (reemplaza al heredoc genérico single-team-style).
- `feat(addon-workshop)` — `apps/_team-template/.env.local.example` con comentario placeholder.
- `feat(scripts)` — 6 nuevos warns en `doctor.sh` para workshop.yaml campos vacíos + presencia de archivos env.
- `feat(wiki-skeleton)` — `wiki/PRD.md.tmpl` plantilla sugerida para vibe coders.
- `docs(quickstart)` — sección "Antes de empezar" con cwd esperado por escenario (A/B/C).
- `feat(addon-workshop)` — `join.sh` embebido en bootstrap, copia automática + edición de placeholders en team-CLAUDE.md.
- `feat(scripts)` — `install.sh` wrapper para distribución vía `curl ... | bash`.

### Changed
- `fix(scripts)` — bootstrap workshop-aware: borra README addon-interno, guard para no pisar templates renderizados, render `{{TEAMS_LIST}}` en checklist, next-steps específicos por TYPE, copia template `.env.local.example` a cada team.
- `fix(addon-workshop)` — `join.sh` `yq_get` acepta expresiones python multi-línea (sets, generators).
- `fix(addon-workshop)` — `join.sh` crea `apps/<team>/.env.local` además de `.env.shared`; next-steps lista vars globales y team-specific por separado.
- `docs` — `secrets-strategy.md` con sección "Modelo two-layer"; `QUICKSTART.md` delega al checklist + nota two-layer; `team-onboarding.md` menciona los dos archivos `.env`.
- `core/gitignore.tmpl` agrega `apps/*/.env.local`.
- `fix(addon-workshop)` — `doctor.sh` ship embebido en el monorepo (single source en runtime).

### Fixed
- `fix(scripts)` — `install.sh` acepta `bash >=3.2` (default macOS).
- `fix(addon-workshop, addon-node-ts)` — gaps encontrados por E2E user-distribution.

---

## [0.1.0] — 2026-04-26

Primera release pública. MVP del **Smart Vibe Framework** — distribución OSS (MIT) que implementa el modo `vibe`.

### Added — Foundations
- `chore` — repo init + `LICENSE` (MIT) + `.gitignore` + empty README.
- `docs(README)` — pitch + diagrama del trinomio (framework / smart-vibe / celeru-pro) + 3 pasos.
- `docs(CLAUDE.md)` — orientación para agentes que trabajen en este repo.

### Added — Framework spec (12 archivos `docs/framework/`)
- `00-principles.md` — 5 axiomas.
- `01-maturity-model.md` — niveles L0-L5.
- `02-modes.md` — `vibe` / `graduating` / `production`.
- `03-phs-spec.md` — schema PHS + reglas de validación.
- `04-golden-rules.md` — 5 reglas que aplican en modo vibe.
- `05-audit-dimensions.md` — 7 dimensiones × 5 sub-criterios × 0-5.
- `06-pipeline.md` — 7 fases con quality gates.
- `07-architecture-decisions.md`.
- `08-risk-taxonomy.md` — CRITICAL/HIGH/MEDIUM/LOW + OWASP.
- `09-output-artifacts.md` — `deliverables/`.
- `10-workshop-mode.md`.
- `99-glossary.md`.

### Added — ADRs (`docs/decisions/`)
- 0001 monorepo structure.
- 0002 PHS as SSOT.
- 0003 vibe mode only in smart-vibe.
- 0004 7 policies = 7 dimensions.
- 0005 conventional commits mandatory.
- 0006 two distributions.
- 0007 modes as first-class.

### Added — Templates de proyecto (`core/`)
- `core/templates/CLAUDE.md.tmpl` — destilado de Parcher con filtro grep.
- `core/wiki-skeleton/` — Home, ROADMAP, RESUME + templates de session_summaries, implementation_logs, features, teleport.
- `core/claude/settings.json.tmpl` + `settings.local.json.tmpl`.
- `core/git-branching.md`.
- `core/policies/` — README + 7 archivos numerados (uno por dimensión).
- `core/gitignore.tmpl`.

### Added — Specs (los dos SSOT del framework)
- `core/phs/` — Prototype Handoff Spec: schema YAML + Zod, 3 ejemplos (startup, corporate, workshop), validation-rules, README.
- `core/workshop-spec/` — workshop.yaml: schema YAML + Zod, ejemplo hackathon, validation-rules, README.

### Added — Addon `node-ts` (single-team)
- Node 20 + Express + TypeScript + Vitest.
- Logger con AsyncLocalStorage, env-loader con validación al startup.
- Observability: Prometheus + Grafana starter dashboard.
- CI/CD: GitHub Actions templates (CI + Deploy AWS comentado por defecto).
- `manage-server.sh` con PID file + log centralizado.

### Added — Addon `workshop` (multi-team Turborepo)
- Shell Next.js + 7 packages compartidos: `design-system`, `types`, `auth`, `api-contracts`, `config`, `infra-contracts`, `fixtures`.
- 11 docs cross-cutting en `docs/workshop/`: integration-contract, secrets-strategy, data-strategy, ui-shared, observability, versioning, local-dev, deployment, team-communication, team-onboarding, shared-design-tokens.
- Workflows CI + integration-check.
- `CODEOWNERS.tmpl`.

### Added — Plugin Claude Code
- `plugin.json` + 7 commands: `/smart-bootstrap`, `/smart-phs`, `/smart-feature`, `/smart-summary`, `/smart-teleport`, `/smart-workshop`, `/smart-graduate`.
- 3 agents: `architect`, `doc-writer`, `phs-helper`.

### Added — Playbooks (top 5 builder-friendly)
- `01-hardcoded-secrets`, `02-weak-auth`, `03-no-tests`, `04-no-readme`, `05-no-env-example`.

### Added — Scripts
- `scripts/bootstrap.sh` — CLI interactivo con 4 preguntas (tipo, tier, vertical, addon). Soporta workshop con `--teams`. Equivalente: `npx smart-vibe init`.
- `scripts/doctor.sh` — validación estructural + subcomandos `phs validate <path>` y `workshop validate <path>`.

### Fixed
- `fix(scripts,wiki)` — E2E bootstrap + doctor pass en single-team y workshop.

---

[Unreleased]: https://github.com/julianmsanchez/smart-vibe/compare/v0.1.5...HEAD
[0.1.5]: https://github.com/julianmsanchez/smart-vibe/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/julianmsanchez/smart-vibe/compare/v0.1.2...v0.1.4
[0.1.2]: https://github.com/julianmsanchez/smart-vibe/compare/v0.1.0...v0.1.2
[0.1.0]: https://github.com/julianmsanchez/smart-vibe/releases/tag/v0.1.0
