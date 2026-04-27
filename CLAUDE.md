# CLAUDE.md — repo `smart-vibe`

> Este archivo orienta a cualquier agente (Claude Code u otro) que trabaje **dentro** de este repo.
> No es el `CLAUDE.md.tmpl` que se entrega al builder al correr `bootstrap.sh` (ese vive en `core/templates/CLAUDE.md.tmpl` y se genera con `pnpm build:templates`).

---

## Identidad del repo

- **Nombre:** `smart-vibe`
- **Propósito:** distribución pública (MIT) del **Smart Vibe Framework**. Implementa el modo `vibe` de la metodología.
- **Mantenedor:** Julian Sánchez · Celeru SAS BIC
- **Hermano privado:** `celeru-pro` (modos `graduating` y `production`). NO se scaffoldea desde acá.
- **Idioma por defecto:** español. Mensajes de commit, docs y comentarios en español neutro. Strings de código (identificadores, logs estructurados) en inglés.

## Scope: qué SÍ y qué NO

**SÍ** se hace en este repo:
- Bootstrap CLI (`scripts/bootstrap.sh`, `npx smart-vibe init`)
- Templates: `CLAUDE.md.tmpl`, wiki, 7 policies en modo vibe
- Addons: `node-ts` (single-team) y `workshop` (Turborepo multi-team)
- Plugin Claude Code (`/smart-*` commands)
- Specs: `core/phs/` (PHS) y `core/workshop-spec/` (workshop.yaml)
- Docs framework (`docs/framework/`) con principios, modelo de madurez, modos, glosario, ADRs

**NO** se hace acá:
- Código del hermano privado (modos graduating/production, audits formales, integraciones enterprise).
- Código privado upstream del que se inspiran algunos templates (logger, env-loader, manage-server son fuente de inspiración; se extraen por template, ver regla de saneamiento abajo).
- Producción real del builder (apps deployables). Esto es toolkit, no aplicación.

## Contratos clave (dos SSOT)

1. **PHS (Prototype Handoff Spec)** — `core/phs/schema.{yaml,ts}`. YAML+Zod a nivel proyecto (`phs.yaml` en raíz del proyecto del builder). Define stack, vertical, decisiones, etc. En modo vibe permite campos vacíos; en graduating exige completitud.
2. **workshop.yaml** — `core/workshop-spec/schema.{yaml,ts}`. SSOT cross-cutting a nivel monorepo (sólo addon `workshop`). Declara teams, infra compartida (APIs, DBs, storage), UI compartida, secrets, observability, versioning, CI/CD. Cada `apps/<team>/phs.yaml` referencia el `workshop.yaml` global.

Cualquier cambio a estos schemas requiere actualizar también: ejemplos, validation-rules, doctor.sh, plugin/commands.

## Estructura (referencia rápida)

```
smart-vibe/
├── docs/framework/          # metodología (principios, modos, glosario, ADRs)
├── core/
│   ├── phs/                 # PHS spec (proyecto)
│   ├── workshop-spec/       # workshop.yaml spec (monorepo)
│   ├── policies/            # 7 policies en modo vibe
│   └── templates/           # CLAUDE.md.tmpl + wiki paralela
├── addons/
│   ├── node-ts/             # Express + TS + Vitest + observability
│   └── workshop/            # Turborepo + packages compartidos + docs/workshop
├── plugin/                  # Claude Code plugin (commands /smart-*)
└── scripts/                 # bootstrap.sh, doctor.sh
```

## Convenciones git

- **Conventional Commits** obligatorio. Tipos comunes: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`.
- **Granularidad: un commit por bundle** (no por archivo). Un bundle = grupo coherente que avanza un objetivo. Ver el plan operativo (local) para los bundles definidos.
- **NO push a remoto sin OK explícito del usuario.** Hasta Bloque J el repo vive sólo local.
- **NO `--amend`** salvo pedido explícito. Si un hook falla, fix + nuevo commit.
- **NO `--no-verify`.** Si un pre-commit falla, investigar.
- **Branch por defecto:** `main`. Sin trabajos en otras ramas hasta que el usuario lo pida.

## Regla de saneamiento (obligatoria antes de commit en archivos extraídos)

Cuando se extraen archivos desde fuentes privadas upstream (logger, env-loader, manage-server, etc.) hay que sanearlos antes de commitear. La regla:

**Placeholderización:**
- Nombres propios de agentes/personas → `{{DEV_AGENT}}`, `{{ORCHESTRATOR}}`, `{{PRODUCT_OWNER}}`, `{{PROJECT_NAME}}`.
- IDs de infra concreta (cuentas cloud, hosts de DB, buckets) → `{{AWS_ACCOUNT_ID}}`, `{{DB_HOST}}`, `{{S3_BUCKET}}`.
- Comentarios en español por defecto; los pendientes de traducción a EN se marcan con `TODO`.

**Filtro pre-commit:**

El patrón concreto de tokens prohibidos vive **fuera del repo**, en `~/.openclaw/credentials/smart-vibe/extraction-filter` (un término por línea). Antes de commitear archivos extraídos correr:

```bash
grep -iE -f ~/.openclaw/credentials/smart-vibe/extraction-filter <archivo>
```

Salida esperada: vacía. Si aparece algo, sanitizar antes de commit. Aplica especialmente a `addons/node-ts/src/services/logger.service.ts` y al `.env.example` del addon.

> Importante: nunca pegues los tokens prohibidos en archivos del repo (incluido este `CLAUDE.md`). Si tenés que documentar la regla, hacelo a nivel concepto y delegá la lista al archivo local.

## Planes operativos vigentes (locales, fuera del repo)

- `~/.claude/plans/` — plan operativo principal y diseños aprobados (workshop addon, etc.). Bloques A–J, decisiones cerradas, riesgos.
- `~/.openclaw/workspace/smart-vibe-docs/` — plan v2 completo (fuente de verdad metodológica) y referencias de hermano privado.

Si vas a hacer un cambio estructural (nuevo bloque, nuevo schema, nueva decisión), actualizá primero el plan operativo y luego el código.

## Policies aplicables a este repo (no al builder)

Aplicamos los principios de las 7 policies a nuestro propio código:
- **security:** sin secretos en repo; tokens OAuth y similares en `~/.openclaw/credentials/`.
- **architecture:** dos contratos (PHS + workshop.yaml), addons opt-in, plugin separado.
- **code-quality:** TS strict en specs, tests para schemas Zod.
- **data:** N/A en MVP (no persistimos datos).
- **ops:** scripts `bootstrap.sh` y `doctor.sh` idempotentes.
- **docs:** README + ADRs + framework docs siempre alineados con código.
- **change-control:** Conventional Commits + plan operativo como journal de decisiones.

## Comandos útiles

- `bash scripts/bootstrap.sh` — bootstrap interactivo (4 preguntas).
- `bash scripts/doctor.sh` — chequea estado del proyecto generado.
- `bash scripts/doctor.sh workshop validate <workshop.yaml>` — valida schema workshop.

## Cuando dudes

1. Leé el plan operativo en `~/.claude/plans/`.
2. Si toca workshop, leé también el diseño aprobado del addon workshop en la misma carpeta.
3. Si toca metodología, leé el plan v2 en `~/.openclaw/workspace/smart-vibe-docs/`.
4. Si la decisión no está cubierta, **preguntá** antes de improvisar.
