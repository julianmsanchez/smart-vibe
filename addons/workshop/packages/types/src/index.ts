/**
 * Tipos compartidos cross-team.
 *
 * Reglas:
 * - Solo tipos genuinamente compartidos (entidades del dominio común,
 *   ids, enums). NO tipos de un solo team — esos viven en `apps/<team>/`.
 * - Sin lógica, sin imports de runtime libs. Solo `type` y `interface`.
 * - Cuando una entidad pasa a tener lógica asociada, mover a un service
 *   y exportar solo el tipo desde acá.
 */

/** UUID v4 string. */
export type UUID = string;

/** ISO 8601 timestamp string. */
export type ISODateString = string;

/** Identificador de team en este workshop. */
export type TeamId = string;

/** Wrapper estándar para respuestas paginadas. */
export interface Paginated<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
}

/** Wrapper estándar para errores HTTP entre teams. */
export interface ApiError {
  error: string;
  message: string;
  details?: Record<string, unknown>;
}
