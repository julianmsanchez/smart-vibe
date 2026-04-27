# `@workshop/types`

Tipos compartidos cross-team.

## Qué va acá

- Entidades del dominio común (User, Order, etc. si son compartidas).
- Identificadores comunes (`UUID`, `ISODateString`, `TeamId`).
- Wrappers estándar (`Paginated<T>`, `ApiError`).
- Enums compartidos.

## Qué NO va acá

- Tipos de un solo team — esos quedan en `apps/<team>/src/types/`.
- Schemas Zod completos — esos van a `@workshop/api-contracts`.
- Lógica de runtime — solo `type` e `interface`.

## Cómo extender

Agregar al `index.ts` o crear archivos por dominio (`src/users.ts`, `src/orders.ts`) y re-exportar.

## Versionado

`workspace:*` (sin SemVer). Breaking changes = PR atómico que actualiza tipos + consumidores. Política completa en `docs/workshop/versioning.md`.
