# Architecture · addon `node-ts`

> Cómo se organiza un proyecto generado con este addon. Pensado para que un agente o colaborador nuevo pueda navegar el código en menos de 5 minutos.

---

## Capas

```
┌────────────────────────────────────────┐
│   server.ts        ← levanta el server │
│       │                                │
│       ▼                                │
│   app.ts          ← createApp() arma   │
│       │             middlewares + rutas│
│       ▼                                │
│   routes/         ← HTTP handlers      │
│       │                                │
│       ▼                                │
│   services/      ← lógica de dominio   │
│       │                                │
│       ▼                                │
│   data/          ← acceso a DB / APIs  │
└────────────────────────────────────────┘
              ▲
              │
        config/, lib/, schemas/  (transversal)
```

**Reglas de imports:**
- `routes/` puede importar de `services/`, `schemas/`, `lib/`, `config/`.
- `services/` puede importar de `data/`, `schemas/`, `lib/`, `config/`.
- `data/` puede importar de `schemas/`, `lib/`, `config/`.
- **Nunca** invertir (services no importa routes; data no importa services).

---

## Archivos transversales

### `src/config/env.ts`
- Único punto que lee `process.env`.
- Exporta el objeto `config` (todo el mundo lo importa).
- `validateConfig()` corre al startup, falla rápido si falta algo crítico.

### `src/services/logger.service.ts`
- `createLogger(namespace)` por contexto.
- `withLogContext({ correlationId }, fn)` propaga ID por AsyncLocalStorage.
- Output dual: pretty para humanos, structured fields para agregadores.

### `src/lib/middleware.ts`
- `asyncHandler` para envolver handlers async sin try/catch boilerplate.
- `requireAuth` skeleton de Bearer auth.

### `src/middleware/adminBasicAuth.ts`
- Basic Auth para paneles internos. Lee `ADMIN_PANEL_USER/PASSWORD` del env.

---

## Flujo de un request típico

```
1. HTTP request entra
2. Middleware express.json() parsea body
3. Middleware correlation-id genera/lee x-correlation-id
   y arranca un withLogContext({ correlationId })
4. Router matchea la ruta → handler en routes/
5. Handler valida input con schema (Zod) → invoca services/
6. Service ejecuta lógica → invoca data/
7. Data ejecuta query → retorna
8. Service retorna DTO → handler responde
9. Si error en cualquier paso → asyncHandler lo pasa a error middleware
10. Error middleware loguea con correlationId y responde 500 (o lo que sea)
```

---

## Decisiones del addon

### TypeScript strict
- `tsconfig.json` con `strict: true`. No negociable.
- `any` solo justificado con comentario.

### Express, no fastify/hono
- Familiar, ecosistema enorme, suficiente para vibe.
- Migrar a fastify/hono al graduar si performance lo justifica (ADR).

### Vitest, no Jest
- Más rápido, integra con TS sin Babel.
- API compatible con Jest para que el cambio no duela.

### Pino-style logger custom (no Pino directo)
- El logger del addon usa `console.*` con formato pretty + structured logs disponibles.
- Esto evita dependencia hard a Pino y permite swap a Winston/Bunyan/Datadog SDK fácil.

### `pnpm` por default
- Más rápido que npm, deps deduplicadas.
- Compatible con Turborepo cuando se gradúa a workshop.

### Manage-server.sh con PID file
- Para dev local, evita procesos huérfanos al hacer `pnpm dev` repetidamente.
- En graduating se reemplaza por process manager (PM2, systemd, contenedor).

---

## Tests

Convención: `<archivo>.test.ts` co-localizado o `__tests__/` por carpeta.

```
src/
├── services/
│   ├── user.service.ts
│   └── user.service.test.ts   ← unit
└── routes/
    ├── users.route.ts
    └── __tests__/
        └── users.route.test.ts ← integration con supertest
```

Tipos:
- **Unit** — service/data en aislamiento, mocks de deps externas.
- **Integration** — `supertest(app)` para rutas HTTP completas.
- **E2E** — cuando aplica, contra DB de test (Docker compose).

---

## Cuando crece

Patrones para cuando el addon-base no alcanza:

| Necesidad | Patrón |
|---|---|
| >5 servicios | Carpeta por dominio (`src/users/`, `src/orders/`) en vez de capas globales |
| Queues / async | `src/workers/` con poll loop, separado del HTTP server |
| Múltiples APIs externas | `src/clients/<provider>.client.ts` con retry/circuit breaker |
| Auth real (no Bearer mock) | `src/auth/` con provider adapter |
| RBAC | `src/auth/policies.ts` con casbin o casl |

Cuando varios de estos aparecen, considerar pasar a `graduating` con celeru-pro: muchos de estos patrones se evalúan en la auditoría 0-5.

---

## Referencias

- Policy code-quality: `core/policies/03-code-quality.md`
- Policy ops: `core/policies/05-ops.md`
- ADR de stack base: en el proyecto del builder, no acá.
