/**
 * Auth adapter compartido.
 *
 * Define la interfaz que cada team usa para autenticar usuarios. La
 * implementación concreta (provider real: Auth0, Cognito, Supabase Auth,
 * Clerk, custom) se inyecta en bootstrap del shell.
 *
 * Esto permite que cada team escriba contra una sola interfaz y el
 * workshop pueda swap-ear de provider sin tocar a los teams.
 */

import type { UUID } from '@workshop/types';

export interface Session {
  userId: UUID;
  email?: string;
  expiresAt: string; // ISO
  roles?: string[];
}

export interface AuthAdapter {
  /** Lee la sesión actual desde un request. Devuelve null si no hay. */
  getSession(req: { headers: Record<string, string | string[] | undefined> }): Promise<Session | null>;

  /** Verifica que la sesión tenga al menos uno de los roles. */
  requireRole(session: Session, roles: string[]): boolean;

  /** Login (delegado al provider). Implementación específica del provider. */
  login(credentials: unknown): Promise<Session>;

  /** Logout (invalidar token/sesión). */
  logout(session: Session): Promise<void>;
}

/**
 * Stub que se reemplaza por el adapter real al hacer bootstrap el shell.
 * Ver workshop.yaml.shared_infra (no hay sección auth todavía — TODO Fase 2).
 */
export class NoopAuthAdapter implements AuthAdapter {
  async getSession(): Promise<Session | null> {
    return null;
  }
  requireRole(_session: Session, _roles: string[]): boolean {
    return false;
  }
  async login(_credentials: unknown): Promise<Session> {
    throw new Error('NoopAuthAdapter: configure a real provider in shell bootstrap');
  }
  async logout(): Promise<void> {
    /* no-op */
  }
}
