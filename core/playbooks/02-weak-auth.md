# Playbook 02 — Weak auth

## Síntoma

Endpoints sensibles sin auth o con auth débil:

```typescript
// ❌ Sin auth
app.delete("/users/:id", async (req, res) => { /* ... */ });

// ❌ Auth "casero" sin validar nada
app.post("/admin/foo", (req, res) => {
  if (req.headers["x-admin"] === "true") { /* ... */ }
});

// ❌ Comparación en plano de tokens (timing attacks)
if (token === process.env.SECRET_TOKEN) { /* ... */ }
```

O síntomas indirectos:

- 401/403 inconsistente entre endpoints similares.
- Tests que pasan con cualquier header.
- Logs muestran que requests sin auth llegan a handlers.

## Por qué pasa

- Prototipado rápido en modo vibe sin agregar middleware.
- Copy-paste de rutas públicas a rutas que deberían ser privadas.
- Auth implementada en frontend pero no en backend.
- Falta de un `requireAuth` middleware compartido.

## Severidad

**high.** En modo vibe puede ser tolerable si el proyecto no expone datos reales. En graduating es bloqueante.

## Fix

### 1. Catalogar endpoints

Listar TODOS los endpoints y clasificar:

| Endpoint | Público | User auth | Admin auth |
|---|---|---|---|
| GET /health | ✓ | | |
| GET /users/:id | | ✓ | |
| DELETE /users/:id | | | ✓ |
| GET /admin/* | | | ✓ |

### 2. Aplicar middleware compartido

El addon `node-ts` ya viene con `src/lib/middleware.ts` exportando `requireAuth`:

```typescript
import { requireAuth } from './lib/middleware';

// Endpoint user-auth
app.get("/users/:id", requireAuth, handler);

// Endpoint admin (nivel extra)
app.delete("/users/:id", requireAuth, requireAdmin, handler);
```

Para workshop, usar `@workshop/auth`:

```typescript
import type { AuthAdapter } from '@workshop/auth';

app.get('/profile', async (req, res) => {
  const session = await auth.getSession(req);
  if (!session) return res.status(401).end();
  if (!auth.requireRole(session, ['user'])) return res.status(403).end();
  res.json({ userId: session.userId });
});
```

### 3. Test de regresión

Por cada endpoint protegido, un test que verifica:

- Sin token → 401.
- Token inválido → 401.
- Token válido pero rol insuficiente → 403.
- Token válido + rol OK → 200.

```typescript
it("rechaza request sin auth", async () => {
  const res = await request(app).delete("/users/1");
  expect(res.status).toBe(401);
});
```

### 4. Comparación segura de tokens

Usar `crypto.timingSafeEqual` en lugar de `===`:

```typescript
import { timingSafeEqual } from 'crypto';

const a = Buffer.from(received);
const b = Buffer.from(expected);
const valid = a.length === b.length && timingSafeEqual(a, b);
```

## Prevención

1. **Default deny:** middleware que requiere auth en todo el `/api/*`, con whitelist explícita para endpoints públicos.
2. **Linter rule** que detecta `app.METHOD` sin middleware en el path.
3. **Tests de auth obligatorios** en CI para endpoints sensibles.
4. **Code review**: cada endpoint nuevo debe pasar por la tabla "Público/User/Admin".
5. **Modo graduating**: agregar audit log de cada acción autenticada.
