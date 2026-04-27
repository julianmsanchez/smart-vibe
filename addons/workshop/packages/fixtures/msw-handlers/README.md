# `msw-handlers/`

[MSW](https://mswjs.io/) handlers compartidos. Permiten correr el frontend sin que ningún backend esté arriba.

## Activación

En el shell o cualquier app frontend:

```typescript
// apps/shell/src/mocks/setup.ts
if (process.env.NEXT_PUBLIC_MOCKS === 'true') {
  const { worker } = await import('@workshop/fixtures/msw-handlers');
  await worker.start();
}
```

Levantar con `MOCKS=true pnpm dev`.

## Patrón

```typescript
// msw-handlers/team-checkout.ts
import { http, HttpResponse } from 'msw';
import { CheckoutCreateOrderResponse } from '@workshop/api-contracts';

export const checkoutHandlers = [
  http.post('/api/checkout/orders', () => {
    return HttpResponse.json({
      orderId: '00000000-0000-0000-0000-000000000001',
      total: 100,
    } satisfies CheckoutCreateOrderResponse);
  }),
];
```

```typescript
// msw-handlers/index.ts
import { setupWorker } from 'msw/browser';
import { checkoutHandlers } from './team-checkout';

export const worker = setupWorker(...checkoutHandlers);
```

## Convenciones

- Un archivo por team. Cada team mantiene sus handlers.
- Validar respuestas con `satisfies <ResponseSchema>` para que TS rompa si los contratos cambian.
- Sin lógica compleja. Si el mock necesita estado, considerá hacer un mini-server local.
