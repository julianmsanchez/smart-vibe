import { Request, Response, NextFunction } from 'express';

/**
 * Wrapper que captura errores async en handlers de Express y los pasa al
 * next() para que el error middleware los procese.
 */
export function asyncHandler(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<void>
) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

/**
 * Middleware básico de autenticación por Bearer token.
 * Valida solo presencia y formato del header. La validación del token en
 * sí (firma, expiración, claims) es responsabilidad del proyecto.
 */
export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Missing or invalid authorization header',
    });
  }

  next();
}
