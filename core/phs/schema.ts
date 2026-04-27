/**
 * PHS — Prototype Handoff Spec — Zod schema v1
 *
 * Fuente de verdad TÉCNICA del schema PHS (importable por celeru-pro,
 * doctor.sh, plugin Claude Code). Cuando difiere de schema.yaml, manda
 * este archivo.
 *
 * Uso:
 *   import { phsSchema, type PHS } from "smart-vibe/core/phs/schema";
 *   const result = phsSchema.safeParse(yaml.load(file));
 *
 * Validaciones por modo (graduating/production) viven en
 * `validation-rules.md` y se implementan en celeru-pro.
 */

import { z } from "zod";

export const PHS_SCHEMA_VERSION = "1.0" as const;

// ---- Enums ----

export const Mode = z.enum(["vibe", "graduating", "production"]);
export type Mode = z.infer<typeof Mode>;

export const ProjectType = z.enum(["single-team", "workshop"]);
export type ProjectType = z.infer<typeof ProjectType>;

export const Vertical = z.enum([
  "general",
  "fintech",
  "salud",
  "retail",
  "edu",
  "gobierno",
  "telecom",
  "otro",
]);
export type Vertical = z.infer<typeof Vertical>;

export const Tier = z.enum(["startup", "corporate"]);
export type Tier = z.infer<typeof Tier>;

export const Language = z.enum([
  "typescript",
  "javascript",
  "python",
  "go",
  "rust",
  "otro",
]);

export const PackageManager = z.enum([
  "pnpm",
  "npm",
  "yarn",
  "bun",
  "pip",
  "poetry",
  "uv",
  "gomod",
  "cargo",
]);

export const Addon = z.enum([
  "node-ts",
  "workshop",
  "compliance",
  "observability-extra",
]);

export const Cloud = z
  .enum([
    "aws",
    "gcp",
    "azure",
    "vercel",
    "cloudflare",
    "fly",
    "railway",
    "render",
    "otro",
  ])
  .nullable();

export const Deployment = z
  .enum(["serverless", "container", "vm", "static", "edge"])
  .nullable();

export const AuthProvider = z
  .enum([
    "supabase-auth",
    "auth0",
    "cognito",
    "clerk",
    "firebase-auth",
    "custom",
    "otro",
  ])
  .nullable();

export const AuthStrategy = z
  .enum(["oauth", "password", "magic-link", "passkeys", "sso"])
  .nullable();

export const ComplianceFramework = z.enum([
  "pci-dss",
  "hipaa",
  "soc2",
  "gdpr",
  "lgpd",
  "iso-27001",
  "otro",
]);

export const DecisionStatus = z.enum([
  "proposed",
  "accepted",
  "deprecated",
  "superseded",
]);

// ---- Sub-objects ----

export const ProjectMeta = z.object({
  name: z
    .string()
    .min(1)
    .regex(/^[a-z0-9][a-z0-9-_]*$/, "slug lowercase, sin espacios"),
  mode: Mode,
  type: ProjectType,
  vertical: Vertical,
  tier: Tier,
  created_at: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "formato YYYY-MM-DD"),
  description: z.string().optional(),
});
export type ProjectMeta = z.infer<typeof ProjectMeta>;

export const WorkshopRef = z.object({
  ref: z.string().min(1),
  team_id: z.string().optional(),
});
export type WorkshopRef = z.infer<typeof WorkshopRef>;

export const Stack = z.object({
  language: Language,
  runtime: z.string().min(1),
  framework: z.string().min(1),
  package_manager: PackageManager,
  addon: z.enum(["node-ts", "workshop"]),
});
export type Stack = z.infer<typeof Stack>;

export const Data = z.object({
  primary_db: z.string().nullable(),
  cache: z.string().nullable(),
  storage: z.string().nullable(),
});
export type Data = z.infer<typeof Data>;

export const Infra = z.object({
  cloud: Cloud,
  region: z.string().nullable(),
  deployment: Deployment,
});
export type Infra = z.infer<typeof Infra>;

export const Auth = z.object({
  provider: AuthProvider,
  strategy: AuthStrategy,
});
export type Auth = z.infer<typeof Auth>;

export const Compliance = z.object({
  required: z.boolean(),
  frameworks: z.array(ComplianceFramework),
});
export type Compliance = z.infer<typeof Compliance>;

export const DecisionRef = z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  file: z.string().min(1),
  status: DecisionStatus,
});
export type DecisionRef = z.infer<typeof DecisionRef>;

export const SLA = z.object({
  uptime_target: z.string().nullable(),
  rto: z.string().nullable(),
  rpo: z.string().nullable(),
  business_hours: z.string().nullable(),
});
export type SLA = z.infer<typeof SLA>;

export const Docs = z.object({
  wiki_path: z.string().nullable(),
  runbooks_path: z.string().nullable(),
  decisions_path: z.string().nullable(),
});
export type Docs = z.infer<typeof Docs>;

// ---- Root schema ----

export const phsSchema = z
  .object({
    project: ProjectMeta,
    workshop: WorkshopRef.optional(),
    stack: Stack,
    data: Data,
    infra: Infra,
    auth: Auth,
    compliance: Compliance,
    addons: z.array(Addon).min(1),
    decisions: z.array(DecisionRef),
    sla: SLA.optional(),
    docs: Docs,
  })
  .superRefine((phs, ctx) => {
    // Cross-field: si type=workshop, workshop.ref debe estar.
    if (phs.project.type === "workshop" && !phs.workshop) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["workshop"],
        message: "type=workshop requiere bloque workshop.ref",
      });
    }
    // Cross-field: si addon=workshop, type debe ser workshop.
    if (phs.stack.addon === "workshop" && phs.project.type !== "workshop") {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["stack", "addon"],
        message: "stack.addon=workshop solo permitido si project.type=workshop",
      });
    }
  });

export type PHS = z.infer<typeof phsSchema>;
