/**
 * Configuración centralizada del proyecto.
 *
 * Patrón: un único objeto `config` con secciones agrupadas, alimentado
 * desde variables de entorno con defaults razonables. Llamar
 * `validateConfig()` al startup del proceso para fallar rápido si falta
 * algo crítico.
 *
 * Reglas del patrón:
 * - NO leer `process.env` desde otros archivos. Todo pasa por `config`.
 * - Defaults seguros para dev local; vars críticas se validan en
 *   `validateConfig()`.
 * - Cuando agregás una sección, declarala acá y registrá las vars
 *   críticas en `required`.
 *
 * Documentar cada var en `.env.example`.
 */

import dotenv from 'dotenv';

dotenv.config();

export const config = {
  // App
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  logLevel: process.env.LOG_LEVEL || 'info',

  // Database
  // Reemplazar por tu provider preferido (Supabase, Neon, RDS, etc.).
  database: {
    url: process.env.DATABASE_URL || '',
    schema: process.env.DB_SCHEMA || 'public',
  },

  // Auth
  // Token interno simple para endpoints administrativos. En graduating
  // mover a JWT firmado, OAuth, o el provider que decidas.
  internalApiToken: process.env.INTERNAL_API_TOKEN || 'change-me-in-development',

  // Servicios externos (ejemplos opcionales — eliminá lo que no uses).
  external: {
    // Ejemplo: cliente LLM
    llmApiKey: process.env.LLM_API_KEY || '',
    // Ejemplo: object storage
    storageBucket: process.env.STORAGE_BUCKET || '',
  },
};

/**
 * Valida que las variables críticas estén definidas.
 *
 * Llamar al inicio del proceso (en `app.ts` antes de levantar el server).
 * Lanza si falta algo.
 */
export function validateConfig(): void {
  const required: { key: string; value: string }[] = [
    // Descomentar/agregar las que tu app requiera al startup.
    // { key: 'DATABASE_URL', value: config.database.url },
  ];

  const missing = required.filter((item) => !item.value);

  if (missing.length > 0) {
    const keys = missing.map((item) => item.key).join(', ');
    throw new Error(`Missing required environment variables: ${keys}`);
  }
}
