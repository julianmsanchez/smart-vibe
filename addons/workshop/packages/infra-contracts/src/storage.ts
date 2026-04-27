/**
 * Storage (buckets / object storage) compartidos.
 *
 * Declaración tipada de `workshop.yaml.shared_infra.storage[]`.
 */

export type StorageProvider = 's3' | 'gcs' | 'r2' | 'azure-blob';

export interface StorageBucketConfig {
  /** Nombre del bucket (lógico, no el de la nube). */
  bucket: string;
  provider: StorageProvider;
  /** Teams con permiso. Vacío = ninguno. */
  access: readonly string[];
  /** URL pública si el bucket es servido por CDN. */
  publicUrl?: string;
}

/**
 * Ejemplo: borrar/reemplazar.
 */
export const UPLOADS_BUCKET: StorageBucketConfig = {
  bucket: 'workshop-uploads',
  provider: 's3',
  access: [],
};

export const ALL_BUCKETS: readonly StorageBucketConfig[] = [UPLOADS_BUCKET] as const;
