/**
 * Contratos HTTP entre teams.
 *
 * Cada endpoint inter-team se declara acá con un schema Zod (request +
 * response). Los teams emisor/receptor importan los tipos derivados con
 * `z.infer` y validan en el wire.
 *
 * Cuando un team rompe un contrato, TS rompe en los consumidores y el PR
 * lockea hasta que se actualicen (policy en
 * workshop.yaml.versioning.breaking_change_policy).
 */

import { z } from 'zod';

/**
 * Ejemplo de contrato. Borrar y reemplazar por los reales del workshop.
 *
 * Convención de naming: `<TeamProvider><Action><Resource>`.
 */
export const CheckoutCreateOrderRequest = z.object({
  userId: z.string().uuid(),
  items: z
    .array(
      z.object({
        sku: z.string(),
        qty: z.number().int().positive(),
      })
    )
    .min(1),
});
export type CheckoutCreateOrderRequest = z.infer<typeof CheckoutCreateOrderRequest>;

export const CheckoutCreateOrderResponse = z.object({
  orderId: z.string().uuid(),
  total: z.number().nonnegative(),
});
export type CheckoutCreateOrderResponse = z.infer<typeof CheckoutCreateOrderResponse>;
