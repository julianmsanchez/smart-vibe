# Addon `node-ts`

> Addon base para proyectos `single-team` con Node.js + TypeScript + Express. Es lo que se scaffoldea cuando elegís `addon: node-ts` en el bootstrap.

---

## Qué incluye

```
addons/node-ts/
├── tsconfig.json                       # TS strict
├── package.json.tmpl                   # deps mínimas + scripts comunes
├── BACKEND_VERSION.tmpl                # trazabilidad de builds
├── .env.example                        # vars con placeholders
├── .eslintrc.json                      # lint base
├── .prettierrc.json                    # format base
├── .github/workflows/
│   ├── ci.yml.tmpl                     # CI: lint + typecheck + build + test
│   └── deploy.yml.tmpl                 # deploy DESACTIVADO (vibe)
├── src/
│   ├── app.ts.tmpl                     # createApp() con healthcheck
│   ├── config/env.ts                   # config + validateConfig()
│   ├── lib/middleware.ts               # asyncHandler + requireAuth
│   ├── middleware/adminBasicAuth.ts    # basic auth para paneles
│   └── services/logger.service.ts     # logger + AsyncLocalStorage
├── observability/
│   ├── prometheus.yml.tmpl             # scrape config base
│   └── grafana/_starter.json           # dashboard starter
├── utils/manage-server.sh              # PID/log mgmt local
└── sql/_README.md                      # convención de migraciones
```

---

## Cómo se usa

### Vía bootstrap

```bash
bash scripts/bootstrap.sh
# Tipo: single-team
# Tier: startup
# Vertical: general
# Addon: node-ts
```

El bootstrap copia los archivos del addon al directorio del proyecto, expandiendo `{{PLACEHOLDERS}}` (`{{PROJECT_NAME}}`, `{{PACKAGE_MANAGER}}`, etc.).

### Manualmente

```bash
cp -r addons/node-ts/. /path/to/mi-proyecto/
# Renombrar *.tmpl a sus nombres finales reemplazando placeholders.
```

---

## Convenciones del addon

### Logger con AsyncLocalStorage
- `createLogger('namespace')` por módulo/servicio.
- `withLogContext({ correlationId }, () => …)` propaga el id por toda la chain async sin pasarlo manualmente.
- Output: pretty a stdout + JSON estructurado disponible.

### Config centralizado
- Toda lectura de `process.env` pasa por `src/config/env.ts`.
- `validateConfig()` corre al startup (en `createApp`).

### Manage server
- `pnpm server:start|stop|restart|status|logs` envuelven `utils/manage-server.sh`.
- PID en `logs/backend.pid`, log central en `logs/backend-dev.log`.
- Configurable por env: `LOG_DIR`, `DEV_CMD`, `PROCESS_PATTERN`.

### CI
- `ci.yml.tmpl` corre lint + typecheck + build + test en PR y push a main.
- `deploy.yml.tmpl` viene desactivado (`if: false`); activarlo es señal de salida del modo vibe.

---

## Lo que NO incluye (a propósito)

- Cliente de DB específico (definilo según tu provider: `pg`, `prisma`, `drizzle`, etc.).
- Auth completa (solo basic auth para panel + skeleton de Bearer auth).
- Métricas implementadas (solo el scrape config; instrumentar con `prom-client` o similar).
- Cliente de cache, queues, etc.

Esto es a propósito: el addon resuelve **lo cross-cutting** (logger, config, hooks de CI, herramientas de dev), no impone librerías de dominio.

---

## Cómo extender

Patrones recomendados:

| Necesidad | Lugar |
|---|---|
| Nueva ruta HTTP | `src/routes/<recurso>.ts`, registrarla en `app.ts` |
| Lógica de negocio | `src/services/<dominio>.service.ts` |
| Acceso a DB | `src/data/<recurso>.repository.ts` |
| Schema validation | `src/schemas/<recurso>.schema.ts` con Zod |
| Tests | Co-localizado en `__tests__/` o `<archivo>.test.ts` |

---

## Referencias

- Plan operativo: `~/.claude/plans/hazy-sniffing-hearth.md` Bloque E
- Dimensión Ops: `core/policies/05-ops.md`
- Logger pattern source: descripción metodológica en `docs/framework/06-pipeline.md`
