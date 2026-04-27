# 07 · Decisiones de Arquitectura recomendadas

> Este doc consolida las **arquitecturas recomendadas** que el framework sugiere por defecto. **Son sugerencias, no obligaciones**. El builder puede sobrescribir cualquier default si lo justifica con una ADR.

> El objetivo: que un builder en modo vibe llegue a un stack razonable **sin tener que decidir desde cero**. Reduce parálisis por análisis y produce defaults que graduarán bien.

---

## Principio rector

**Lambda-first** para compute (en cloud), **postgres-first** para datos. Estas dos elecciones cubren ~80% de los proyectos y se gradúan suavemente.

Esto **no significa**:
- Que tu prototipo deba estar en AWS (un node-ts en local funciona perfecto).
- Que no puedas usar containers (perfectamente válido para muchas cargas).
- Que postgres sea siempre la respuesta (KV stores, columnar, vector DBs tienen su lugar).

**Sí significa**:
- Si no tenés razón fuerte para elegir otra cosa, lambda + postgres es el camino más predecible.
- El framework optimiza tooling, runbooks y agentes para esta combinación.

---

## Arquitecturas por tier

### Tier `startup` (default si tier no se especifica)

**Foco:** baja fricción operativa, free tiers cuando sea posible, escalado tardío aceptable.

| Capa | Recomendación | Alternativas razonables |
|---|---|---|
| **Compute** | Serverless (AWS Lambda, Cloudflare Workers, Vercel Functions) | Container en Render/Railway/Fly |
| **Database** | Postgres managed (Supabase, Neon, Render) | PlanetScale (mysql), DynamoDB (KV) |
| **Auth** | Supabase Auth, Clerk, Auth0 free tier | Custom con bcrypt + JWT |
| **Storage** | S3 / R2 / Supabase Storage | GCS, Azure Blob |
| **Hosting frontend** | Vercel, Netlify, Cloudflare Pages | S3+CloudFront |
| **Observability** | Logger estructurado a stdout + provider del cloud | Datadog (free), Grafana Cloud (free) |
| **CI/CD** | GitHub Actions (free para repos públicos / 2000min priv) | GitLab CI |

**Decisiones implícitas que esto cierra:**
- `infra.cloud: aws | cloudflare | vercel` (multi-cloud aceptable en vibe).
- `infra.deployment: serverless`.
- `data.primary_db: postgres-managed`.
- `auth.provider: supabase-auth | clerk | auth0`.

### Tier `corporate`

**Foco:** compliance, alta disponibilidad, integraciones enterprise.

| Capa | Recomendación | Alternativas razonables |
|---|---|---|
| **Compute** | Lambda + ECS Fargate para cargas especiales | Kubernetes (EKS/GKE) si ya hay knowledge |
| **Database** | RDS Postgres Multi-AZ + read replicas | Aurora Postgres |
| **Auth** | Cognito, Auth0 enterprise, Okta | Active Directory federation |
| **Storage** | S3 con KMS + versioning | GCS con CMEK |
| **Hosting frontend** | CloudFront + S3, o Vercel Enterprise | NGINX en Fargate |
| **Observability** | CloudWatch + Datadog/New Relic | Grafana + Prometheus self-hosted |
| **CI/CD** | GitHub Actions Enterprise + AWS CodeDeploy | GitLab CI premium |
| **Secrets** | AWS Secrets Manager / Vault | KMS + parameter store |
| **Compliance** | Vertical-específico (HIPAA, PCI-DSS, SOC2) | — |

**Decisiones implícitas:**
- `infra.cloud: aws | gcp | azure`.
- `infra.deployment: serverless + container hybrid`.
- `auth.provider: cognito | okta | auth0-enterprise`.
- `compliance.required: true` (default).

---

## Decisiones por vertical

### Fintech

- `compliance.required: true` automático.
- `compliance.frameworks: [pci-dss]` mínimo, `[soc2]` recomendado.
- Auth: MFA obligatorio; passwordless aceptable.
- Logging: PII tagueada, retención según regulación local (LATAM: ver normativa por país).
- Backup: RPO ≤1h, RTO ≤4h.
- Auditoría externa anual.

### Salud

- `compliance.required: true`.
- `compliance.frameworks: [hipaa]` (US) o equivalente local.
- Encriptación at-rest + in-transit obligatoria.
- Audit log inmutable de acceso a PHI/datos sensibles.
- BAA con todos los providers que toquen datos.

### Gobierno

- Compliance por jurisdicción.
- Hosting on-premise o sovereign cloud según requerimiento.
- Procesos de cambio formales (RFC + approval boards) — afecta dimensión change-control.

### Edu, retail, telecom, otro

- Compliance opt-in según tamaño/regulación.
- Defaults de tier aplican sin restricciones extra.

---

## Decisiones a nivel proyecto (que el builder toma)

Independiente de tier/vertical, hay decisiones que **el builder tiene que tomar** y registrar:

1. **Patrón de API** — REST, GraphQL, RPC. El framework no opina; cada uno tiene su lugar.
2. **State management (frontend)** — depende del framework UI elegido.
3. **Async / messaging** — colas (SQS, Pub/Sub), event bus, scheduled jobs. Solo si el dominio lo requiere.
4. **Multi-tenancy strategy** — schema-per-tenant, row-level isolation, db-per-tenant (más caro pero más aislado).
5. **Caching** — in-memory, Redis, CDN. Solo si hay performance need real.
6. **Search** — DB ILIKE, postgres FTS, OpenSearch/Elasticsearch. Empezar simple.
7. **Background jobs** — same-process workers, dedicated workers (BullMQ, Sidekiq), serverless schedulers.

Cada una de estas debe registrarse como ADR si se elige algo no-default.

---

## Decisiones recomendadas por defecto en `node-ts` addon

El addon `node-ts` ya viene con elecciones:
- **Framework:** Express. (Alternativas: Hono, Fastify — no soportadas en MVP).
- **Logger:** Pino, formato JSON.
- **Validación:** Zod.
- **Tests:** Vitest.
- **Config:** dotenv + zod schema.
- **Linter:** ESLint + Prettier.
- **TS:** strict.

Cambiar uno requiere ADR. Cambiar varios = considerar otro addon (futuro).

---

## Decisiones recomendadas en `workshop` addon

Detalle en `10-workshop-mode.md`. Resumen:
- **Monorepo:** Turborepo + pnpm workspaces.
- **Shell:** Next.js 14+ (App Router).
- **Apps por team:** consume el addon `node-ts` debajo.
- **Packages compartidos:** `design-system`, `types`, `auth`, `api-contracts`, `config`, `infra-contracts`, `fixtures`.
- **DB strategy default:** `shared-schema-isolated-rows` con RLS opcional.
- **CI/CD:** GitHub Actions con `integration-check` cross-team.

---

## Cómo registrar overrides

Si elegís algo distinto al default, registrá una ADR:

```markdown
# 0008 · Stack: Hono en lugar de Express

- **Status:** Accepted
- **Date:** 2026-04-27
- **Decisión:** Hono como framework HTTP en lugar de Express.
- **Razón:** edge runtime first-class (deploy a Cloudflare Workers), API más moderna, performance.
- **Alternativas descartadas:** Express (default del addon), Fastify.
- **Trade-offs:** menos ecosistema de middleware; algunas integraciones requieren wrapper.
- **Cuándo revisar:** si la app deja de usar edge runtime o el ecosistema se vuelve bottleneck.
```

Después actualizás `phs.stack.framework: hono` y mencionás la ADR en `phs.decisions[]`.

---

## Anti-patrones de elección

- **Stack hipster sin razón:** elegir un framework recién salido sin ecosistema porque "se ve cool". El framework no lo prohíbe, pero `celeru-pro` te va a auditar fuerte sobre ecosistema en F2.
- **Multi-cloud por defecto:** complejidad operativa multiplicada por N clouds. Solo si hay razón regulatoria.
- **Microservicios desde día 1 en startup tier:** salvo que tengas equipos separados, monolito → modular monolito → microservicios es el camino que mejor escala con personas.
- **Postgres + Mongo + Redis "porque sí":** un primary store + cache opcional cubre 90% de los casos en startup tier.

---

## Referencias

- Tier y vertical: `00-principles.md` § 9
- PHS spec: `03-phs-spec.md`
- Workshop mode: `10-workshop-mode.md`
- Pipeline (donde estos defaults se auditan): `06-pipeline.md`
