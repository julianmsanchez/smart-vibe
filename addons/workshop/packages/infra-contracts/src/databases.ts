/**
 * Databases compartidas.
 *
 * Declaración tipada de `workshop.yaml.shared_infra.databases`. Cada team
 * importa `DB_CONFIG` y respeta la `strategy` declarada (no escribir fuera
 * de su namespace).
 */

export type DatabaseStrategy =
  | 'shared-schema-isolated-rows'
  | 'schema-per-team'
  | 'db-per-team';

export type IsolationMode = 'row-level-security' | 'none';

export interface DatabaseConfig {
  strategy: DatabaseStrategy;
  /** Variable de entorno con la connection string. */
  urlEnv: string;
  /** Quién es dueño de las migraciones. Casi siempre "shell". */
  migrationsOwner: string;
  /** Aislación entre teams. */
  isolation: IsolationMode;
}

/**
 * Ejemplo: borrar/reemplazar según `workshop.yaml`.
 */
export const DB_CONFIG: DatabaseConfig = {
  strategy: 'shared-schema-isolated-rows',
  urlEnv: 'DATABASE_URL',
  migrationsOwner: 'shell',
  isolation: 'row-level-security',
};
