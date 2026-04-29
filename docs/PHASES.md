# Fases del proyecto smart-vibe

> Fuente: destilado de `~/.claude/plans/hazy-sniffing-hearth.md` (plan maestro v2) + estado real verificado contra el repo.
> Última actualización: 2026-04-29.

## Resumen ejecutivo

| Fase | Objetivo | Estado | Tag |
|---|---|---|---|
| 1 | MVP OSS — modo `vibe` listo en <30 min | ✅ completa | v0.1.5 |
| 2 | Agentes nuevos + hooks + slash commands de workflow | ✅ completa | v0.2.0 |
| 3 | Multi-stack + EN + marketplace | 🔴 lejano | v1.x |

---

## Fase 1 — MVP v0.1.0 (✅ completa, superada hasta v0.1.5)

**Objetivo:** builder externo corre `bash scripts/bootstrap.sh` y obtiene proyecto en modo `vibe` listo en <30 min.

**Definition of Done v0.1.0:** 20 checks (estructura, schemas, bootstrap E2E, plugin, doctor). Detalle en `~/.claude/plans/hazy-sniffing-hearth.md § Verificación`.

### 10 bloques (A–J)

- **A — Foundations:** repo init, LICENSE MIT, README, CLAUDE.md, primeros 4 docs framework + 3 ADRs.
- **B — Framework spec completo:** los 12 archivos `docs/framework/` (00-principles → 99-glossary) + 4 ADRs restantes.
- **C — Templates de proyecto:** `core/templates/CLAUDE.md.tmpl`, `core/wiki-skeleton/`, `core/claude/settings*.tmpl`, `core/policies/` (7 dimensiones), `core/gitignore.tmpl`.
- **D — PHS + Workshop spec:** schemas YAML+Zod en `core/phs/` y `core/workshop-spec/`, ejemplos, validation-rules.
- **E — Addon node-ts:** Node 20 + Express + TS + Vitest + observability (Prometheus/Grafana) + CI/Deploy AWS workflows. Extraído de Parcher con filtro grep.
- **F — Addon workshop:** Turborepo + Next.js shell + 7 packages (design-system, types, auth, api-contracts, config, infra-contracts, fixtures) + 11 docs cross-cutting + workshop.yaml.
- **G — Plugin Claude Code:** plugin.json + 7 commands (`/smart-bootstrap`, `/smart-phs`, `/smart-feature`, `/smart-summary`, `/smart-teleport`, `/smart-workshop`, `/smart-graduate`) + 3 agents (architect, doc-writer, phs-helper).
- **H — Playbooks:** Top 5 builder-friendly (hardcoded-secrets, weak-auth, no-tests, no-readme, no-env-example).
- **I — Scripts:** `bootstrap.sh` (CLI 4 preguntas), `doctor.sh` (validación + subcomandos `phs validate`, `workshop validate`).
- **J — Validación + tag:** Definition of Done, `git tag v0.1.0`, push.

### Iteraciones post-v0.1.0 (siguen en Fase 1)

- **v0.1.1** — 1-prompt bootstrap (curl-pipe-bash), unattended flags.
- **v0.1.2** — organizer guidance (`ORGANIZER-CHECKLIST.md`) + two-layer env model. Plan en `parsed-chasing-boole.md`.
- **v0.1.3** — wiki-skeleton + `PRD.md` template para vibers (parte de v0.1.4 final).
- **v0.1.4** — `scripts/sync-env.sh` auto-sync `apis_external[].access` → archivos env (cierra TODO de v0.1.2).
- **v0.1.5** — `/smart-graduate` redesign (read-only diagnostic, 3 categorías) + `scripts/graduate.sh` + bootstrap corre `sync-env` post-workshop + `CHANGELOG.md` raíz + `docs/PHASES.md` + `CLAUDE.md` con refs a planes.

### Gaps menores conocidos (del plan maestro)

- ~~`CHANGELOG.md` raíz~~ ✅ creado.
- `docs/README.md` — índice de docs (ausente).
- `addons/README.md` — índice de addons (ausente).
- `core/wiki-skeleton/docs/changelog/CHANGELOG.md` — template (ausente, low priority).

---

## Fase 2 — post-MVP (✅ completa, v0.2.0)

**3 entregables explícitos** (`hazy-sniffing-hearth.md:242-245`), todos entregados:

### 2.1 Agentes nuevos en `plugin/agents/` ✅

- ✅ `reviewer.md` — code review light dev-time con perspectiva de las 7 policies (3 severidades: block/warn/info, output corto, sin scoring 0-5).
- ✅ `explorer.md` — discovery agent: recorre código y devuelve mapa mental (estructura, entry points, hotspots, deuda visible).

(Total: 5 agentes — architect, doc-writer, phs-helper, reviewer, explorer.)

### 2.2 Hook `session-start.sh` ✅

- ✅ `scripts/session-start.sh` lee `wiki/RESUME.md` (con fallback a `RESUME.md` raíz), trunca a 12KB y emite JSON con `hookSpecificOutput.additionalContext`.
- ✅ Registrado en `core/claude/settings.json.tmpl` bajo `hooks.SessionStart`.
- ✅ Embed automático en proyectos generados por bootstrap (single-team y workshop).
- ✅ Disable: `SMART_VIBE_DISABLE_SESSION_HOOK=1`.

### 2.3 Slash commands de workflow ✅

- ✅ `/smart-close-feature` — workflow de cierre (commit, session_summary, update RESUME, update ROADMAP). Simétrico a `/smart-feature`.
- ✅ `/smart-preflight` — validación pre-deploy (working tree + lint + typecheck + test + doctor + phs/workshop validate, `--review` opcional invocando al agente reviewer).
- ✅ `/smart-implementation-log` — entry técnico en `wiki/docs/implementation_logs/` desde el contexto de la sesión.

(Total: 10 commands — los 7 de v0.1.0 + estos 3.)

### Bonus de v0.2.0 (no era entregable de Fase 2 pero shipped)

- ✅ `scripts/check-docs.sh` + `scripts/install-hooks.sh` + `.github/workflows/check-docs.yml` — enforcer de la "Regla de documentación viva". Cierra el riesgo de drift (CHANGELOG/PHASES sin actualizar tras tag).

---

## Fase 3 — Ecosistema (🔴 lejano)

Sin orden definido, son tracks paralelos:

- **Multi-stack:** addons `python-fastapi/`, `go/`. Hoy sólo node-ts.
- **Internacionalización:** EN además de ES. Hoy todo es ES.
- **Marketplace:** publicación oficial del plugin en Claude Code marketplace.
- **`examples/parcher-distillation.md`:** doc del mapeo Parcher → smart-vibe (caso de estudio).

---

## Fuera de scope (entregable de `celeru-pro`, repo privado)

Estos NO se implementan en smart-vibe:

- `/smart-audit` profundo con LLM.
- `/smart-handoff` que genera `deliverables/` completo.
- Top 50 playbooks ejecutables (smart-vibe tiene top 5).
- Compliance LATAM (Ley 1581, Superfinanciera, Salud, PCI-DSS, SOC 2).
- Pipeline orchestrator + 7 agentes IA pesados.
- Modos `graduating` y `production`.

Ver `~/.openclaw/workspace/celeru-pro/ROADMAP.md` para el plan del repo hermano privado.
