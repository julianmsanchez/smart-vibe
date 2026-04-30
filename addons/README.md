# `addons/` — Addons opt-in de `smart-vibe`

Cada subdirectorio es un **addon** que el bootstrap puede aplicar al
proyecto generado. Hoy hay dos: `node-ts` (single-team) y `workshop`
(multi-team con Turborepo).

El addon se elige en el bootstrap según el `--type`:

| `--type` | Addon aplicado | Stack |
|---|---|---|
| `single-team` | [`node-ts/`](node-ts/) | Node.js + TypeScript + Express + Vitest + observability base. |
| `workshop` | [`workshop/`](workshop/) | Turborepo + pnpm workspaces + packages cross-cutting (api-contracts, ui, telemetry, etc.). Apto para hackathons o multi-squad. |

---

## node-ts (single-team)

Addon base para proyectos individuales o equipos chicos. Detalle completo
en [`node-ts/README.md`](node-ts/README.md) y arquitectura en
[`node-ts/ARCHITECTURE.md`](node-ts/ARCHITECTURE.md).

Highlights:

- TS strict + lint + format preconfigurados.
- `createApp()` con healthcheck listo, middlewares (`asyncHandler`, `requireAuth`, basic auth admin).
- Logger con `AsyncLocalStorage` para trazabilidad por request.
- Observability base: Prometheus scrape + Grafana starter dashboard.
- CI: lint + typecheck + build + test. Deploy desactivado en modo vibe.

---

## workshop (multi-team)

Addon con dos capas: declarativa (`workshop.yaml` como SSOT cross-cutting)
+ concreta (packages compartidos). Detalle completo en
[`workshop/README.md`](workshop/README.md) y arquitectura en
[`workshop/ARCHITECTURE.md`](workshop/ARCHITECTURE.md).

Highlights:

- `workshop.yaml` declara teams, infra compartida, UI, secrets, observability, versioning.
- Two-layer env model: `.env.shared.example` (raíz) + `apps/<team>/.env.local.example` (por team).
- Packages base: `@workshop/api-contracts`, `@workshop/ui`, `@workshop/telemetry`, `@workshop/config`, `@workshop/test-utils`.
- `scripts/join.sh` viaja embebido para que un dev se sume a un team con un comando.
- `ORGANIZER-CHECKLIST.md` guía al organizer en los 4 pasos post-bootstrap.
- Spec del yaml: [`../core/workshop-spec/`](../core/workshop-spec/).

---

## Cómo agregar un addon nuevo

> Próxima fase. Hoy los addons no son extensibles por terceros; viven
> en este repo. Multi-stack (`python-fastapi`, `go`, etc.) es track de
> Fase 3 — ver [`../docs/PHASES.md`](../docs/PHASES.md).
