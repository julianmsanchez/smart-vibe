# Policy 01 · Security

> **Dimensión:** Security · **Pregunta nuclear:** ¿el sistema resiste ataques esperables y maneja secretos correctamente?

---

## Principio

**Los secretos nunca tocan el repo y los inputs externos nunca se confían.** Estas dos reglas resuelven el 80% de incidentes de un MVP. El resto (auth robusta, SCA, PII tagging) son evolutivos.

---

## Mínimo en `vibe`

Mapeo a las 5 reglas de oro:

- **Regla 2 — sin secretos en repo.** `.env` está en `.gitignore`. Existe `.env.example` con nombres de variables y placeholders.
- **Validación básica de inputs** — todo endpoint público valida shape y tipos antes de procesar. `zod`/`valibot` o equivalente. No es opcional aunque sea MVP.

Eso es lo único exigido en vibe. Lo demás es referencia.

---

## Checklist (referencia para graduar)

### Secret management
- [ ] `.env.example` cubre todas las vars de `.env`.
- [ ] Ningún commit pasado tiene secretos (verificar con `git log -p | grep -iE "key|secret|password|token"`; si aparece algo, rotar e historiar).
- [ ] Plan documentado para mover a secrets manager (Vault, AWS SM, Doppler) al graduar.

### Authentication & authorization
- [ ] Auth funciona en happy path con tests.
- [ ] Roles/permisos están explícitos (no "todos pueden todo").
- [ ] Sesiones tienen expiración. Tokens tienen TTL.
- [ ] MFA disponible para cuentas admin (puede ser stretch en vibe).

### Input validation & output encoding
- [ ] Todo endpoint público valida shape con schema (`zod` o equivalente).
- [ ] Outputs HTML escapados por default (framework lo hace, no desactivar).
- [ ] SQL parametrizado (no concatenación).
- [ ] Uploads de archivos validan MIME real, no extensión.

### Dependency security
- [ ] `pnpm audit` / `npm audit` corrido al menos 1 vez, vulnerabilidades CRITICAL resueltas.
- [ ] Lockfile commiteado.
- [ ] Plan para automatizar SCA (Dependabot, Renovate, Snyk) al graduar.

### Logs & PII
- [ ] No se loguean passwords, tokens, ni cookies completas.
- [ ] PII (email, teléfono, nombre completo) identificada en el data model.
- [ ] Plan de retención de logs documentado al graduar.

---

## Anti-patrones (banderas rojas)

- **Secret hardcoded** — `const API_KEY = "sk-..."` en código. Inmediato: rotar y mover a env.
- **Eval de input** — `eval(req.body.code)`. Nunca, ni en juguetes.
- **Auth por header sin verificar** — `if (req.headers["x-admin"]) ...`. Trivialmente bypasseable.
- **SQL concatenado** — `\`SELECT * FROM users WHERE email = '${req.body.email}'\``. SQL injection garantizada.
- **CORS `*` en endpoint con cookies** — robo de sesiones. Whitelist explícita.
- **Errores con stack trace al cliente** — leak de paths internos, deps, versiones. Errores genéricos al cliente, detalle al log.
- **Logs con PII** — `logger.info({ user: req.user })` cuando `user` incluye email/phone. Filtrar antes.

---

## Referencia rápida OWASP Top 10

Las 7 dimensiones cubren OWASP de la siguiente forma (mapeo extendido en `docs/framework/08-risk-taxonomy.md`):

| OWASP | Cubierto por |
|---|---|
| A01 Broken Access Control | Sub-criterio 1.2 (auth) |
| A02 Cryptographic Failures | Sub-criterio 1.1 (secrets) + 4.4 (PII) |
| A03 Injection | Sub-criterio 1.3 (input validation) |
| A04 Insecure Design | Dimensión 2 (architecture) |
| A05 Security Misconfiguration | Sub-criterio 5.4 (deployment) |
| A06 Vulnerable Components | Sub-criterio 1.4 (deps) |
| A07 Identification & Auth Failures | Sub-criterio 1.2 |
| A08 Software & Data Integrity Failures | Sub-criterio 4.5 |
| A09 Logging & Monitoring Failures | Sub-criterio 5.1 + 1.5 |
| A10 SSRF | Sub-criterio 1.3 |
