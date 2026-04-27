# `seeds/`

Datos de seed para dev local y tests. Cada team aporta sus seeds; el shell consolida al levantar el monorepo en modo dev.

## Patrón

```typescript
// seeds/team-checkout/users.ts
export const seedUsers = [
  { id: 'u1', email: 'demo@example.com' },
  // ...
];
```

```typescript
// seeds/index.ts
export * from './team-checkout/users';
// ...
```

## Cuándo usar seeds vs MSW

- **Seeds** → cuando hay DB real local y querés data persistida (`pnpm db:seed`).
- **MSW** → cuando querés interceptar HTTP sin levantar nada (frontend dev pure).

## Convenciones

- IDs estables (`u1`, `order-1`) — fáciles de referenciar en tests.
- Sin datos personales reales. Usar dominios `example.com`, `test.local`.
- Cada team mantiene su carpeta `seeds/team-<id>/`.
