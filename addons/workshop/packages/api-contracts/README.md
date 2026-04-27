# `@workshop/api-contracts`

Contratos HTTP entre teams declarados con Zod. Cada team importa el schema y los tipos derivados.

## Patrón

```typescript
// 1. En este package: declarar el schema
export const FooRequest = z.object({ /* ... */ });
export type FooRequest = z.infer<typeof FooRequest>;

// 2. En el team consumer:
import { FooRequest } from '@workshop/api-contracts';
const result = FooRequest.safeParse(req.body);

// 3. En el team provider:
import { type FooRequest } from '@workshop/api-contracts';
async function handle(input: FooRequest) { /* ... */ }
```

## Convenciones

- **Naming:** `<TeamProvider><Action><Resource>` para schemas.
  Ej: `CheckoutCreateOrderRequest`, `SearchListEventsResponse`.
- **Un archivo por dominio.** `src/checkout.ts`, `src/search.ts`. Re-exportar desde `index.ts`.
- **Versionar adentro del schema** cuando es necesario: `CheckoutV2CreateOrderRequest`. Mantener el viejo hasta que todos migren.

## Breaking changes

Política en `docs/workshop/versioning.md` y `workshop.yaml.versioning.breaking_change_policy`.

Resumen: PR atómico que actualiza el schema **y** todos los consumidores. Si no es posible (otro team está mid-flight), agregar la nueva versión sin quitar la vieja.

## TODO Fase 2

- `packages/api-clients/` — autogenerado desde estos schemas (typed fetch wrappers).
- OpenAPI export con `zod-to-openapi`.
