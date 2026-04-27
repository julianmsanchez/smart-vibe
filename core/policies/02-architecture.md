# Policy 02 · Architecture

> **Dimensión:** Architecture · **Pregunta nuclear:** ¿la estructura del sistema es coherente, escalable y comprensible?

---

## Principio

**La estructura debe poder explicarse en 30 segundos a un colaborador nuevo.** Si necesita un mapa mental complejo para entender por qué los archivos están donde están, la arquitectura está fallando — sin importar cuán "elegante" sea internamente.

---

## Mínimo en `vibe`

Mapeo a las 5 reglas de oro:

- **Estructura de carpetas razonable** — la trae el addon (`addons/node-ts/` o `addons/workshop/`). No reorganizar caprichosamente.
- **Regla 5 — ADRs para decisiones grandes.** Decisiones que un futuro yo (o agente) no podrá deducir del código → escribir ADR en `docs/decisions/`.

Eso es lo único exigido en vibe.

---

## Checklist (referencia para graduar)

### Separation of concerns
- [ ] Capas mínimas presentes: `routes/controllers` → `services` → `data/repositories`. No mezclar.
- [ ] Funciones HTTP no contienen queries SQL directas.
- [ ] Lógica de dominio no depende del framework HTTP.

### Coupling & cohesion
- [ ] Imports unidireccionales: `services/` no importa de `routes/`.
- [ ] Sin imports circulares (lint con `eslint-plugin-import` o `madge`).
- [ ] Módulos por dominio (`users/`, `orders/`) en lugar de por capa global cuando el proyecto crece.

### Scalability path
- [ ] Bottleneck conocido y documentado (DB, API externa, CPU).
- [ ] Plan para horizontal scaling cuando aplique (stateless services, sticky sessions evitadas).
- [ ] Idempotencia en operaciones que se reintentan.

### Error handling strategy
- [ ] Tipos de error definidos (`AppError`, `ValidationError`, `NotFoundError`).
- [ ] Errores propagados con contexto (`{ cause }`, correlation ID).
- [ ] Top-level handler que mapea errores a respuestas HTTP coherentes.

### ADRs
- [ ] ADR para elección de DB.
- [ ] ADR para elección de framework HTTP.
- [ ] ADR para deployment target (Lambda, Fargate, k8s, etc.).
- [ ] ADR para auth strategy.

---

## Anti-patrones (banderas rojas)

- **God file** — un archivo de >800 líneas que hace 5 cosas distintas. Refactor a módulos.
- **Routes con queries directas** — `app.get("/users", (req,res) => db.query(...))`. Saltea capa de servicio.
- **Imports circulares** — A importa B, B importa A. Suele indicar boundary mal puesto.
- **"Por si acaso"** — capa de abstracción sin ningún consumer concreto. YAGNI.
- **Singleton mutable global** — `let cache = {}` exportado. Difícil de testear, race conditions.
- **Errores silenciados** — `try { ... } catch {}`. Un error que no se loguea no existe hasta que rompe en prod.
- **ADR retroactiva** — escribir la ADR justificando lo ya hecho. Vale, pero entonces es post-mortem; renombrar.
