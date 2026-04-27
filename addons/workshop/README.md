# Addon `workshop`

> Addon multi-team con Turborepo + pnpm workspaces. Para hackathons, squads paralelos o equipos multi-product que comparten infra, UI y políticas.

> **Único punto de control declarativo:** `workshop.yaml` en la raíz del monorepo (SSOT cross-cutting). Schema en `core/workshop-spec/`.

---

## Las dos capas

1. **Capa declarativa — `workshop.yaml`** (raíz del monorepo).
   Declara teams, infra compartida, UI compartida, secrets, observability, versioning, CI/CD.
2. **Capa concreta — packages cross-cutting** que implementan lo declarado.

Detalle en `ARCHITECTURE.md`.

---

## Estructura del monorepo generado

```
mi-workshop/
├── workshop.yaml                # SSOT cross-cutting
├── package.json                 # raíz, scripts pnpm/turbo
├── pnpm-workspace.yaml
├── turbo.json
├── .env.shared.example
├── CODEOWNERS                   # asigna ownership por team
├── .github/workflows/
│   ├── ci.yml
│   └── integration-check.yml    # cross-team integration check
│
├── apps/
│   ├── shell/                   # Next.js. Monta /{team_id}, ThemeProvider
│   ├── team-checkout/           # cada team es node-ts standalone
│   ├── team-search/
│   └── team-recs/
│
├── packages/
│   ├── design-system/           # tokens + components + assets + theme
│   ├── types/                   # tipos compartidos
│   ├── auth/                    # adapter de auth
│   ├── api-contracts/           # contratos HTTP entre teams
│   ├── config/                  # eslint/prettier/tsconfig compartidos  ← cross-cutting
│   ├── infra-contracts/         # tipos de workshop.yaml                ← cross-cutting
│   └── fixtures/                # seeds + msw                           ← cross-cutting
│
└── docs/workshop/               # 10 docs de operación cross-team
```

---

## Quickstart

```bash
# 1. Bootstrap del workshop
bash scripts/bootstrap.sh
# Tipo: workshop · Tier: startup · Vertical: general · Teams: 3

# 2. Setup local
cd mi-workshop
pnpm install

# 3. Dev cruzado: shell + un team
pnpm turbo dev --filter=shell --filter=...team-checkout

# 4. Validar workshop.yaml
bash scripts/doctor.sh workshop validate workshop.yaml

# 5. Plugin commands
/smart-workshop status
/smart-workshop integration-check
```

---

## Cuándo usar workshop vs single-team

| Situación | Usar |
|---|---|
| 1 equipo, 1 app | `single-team` con addon `node-ts` |
| 2+ equipos compartiendo design-system o auth | `workshop` |
| Multi-tenant SaaS comercial | ninguno (es otro patrón) |
| Hackathon de N teams independientes pero con infra compartida | `workshop` |

---

## Out of scope para v0.1.0 (TODO Fase 2)

- `packages/events/` — bus inter-team (queues, pub/sub).
- `packages/api-clients/` — autogen de SDKs desde `api-contracts`.
- `core/workshop-spec/example-corporate-squads.yaml`.
- Soporte de `db-per-team` con orquestación CDK.
- Style Dictionary integration en `design-system`.
- Storybook para `design-system/components`.
- Vault / AWS Secrets Manager integration nativa.
- Remote Turbo cache (signed URLs).

Estos quedan para Fase 2 o se entregan vía celeru-pro al graduar.

---

## Referencias

- Workshop spec (schema): `core/workshop-spec/`
- Plan completo aprobado: `~/.claude/plans/parsed-chasing-boole.md`
- Descripción metodológica: `docs/framework/10-workshop-mode.md`
- Plugin commands: `plugin/commands/smart-workshop.md`
