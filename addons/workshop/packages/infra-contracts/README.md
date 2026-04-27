# `@workshop/infra-contracts`

Tipos TS de la infra compartida declarada en `workshop.yaml`. Cada team importa los configs tipados acá en lugar de leer env vars sueltas.

## Mapeo a `workshop.yaml`

```
workshop.yaml ─┬─→ shared_infra.apis_external  → src/apis-external.ts
               ├─→ shared_infra.databases       → src/databases.ts
               └─→ shared_infra.storage         → src/storage.ts
```

En MVP estos archivos son **escritos a mano** y deben mantenerse en sync con `workshop.yaml`. En Fase 2 se autogeneran al validar el manifest.

## Uso

```typescript
import { OPENAI_CONFIG } from '@workshop/infra-contracts/apis-external';
import { DB_CONFIG } from '@workshop/infra-contracts/databases';
import { UPLOADS_BUCKET } from '@workshop/infra-contracts/storage';

const apiKey = OPENAI_CONFIG.envVar; // "OPENAI_API_KEY"
```

## Por qué tiparlo

1. Si el shell renombra `OPENAI_API_KEY` a `LLM_API_KEY`, TS rompe acá y el team se entera al instante.
2. Si un team intenta usar una API que no tiene declarado `access`, lo detectamos por convención.
3. Documentación viva: leer `apis-external.ts` te dice qué APIs existen sin abrir `workshop.yaml`.

## TODO Fase 2

- Codegen automático desde `workshop.yaml` (`pnpm workshop:gen`).
- Helper `assertAccess(teamId, service)` con runtime check.
