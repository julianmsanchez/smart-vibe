/**
 * Health route — responde 200 con un payload mínimo.
 *
 * Sirve para que `apps/shell/` y `scripts/integration-check` validen que
 * el team está vivo antes de orquestar tests cross-team.
 */

import { Router } from 'express';

// Tipo explícito para evitar TS2742 al inferir el tipo desde @types/express
// (los tipos viven en express-serve-static-core, no es portable).
export const healthRouter: Router = Router();

healthRouter.get('/', (_req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});
