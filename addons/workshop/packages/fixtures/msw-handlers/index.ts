/**
 * Handlers MSW compartidos. Cada team agrega su sub-export acá.
 *
 * Modo vibe: vacío está OK. Materializar cuando un team quiera correr
 * frontend sin levantar su backend.
 */

import type { RequestHandler } from 'msw';

export const handlers: RequestHandler[] = [];
