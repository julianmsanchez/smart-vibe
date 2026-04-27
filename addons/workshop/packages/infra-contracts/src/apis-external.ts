/**
 * APIs externas compartidas.
 *
 * Declaración tipada de `workshop.yaml.shared_infra.apis_external[]`.
 * Mantener en sync a mano hasta que la Fase 2 autogenere desde el manifest.
 */

export interface ExternalApiConfig {
  /** Nombre lógico (debe coincidir con `apis_external[].name` en workshop.yaml). */
  name: string;
  /** Variable de entorno donde vive la API key. */
  envVar: string;
  /** Teams que pueden usar esta API. Vacío = ninguno. */
  access: readonly string[];
  /** Budget mensual en USD (informativo). */
  budgetUsdMonthly?: number;
  /** URL base, si aplica. */
  baseUrl?: string;
}

/**
 * Ejemplo: borrar/reemplazar por las APIs reales del workshop.
 */
export const OPENAI_CONFIG: ExternalApiConfig = {
  name: 'openai',
  envVar: 'OPENAI_API_KEY',
  access: [], // declarar teams en workshop.yaml y replicar acá
  budgetUsdMonthly: 50,
  baseUrl: 'https://api.openai.com/v1',
};

export const ALL_EXTERNAL_APIS: readonly ExternalApiConfig[] = [OPENAI_CONFIG] as const;
