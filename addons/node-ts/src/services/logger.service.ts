/**
 * Logger Service
 *
 * Logger estructurado pensado para apps Node + TypeScript. Diseñado para
 * ser compatible con agregadores externos (CloudWatch, Datadog, Loki) sin
 * acoplarse a ninguno por default: emite JSON estructurado a stdout y un
 * formato pretty con prefijos al mismo tiempo.
 *
 * Feature clave: **propagación automática de correlationId** vía
 * AsyncLocalStorage. Cuando se envuelve una operación con `withLogContext`,
 * todos los logs anidados (incluso en async chains profundas) llevan el
 * correlationId sin pasarlo explícito.
 */

import { AsyncLocalStorage } from 'async_hooks';

type LogLevel = 'info' | 'warn' | 'error' | 'debug';

interface LogMetadata {
  [key: string]: any;
}

/**
 * Contexto de log que se propaga automáticamente por la cadena async.
 * Extender este tipo si tu app necesita campos adicionales (ej: userId).
 */
export interface LogContext {
  correlationId?: string;
}

/**
 * AsyncLocalStorage para propagación automática del LogContext.
 */
export const logContext = new AsyncLocalStorage<LogContext>();

/**
 * Ejecuta una función dentro de un LogContext. Todos los logs emitidos
 * adentro (incluyendo chains async) llevan el correlationId.
 *
 * @example
 *   await withLogContext({ correlationId: req.id }, async () => {
 *     logger.info('Processing request');
 *     await someService.doWork(); // logs anidados también llevan el id
 *   });
 */
export function withLogContext<T>(context: LogContext, fn: () => T): T {
  return logContext.run(context, fn);
}

/**
 * Devuelve el LogContext actual (si hay uno activo).
 */
export function getLogContext(): LogContext | undefined {
  return logContext.getStore();
}

export class Logger {
  private context: string;

  constructor(context: string) {
    this.context = context;
  }

  info(message: string, metadata?: LogMetadata): void {
    this.log('info', message, metadata);
  }

  warn(message: string, metadata?: LogMetadata): void {
    this.log('warn', message, metadata);
  }

  error(message: string, metadata?: LogMetadata): void {
    this.log('error', message, metadata);
  }

  /**
   * Debug solo se emite si NODE_ENV !== 'production'.
   */
  debug(message: string, metadata?: LogMetadata): void {
    if (process.env.NODE_ENV !== 'production') {
      this.log('debug', message, metadata);
    }
  }

  private log(level: LogLevel, message: string, metadata?: LogMetadata): void {
    const timestamp = new Date().toISOString();

    // Lee correlationId del AsyncLocalStorage si está activo.
    const ctx = logContext.getStore();
    const correlationId = ctx?.correlationId;

    // Enriquece metadata con correlationId para que aparezca en JSON estructurado.
    const enrichedMetadata = {
      ...metadata,
      ...(correlationId && { correlationId }),
    };

    const logEntry = {
      timestamp,
      level,
      context: this.context,
      message,
      ...(Object.keys(enrichedMetadata).length > 0 && { metadata: enrichedMetadata }),
    };

    // Formato pretty para consola, mantiene el JSON estructurado disponible
    // para agregadores que parsean stdout.
    const levelPrefix = level === 'error' || level === 'warn' ? `[${level.toUpperCase()}]` : '';
    const correlationPrefix = correlationId ? `[${correlationId}]` : '';
    const prefix = `${timestamp} ${levelPrefix} ${correlationPrefix} [${this.context}]`.replace(/\s+/g, ' ').trim();
    const metadataStr = Object.keys(enrichedMetadata).length > 0 ? JSON.stringify(enrichedMetadata) : '';

    switch (level) {
      case 'info':
        console.log(`${prefix} ${message}`, metadataStr || '');
        break;
      case 'warn':
        console.warn(`${prefix} ${message}`, metadataStr || '');
        break;
      case 'error':
        console.error(`${prefix} ${message}`, metadataStr || '');
        break;
      case 'debug':
        console.debug(`${prefix} ${message}`, metadataStr || '');
        break;
    }

    // Hook para integraciones futuras (CloudWatch, Datadog, Sentry).
    // Mantener stdout/stderr como contrato: cualquier agregador puede
    // colectarlo desde el proceso sin acoplar el código a su SDK.
    void logEntry;
  }
}

/**
 * Factory para crear un logger asociado a un contexto (típicamente nombre
 * de servicio o módulo).
 */
export function createLogger(context: string): Logger {
  return new Logger(context);
}
