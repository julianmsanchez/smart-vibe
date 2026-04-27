# `@workshop/auth`

Adapter de auth compartido. Cada team usa esta interfaz; el shell inyecta el adapter real (Auth0, Cognito, Clerk, Supabase Auth, custom).

## Por qué adapter

Dos problemas que resuelve:

1. **Swap de provider** sin tocar a los teams.
2. **Tests** — los teams pueden mockear `AuthAdapter` sin saber del provider real.

## Uso desde un team

```typescript
import { type AuthAdapter } from '@workshop/auth';

export function makeRoutes(auth: AuthAdapter) {
  app.get('/profile', async (req, res) => {
    const session = await auth.getSession(req);
    if (!session) return res.status(401).end();
    if (!auth.requireRole(session, ['user'])) return res.status(403).end();
    res.json({ userId: session.userId });
  });
}
```

## Implementar un provider real

Crear un archivo `src/providers/<provider>.ts` que implemente `AuthAdapter`:

```typescript
import type { AuthAdapter, Session } from '../index';

export class Auth0Adapter implements AuthAdapter {
  async getSession(req) { /* … */ }
  // …
}
```

Y exportarlo desde `src/index.ts`. El shell elige cuál instanciar según `workshop.yaml`.

## TODO Fase 2

- Sección `auth` en `workshop.yaml` que declara provider + config.
- Adapters concretos (Auth0, Supabase, Clerk) como sub-paquetes opt-in.
