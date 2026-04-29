# Smart Vibe — Guía del builder

> Manual de uso de las herramientas que `smart-vibe` instala en tu proyecto.
> Asume que ya corriste `bootstrap.sh` y tenés el repo generado.
> Para arrancar desde cero ver [`QUICKSTART.md`](QUICKSTART.md).

---

## Modelo mental

Tu proyecto smart-vibe tiene tres capas de herramientas:

| Capa | Dónde vive | Cuándo se usa |
|---|---|---|
| **Slash commands** (10) | `.claude/commands/` o plugin instalado | Vibeando dentro de Claude Code: `/smart-feature`, `/smart-close-feature`, etc. |
| **Agentes** (5) | `plugin/agents/` | Tareas más largas o discovery: `architect`, `reviewer`, `explorer`, `doc-writer`, `phs-helper`. |
| **Scripts bash** (4) | `scripts/` del proyecto generado | Validación, sync, handoff: `doctor.sh`, `sync-env.sh`, `graduate.sh`, `session-start.sh`. |

Las tres apuntan al mismo objetivo: **prototipar rápido sin perder disciplina** (PHS al día, wiki al día, policies aplicadas en modo vibe).

---

## Workflow típico (día a día)

```
Empezás sesión              → SessionStart hook carga wiki/RESUME.md automático
                              (no hacés nada)

Querés trabajar feature X   → /smart-feature checkout-flow
                              crea src/features/, test stub, wiki/features/checkout-flow.md

Vibeás                      → escribís código con Claude. Si dudás de arquitectura:
                              invocá agente architect. Si querés review: agente reviewer.

Cerrás la feature           → /smart-close-feature checkout-flow
                              corre tests del módulo + commit + session_summary +
                              update RESUME + update ROADMAP

Implementación atípica      → /smart-implementation-log checkout-flow
(opcional)                    captura problema/opciones/decisión/trade-offs

Antes de push o tag         → /smart-preflight
                              lint + typecheck + tests + doctor + phs validate

Cuando madura               → /smart-graduate
                              diagnóstico read-only + handoff a celeru-pro
```

---

## Slash commands

Todos viven en `plugin/commands/<nombre>.md`. La spec completa de cada uno está
ahí; abajo está la versión "cuándo lo uso".

| Comando | Cuándo |
|---|---|
| [`/smart-bootstrap`](../plugin/commands/smart-bootstrap.md) | Ya lo corriste para generar el proyecto. Útil de nuevo sólo si querés re-bootstrap. |
| [`/smart-feature <nombre>`](../plugin/commands/smart-feature.md) | Abrir una feature nueva. Crea código + test + wiki entry. |
| [`/smart-close-feature <nombre>`](../plugin/commands/smart-close-feature.md) | Cerrar la feature: commit + session_summary + update RESUME + update ROADMAP. Simétrico al de arriba. |
| [`/smart-implementation-log <slug>`](../plugin/commands/smart-implementation-log.md) | Después de implementar algo complejo (auth, pagos, jobs distribuidos). Captura nota técnica profunda. |
| [`/smart-preflight`](../plugin/commands/smart-preflight.md) | Antes de un push importante o un tag. Falla rápido si lint/test/doctor no pasan. Opcional `--review` invoca al agente reviewer. |
| [`/smart-summary`](../plugin/commands/smart-summary.md) | Querés un overview del estado del proyecto: PHS, modo, deuda, decisiones recientes. |
| [`/smart-teleport`](../plugin/commands/smart-teleport.md) | Sesión nueva de Claude Code y querés cargar contexto rápido. (Complementario al hook SessionStart, que ya lo hace solo.) |
| [`/smart-phs`](../plugin/commands/smart-phs.md) | Editar/validar `phs.yaml` con asistencia. |
| [`/smart-workshop`](../plugin/commands/smart-workshop.md) | Sólo en proyectos type=workshop. Subcomandos: `status`, `integration-check`, `add-team`. |
| [`/smart-graduate`](../plugin/commands/smart-graduate.md) | Cuando el proyecto está listo para dejar el modo vibe. Diagnóstico read-only + handoff a celeru-pro. |

---

## Agentes

Los 5 viven en `plugin/agents/<nombre>.md`. Se invocan desde Claude Code como
tareas paralelas (`> use agent reviewer to ...`).

| Agente | Cuándo |
|---|---|
| [`architect`](../plugin/agents/architect.md) | Decisión de arquitectura concreta (qué DB, cómo modular, qué pattern). Lee el PHS, propone trade-offs. NO escribe código. |
| [`reviewer`](../plugin/agents/reviewer.md) | Code review dev-time del último commit/diff. 3 severidades (block/warn/info). Para audit profundo con scoring 0-5 → celeru-pro. |
| [`explorer`](../plugin/agents/explorer.md) | Llegás a un repo nuevo y necesitás un mapa mental en <10 min: estructura, entry points, hotspots, deuda visible. |
| [`doc-writer`](../plugin/agents/doc-writer.md) | Generar o actualizar wiki paralela y READMEs cuando el código se desfasó de la doc. |
| [`phs-helper`](../plugin/agents/phs-helper.md) | Edita `phs.yaml` con validación Zod en línea. Útil si una decisión nueva amerita registrar un ADR + entry en `decisions[]`. |

---

## Scripts

Viven en `scripts/` del proyecto generado. Se corren con `bash scripts/<nombre>.sh`.

| Script | Qué hace |
|---|---|
| [`doctor.sh`](../scripts/doctor.sh) | Estado del proyecto. Lista warns/fails de las 7 policies. Subcomandos: `phs validate`, `workshop validate`. Tolerante en modo vibe. |
| [`sync-env.sh`](../scripts/sync-env.sh) | Sólo en workshops. Re-genera `apps/<team>/.env.local.example` desde `workshop.yaml.shared_infra.apis_external[].access`. Correr cuando editás el yaml. |
| [`graduate.sh`](../scripts/graduate.sh) | Backend del slash `/smart-graduate`. Diagnóstico read-only en 3 categorías. No cambia nada. |
| [`session-start.sh`](../scripts/session-start.sh) | Hook que corre solo al abrir una sesión Claude Code. Carga `wiki/RESUME.md` al contexto. Disable: `SMART_VIBE_DISABLE_SESSION_HOOK=1`. |

---

## Decisiones de documentación (cuándo qué)

Tres lugares para escribir cosas. La diferencia importa.

| Lugar | Qué va | Cuándo |
|---|---|---|
| `docs/decisions/NNNN-<slug>.md` (ADR) | Decisión arquitectónica con consecuencias estables ("usamos Postgres en vez de Mongo porque..."). Una decisión = un ADR. | Al tomar la decisión. Linkearla en `phs.yaml.decisions[]`. |
| `wiki/docs/implementation_logs/<fecha>-<slug>.md` | Cómo se implementó algo arriesgado/atípico. Problema, opciones, decisión, trade-offs aceptados, riesgos. | Después de cerrar una feature compleja. Disparado por `/smart-implementation-log`. |
| `wiki/docs/session_summaries/<fecha>-<slug>.md` | Resumen ejecutivo de una sesión: archivos tocados, decisiones tomadas, qué quedó pendiente. | Cada vez que cerrás una feature. Disparado por `/smart-close-feature`. |

**Regla rápida:**

- ¿La decisión tiene impacto a meses? → ADR.
- ¿La feature fue compleja y quiero que el próximo dev entienda el "por qué"? → implementation_log.
- ¿Quiero que mi yo de la próxima sesión retome rápido? → session_summary (lo genera `/smart-close-feature`).

---

## Variables de entorno

| Variable | Efecto |
|---|---|
| `SMART_VIBE_DISABLE_SESSION_HOOK=1` | Desactiva la auto-carga de `RESUME.md` al abrir sesión. |
| `SKIP_DOCS_CHECK=1` | Bypass del hook `commit-msg` que exige actualizar `CHANGELOG.md` en commits `feat`/`fix`. Sólo para casos puntuales. |

---

## FAQ

**¿Qué pasa si no creo `wiki/RESUME.md`?**
Nada. El hook `session-start.sh` falla silencioso y la sesión arranca sin contexto extra.

**¿Cómo sé si estoy en modo vibe o graduating?**
`grep mode phs.yaml`. El bootstrap setea `vibe`. Para pasar a graduating no tocás esto a mano: corrés `/smart-graduate`, que vive en celeru-pro.

**¿Tengo que usar todos los slash commands?**
No. El mínimo viable es `bootstrap` + `feature` + `close-feature`. Lo demás es opt-in según necesidad.

**¿Puedo deshabilitar las policies?**
Las policies son markdown en `docs/policies/` — no se "ejecutan", son guías. `doctor.sh` chequea algunas en modo warn-only en vibe. Si querés ignorar un warn puntual: el playbook correspondiente en `docs/playbooks/` te dice cómo.

**¿Por qué hay un `phs.yaml` Y un `workshop.yaml`?**
- `phs.yaml` → SSOT a nivel proyecto (un archivo por proyecto, o uno por team en workshops).
- `workshop.yaml` → SSOT cross-cutting a nivel monorepo (sólo en workshops). Declara teams, infra compartida, secrets.

Ambos están especificados en `core/phs/` y `core/workshop-spec/` del repo `smart-vibe`.

**¿Cómo actualizo a una versión nueva de smart-vibe?**
Hoy no hay update automático. Mirá el `CHANGELOG.md` del repo y aplicá los cambios relevantes a mano. Cuando smart-vibe tenga `npx smart-vibe update`, lo documentaremos acá.

---

## Referencias rápidas

- Especificaciones de comandos y agentes: [`plugin/commands/`](../plugin/commands/) y [`plugin/agents/`](../plugin/agents/).
- Quick start (bootstrap desde cero): [`QUICKSTART.md`](QUICKSTART.md).
- Fases del proyecto smart-vibe: [`PHASES.md`](PHASES.md).
- Metodología y principios: [`framework/`](framework/).
- Cambios por versión: [`../CHANGELOG.md`](../CHANGELOG.md).
