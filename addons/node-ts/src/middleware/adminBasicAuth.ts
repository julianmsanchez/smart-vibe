import { Request, Response, NextFunction } from 'express';

/**
 * Middleware de HTTP Basic Auth para rutas administrativas.
 *
 * Lee credenciales de las env vars `ADMIN_PANEL_USER` y
 * `ADMIN_PANEL_PASSWORD`. Si no están seteadas, responde 503.
 *
 * NOTA: Basic Auth es adecuado para paneles internos detrás de TLS.
 * Para auth de usuarios finales usar OAuth/JWT.
 *
 * Uso:
 *   app.use('/admin', adminBasicAuth, express.static(...))
 */
export function adminBasicAuth(req: Request, res: Response, next: NextFunction): void {
  const user = process.env.ADMIN_PANEL_USER;
  const pass = process.env.ADMIN_PANEL_PASSWORD;

  if (!user || !pass) {
    res.status(503).send('Authentication not configured');
    return;
  }

  const authHeader = req.headers.authorization || '';

  if (!authHeader.startsWith('Basic ')) {
    res.setHeader('WWW-Authenticate', 'Basic realm="Admin"');
    res.status(401).send('Authentication required');
    return;
  }

  const base64Credentials = authHeader.replace('Basic ', '');
  const credentials = Buffer.from(base64Credentials, 'base64').toString('utf8');
  const [providedUser, providedPass] = credentials.split(':');

  if (providedUser === user && providedPass === pass) {
    next();
    return;
  }

  res.setHeader('WWW-Authenticate', 'Basic realm="Admin"');
  res.status(401).send('Invalid credentials');
}
