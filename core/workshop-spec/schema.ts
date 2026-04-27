/**
 * Workshop Spec — Zod schema v1
 *
 * SSOT cross-cutting a nivel monorepo del addon `workshop`. Vive en la raíz
 * de un proyecto type=workshop como `workshop.yaml`. Cada team referencia
 * este archivo desde su `phs.yaml` propio (campo `workshop.ref`).
 *
 * Uso:
 *   import { workshopSchema, type Workshop } from "smart-vibe/core/workshop-spec/schema";
 *   const result = workshopSchema.safeParse(yaml.load(file));
 */

import { z } from "zod";

export const WORKSHOP_SCHEMA_VERSION = "1.0" as const;

// ---- Enums ----

export const WorkshopType = z.enum([
  "hackathon",
  "corporate-squads",
  "multi-product",
]);

export const WorkshopMode = z.enum(["vibe", "graduating", "production"]);

export const DBStrategy = z.enum([
  "shared-schema-isolated-rows",
  "schema-per-team",
  "db-per-team",
]);

export const DBIsolation = z.enum(["row-level-security", "none"]);

export const StorageProvider = z.enum([
  "s3",
  "gcs",
  "r2",
  "azure-blob",
  "local-fs",
]);

export const SecretsStrategy = z.enum([
  "dotenv-local",
  "aws-secrets-manager",
  "vault",
  "doppler",
]);

export const Logger = z.enum(["pino", "winston", "bunyan", "otro"]);

export const LogFormat = z.enum(["json", "pretty"]);

export const LogDestination = z.enum([
  "stdout",
  "cloudwatch",
  "datadog",
  "loki",
  "otro",
]);

export const MocksStrategy = z.enum(["msw", "none"]);

export const VersioningStrategy = z.enum([
  "workspace-protocol",
  "semver-internal",
]);

export const IntegrationCheck = z.enum(["enabled", "disabled"]);

export const DeploymentStrategy = z.enum([
  "independent-per-team",
  "monolithic",
  "hybrid",
]);

// ---- Sub-objects ----

const slug = z
  .string()
  .min(1)
  .regex(/^[a-z0-9][a-z0-9-_]*$/, "slug lowercase, sin espacios");

export const Shell = z.object({
  framework: z.string().min(1),
  mounts_teams_at: z.string().min(1),
  theme_provider_pkg: z.string().min(1),
});

export const Team = z.object({
  id: slug,
  members: z.array(z.string()),
  domain: z.string().min(1),
  app_path: z.string().min(1),
  api_prefix: z.string().min(1),
});
export type Team = z.infer<typeof Team>;

export const ApiExternal = z.object({
  name: z.string().min(1),
  env_var: z.string().min(1),
  access: z.array(z.string()).default([]),
  budget_usd_monthly: z.number().nullable().optional(),
});

export const Databases = z.object({
  strategy: DBStrategy,
  url_env: z.string().min(1),
  migrations_owner: z.string().min(1),
  isolation: DBIsolation.optional(),
});

export const StorageBucket = z.object({
  bucket: z.string().min(1),
  provider: StorageProvider,
  access: z.array(z.string()).default([]),
});

export const Secrets = z.object({
  shared_file: z.string().min(1),
  strategy: SecretsStrategy,
  rotation_owner: z.string().min(1),
});

export const Observability = z.object({
  logger: Logger,
  log_format: LogFormat,
  correlation_header: z.string().min(1),
  destination: LogDestination,
  metrics_enabled: z.boolean(),
});

export const SharedInfra = z.object({
  apis_external: z.array(ApiExternal).default([]),
  databases: Databases,
  storage: z.array(StorageBucket).default([]),
  queues_buses: z.array(z.unknown()).default([]),
  secrets: Secrets,
  observability: Observability,
});

export const UIShared = z.object({
  design_system_pkg: z.string().min(1),
  tokens_path: z.string().min(1),
  components_path: z.string().min(1),
  assets_path: z.string().min(1),
});

export const Fixtures = z.object({
  seeds_path: z.string().min(1),
  mocks_strategy: MocksStrategy,
});

export const Versioning = z.object({
  strategy: VersioningStrategy,
  breaking_change_policy: z.string().min(1),
});

export const CICD = z.object({
  integration_check: IntegrationCheck,
  deployment_strategy: DeploymentStrategy,
  rollback_owner: z.string().min(1),
});

// ---- Root schema ----

export const workshopSchema = z
  .object({
    workshop: z.object({
      name: slug,
      type: WorkshopType,
      mode: WorkshopMode,
      shell: Shell,
      teams: z.array(Team).min(1),
      shared_infra: SharedInfra,
      ui_shared: UIShared,
      fixtures: Fixtures,
      versioning: Versioning,
      ci_cd: CICD,
    }),
  })
  .superRefine((root, ctx) => {
    const ws = root.workshop;
    const teamIds = new Set(ws.teams.map((t) => t.id));
    const owners = new Set([...teamIds, "shell"]);

    // teams ids únicos
    if (teamIds.size !== ws.teams.length) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["workshop", "teams"],
        message: "team ids deben ser únicos",
      });
    }

    // apis_external.access: cada elemento debe ser un team_id válido.
    ws.shared_infra.apis_external.forEach((api, i) => {
      api.access.forEach((teamId, j) => {
        if (!teamIds.has(teamId)) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            path: ["workshop", "shared_infra", "apis_external", i, "access", j],
            message: `team '${teamId}' no existe en teams[]`,
          });
        }
      });
    });

    // storage.access: cada elemento debe ser team_id válido.
    ws.shared_infra.storage.forEach((bucket, i) => {
      bucket.access.forEach((teamId, j) => {
        if (!teamIds.has(teamId)) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            path: ["workshop", "shared_infra", "storage", i, "access", j],
            message: `team '${teamId}' no existe en teams[]`,
          });
        }
      });
    });

    // migrations_owner debe ser team o "shell".
    if (!owners.has(ws.shared_infra.databases.migrations_owner)) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["workshop", "shared_infra", "databases", "migrations_owner"],
        message: `'${ws.shared_infra.databases.migrations_owner}' no es 'shell' ni un team_id válido`,
      });
    }

    // rollback_owner debe ser team o "shell".
    if (!owners.has(ws.ci_cd.rollback_owner)) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["workshop", "ci_cd", "rollback_owner"],
        message: `'${ws.ci_cd.rollback_owner}' no es 'shell' ni un team_id válido`,
      });
    }

    // secrets.rotation_owner debe ser team o "shell".
    if (!owners.has(ws.shared_infra.secrets.rotation_owner)) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["workshop", "shared_infra", "secrets", "rotation_owner"],
        message: `'${ws.shared_infra.secrets.rotation_owner}' no es 'shell' ni un team_id válido`,
      });
    }

    // En modo graduating, metrics_enabled debe ser true.
    if (ws.mode === "graduating" && !ws.shared_infra.observability.metrics_enabled) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["workshop", "shared_infra", "observability", "metrics_enabled"],
        message: "modo graduating requiere metrics_enabled=true",
      });
    }
  });

export type Workshop = z.infer<typeof workshopSchema>;
