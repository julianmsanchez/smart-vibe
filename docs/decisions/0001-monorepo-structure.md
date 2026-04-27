# 0001 · Estructura monorepo de smart-vibe

- **Status:** Accepted
- **Date:** 2026-04-27
- **Deciders:** Julian Sánchez

## Contexto

`smart-vibe` agrupa varios artefactos heterogéneos: docs metodológicas, specs (PHS, workshop.yaml), policies, templates, dos addons (`node-ts`, `workshop`), un plugin de Claude Code y scripts de bootstrap/doctor. Cada uno podría vivir en su propio paquete o repo.

La pregunta: ¿split (mono-paquete por concepto) o mono-repo (todo en un repo único)?

## Decisión

Mantener **un solo repo con un solo `package.json` raíz**. La estructura interna agrupa por capa funcional:

```
smart-vibe/
├── docs/framework/       # metodología (lectura)
├── core/
│   ├── phs/              # PHS spec
│   ├── workshop-spec/    # workshop.yaml spec
│   ├── policies/         # 7 policies modo vibe
│   └── templates/        # CLAUDE.md.tmpl + wiki paralela
├── addons/
│   ├── node-ts/          # opt-in
│   └── workshop/         # opt-in
├── plugin/               # Claude Code commands
└── scripts/              # bootstrap.sh, doctor.sh
```

No hay `pnpm workspaces` ni Turborepo en este repo. El monorepo (Turborepo + pnpm) **lo genera el addon `workshop`** en el repo del builder, no lo usa `smart-vibe` internamente.

## Alternativas consideradas

### A) Múltiples repos (split por concepto)
- `smart-vibe-spec` (PHS + workshop.yaml + policies)
- `smart-vibe-cli` (bootstrap + doctor)
- `smart-vibe-addons` (uno por addon)
- `smart-vibe-plugin` (plugin Claude Code)
- `smart-vibe-docs` (framework docs)

**Rechazado** porque:
- En MVP cada artefacto cambia con los demás (un cambio al PHS schema toca templates, plugin, doctor, policies). Cross-repo PRs serían el día a día.
- 5 repos × 5 issues de versionado = matriz combinatoria innecesaria.
- El builder consume **una sola cosa** (`npx smart-vibe init`); abstraer eso a 5 publicaciones es over-engineering.

### B) Monorepo con pnpm workspaces interno
- `packages/spec`, `packages/cli`, `packages/addons-node-ts`, etc.

**Rechazado** porque:
- Agrega complejidad (build matrix, version sync, lockfile manejo) sin beneficio en MVP.
- Si en algún momento queremos separar (e.g., publicar `@smart-vibe/spec` standalone), la migración desde estructura plana es trivial.

## Consecuencias

### Positivas
- Cambios atómicos cross-capa en un solo PR.
- Setup local ultra simple (`git clone && pnpm install`).
- Ningún builder necesita lidiar con 5 paquetes — consume `smart-vibe` y listo.
- Distribución por `npx smart-vibe init` se mantiene trivial (un solo paquete a publicar).

### Negativas
- Si en el futuro queremos publicar `@smart-vibe/spec` separado (e.g., para que `celeru-pro` lo consuma sin pull del addon), hay que refactorizar.
- El repo crece monolítico; navegabilidad depende de buena estructura de carpetas (lo cubre `core/`, `addons/`, `plugin/`).

### Mitigaciones
- Convención: cada carpeta de `core/` y `addons/` tiene su propio README.md con scope claro.
- Si llega el momento de splittear, se hará con ADR explícita y los puntos de corte ya están razonados (cada carpeta es candidata a paquete independiente).

## Referencias

- Plan operativo: `~/.claude/plans/hazy-sniffing-hearth.md`
- Plan v2: `~/.openclaw/workspace/smart-vibe-docs/SMART_VIBE_PLAN_V2.md`
- ADR 0006: two-distributions
