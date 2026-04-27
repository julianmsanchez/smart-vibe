# 04 · Las 5 Reglas de Oro

> Las **5 Reglas de Oro** son las únicas reglas obligatorias en modo vibe. Si tu proyecto las cumple, está en L1 como mínimo y `smart-vibe` lo considera saludable. Las 7 dimensiones de auditoría existen pero no son gates en este modo (ver `00-principles.md` § 7).

> Cada regla tiene un **anti-patrón** (lo que se ve cuando NO se cumple) y un **patrón** (cómo se ve cuando sí). El framework no te pide más que esto en vibe.

---

## Regla 1 · Tenés un PHS y declarás tu modo

**Por qué:** sin PHS no hay graduación posible, y sin modo declarado el framework no sabe qué exigirte. El PHS es el contrato mínimo entre vos, el framework y tu yo del futuro.

### Anti-patrón
```
mi-prototipo/
├── README.md
├── package.json
└── src/
```
Sin `phs.yaml`. El stack está inferido del package.json. Las decisiones (vertical, tier, addons) solo viven en la cabeza del builder. Quien quiera entender el proyecto tiene que abrir 5 archivos.

### Patrón
```
mi-prototipo/
├── phs.yaml          ← declara: name, mode, type, vertical, tier, stack, addons
├── README.md
├── package.json
└── src/
```

```yaml
# phs.yaml (mínimo aceptable)
project:
  name: mi-prototipo
  mode: vibe
  type: single-team
  vertical: general
  tier: startup
stack:
  language: typescript
  runtime: node@20
  framework: express
  addon: node-ts
addons: [node-ts]
```

**Cómo se chequea:** `bash scripts/doctor.sh phs validate phs.yaml`.

---

## Regla 2 · No hay secretos en el repo

**Por qué:** un secreto que entra al repo entra a la historia de git, y removerlo después es doloroso (git filter-repo, rotación de credenciales, etc.). Es la #1 causa de incidentes de seguridad en prototipos.

### Anti-patrón
```javascript
// src/config.js
export const DB_URL = "postgres://user:pass@host/db";
export const OPENAI_KEY = "sk-...";
```

```bash
$ cat .env
OPENAI_KEY=sk-...
DATABASE_URL=postgres://...
```
…con `.env` **no** en `.gitignore`.

### Patrón
```javascript
// src/config.js
export const DB_URL = process.env.DB_URL ?? throwError("DB_URL not set");
export const OPENAI_KEY = process.env.OPENAI_KEY ?? throwError("OPENAI_KEY not set");
```

```bash
$ cat .gitignore
.env
.env.local
.env.*.local

$ cat .env.example       # ← este sí va al repo
DB_URL=postgres://placeholder
OPENAI_KEY=sk-placeholder
```

**Cómo se chequea:**
- `.env*` en `.gitignore` (excepto `.env.example`).
- Búsqueda básica: `grep -rE "(api[_-]?key|secret|token|password)\s*[:=]\s*['\"][a-zA-Z0-9]{16,}" src/` debería estar vacío.
- `doctor.sh` corre estos checks en modo vibe.

---

## Regla 3 · Hay git desde el primer minuto, con Conventional Commits

**Por qué:** sin git no hay rollback, sin commits estructurados no hay journal de decisiones, sin journal no hay graduación. El bootstrap inicializa git automáticamente; mantenerlo limpio es responsabilidad del builder.

### Anti-patrón
```bash
$ git log --oneline
a8f3c21 wip
b1d4e5a wip 2
c9f2a3b stuff
d8e4f1a more stuff
```

O peor:
```bash
$ git status
fatal: not a git repository
```

O:
```bash
$ git status
On branch main
Untracked files:
  src/
  package.json
  README.md
nothing added to commit but untracked files present
```

### Patrón
```bash
$ git log --oneline
e7a3b2c feat: add user authentication endpoint
d4f5a1c chore: bump pnpm to v9
c1b2d3e docs: README setup section
b9c8d7e fix: handle null in token parser
a1b2c3d chore: init repo + LICENSE + .gitignore + README
```

Reglas concretas:
- Repo inicializado con `git init` (lo hace el bootstrap).
- Cada commit usa Conventional Commits (`feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`).
- Commit por bundle coherente, no por archivo suelto.
- `main` es la branch de trabajo principal.

**Cómo se chequea:** el bootstrap garantiza el primer commit. `doctor.sh` chequea que existe `.git/` y que los últimos N commits siguen Conventional Commits.

---

## Regla 4 · Hay README + CLAUDE.md mínimos

**Por qué:** un colaborador (humano o agente) que llega al repo debe poder entender en **<5 minutos** qué es el proyecto y cómo correrlo. Si no, cada onboarding es un costo escondido que se paga 100x cuando llega el momento de graduar.

### Anti-patrón
```markdown
# my-app

TODO: add description
```

O directamente: sin README. O un README de 2000 líneas que nunca está actualizado.

### Patrón

**README.md mínimo:**
```markdown
# nombre-proyecto

> Una línea sobre qué hace.

## Setup
\`\`\`bash
pnpm install
cp .env.example .env
# editar .env con valores reales
pnpm dev
\`\`\`

## Stack
- Node 20 + TypeScript + Express
- PHS en modo vibe (ver `phs.yaml`)

## Comandos
- `pnpm dev` — corre local
- `pnpm test` — corre tests
- `pnpm lint` — lintea
```

**CLAUDE.md mínimo** (lo genera el bootstrap, basado en el addon):
- Identidad del proyecto.
- Stack y convenciones.
- Comandos importantes.
- Cuando dudar, qué leer.

**Cómo se chequea:** `doctor.sh` verifica que ambos archivos existen y no están vacíos. No valida calidad del contenido (es modo vibe).

---

## Regla 5 · Las decisiones grandes son visibles

**Por qué:** una decisión arquitectónica tomada en silencio es deuda técnica con interés compuesto. En modo vibe **no exigimos ADRs formales** para todo, pero sí que las decisiones **grandes** queden visibles en algún lado.

### Qué cuenta como "decisión grande" en vibe

- Elección de DB / hosting / cloud provider.
- Elección de auth provider.
- Pagar por un servicio externo (OpenAI, Supabase, etc.).
- Cambio de lenguaje o framework principal.
- Activación de un addon nuevo.

### Anti-patrón

```bash
$ git log --oneline | head
a8f3c21 feat: integration

$ cat src/db.ts
import { createClient } from '@supabase/supabase-js';
// ...
```
Decisión "usar Supabase" tomada sin rastro: no aparece en el commit message, no hay ADR, no está en el PHS, no está en README.

### Patrón

**Mínimo aceptable en vibe** (cualquiera de estas tres opciones):

#### Opción A — commit message explícito
```
feat: add Supabase integration for user data

- Reason: free tier suficiente para MVP, postgres + auth combinados.
- Alternativas: PlanetScale (no auth), Firebase (vendor más cerrado).
- Decisión revisable cuando tier=corporate.
```

#### Opción B — campo en PHS
```yaml
# phs.yaml
data:
  primary_db: supabase-postgres
auth:
  provider: supabase-auth

decisions:
  - id: 0001
    title: stack-data
    summary: Supabase como DB+auth en MVP. Free tier OK hasta 50K usuarios.
    file: docs/decisions/0001-stack-data.md  # o ~ si todavía no escribiste el ADR
    status: accepted
```

#### Opción C — ADR liviana en `docs/decisions/`
```markdown
# 0001 · Stack de datos: Supabase

- **Status:** Accepted
- **Date:** 2026-04-27
- **Decisión:** Supabase para DB (postgres) + auth.
- **Razón:** free tier suficiente, auth + DB en un solo provider, baja fricción.
- **Alternativas descartadas:** PlanetScale (sin auth), Firebase (vendor más cerrado).
- **Cuándo revisar:** al graduar a tier corporate o cuando lleguemos a 30K usuarios.
```

En **graduating**, la opción C se vuelve obligatoria. En vibe basta cualquiera de las tres.

**Cómo se chequea:** no hay validador automático en vibe (sería ruidoso). El `/smart-graduate` chequea que para los campos críticos del PHS (data, auth, infra) exista al menos una de las tres opciones.

---

## Cómo se chequean las 5 reglas

```bash
bash scripts/doctor.sh
```

Salida esperada en un proyecto saludable:
```
✓ Regla 1 — PHS válido (mode: vibe, 8 campos pendientes)
✓ Regla 2 — No secretos en repo
✓ Regla 3 — Git inicializado, últimos 10 commits siguen Conventional Commits
✓ Regla 4 — README.md y CLAUDE.md presentes
~ Regla 5 — No se valida automáticamente en vibe (revisión manual al graduar)

Estado: L1 (Vibe). Sigue vibeando 🚀
```

Si una regla falla, `doctor.sh` reporta el problema y sugiere fix. **No bloquea**: en modo vibe es info, no gate.

---

## Lo que NO está en las 5 reglas (a propósito)

Estas cosas son **buena práctica** y aplicarán en graduating, pero **no son obligatorias en vibe**:

- Tests con cobertura mínima.
- Linter configurado y verde.
- CI/CD operativo.
- Observability (métricas, alertas).
- Runbooks operativos.
- Auditoría de seguridad.
- Documentación de API.
- Política de branching (gitflow, trunk-based, etc.).

Cada una de estas pertenece a una de las 7 dimensiones (`05-audit-dimensions.md`). En modo vibe son referencia hacia graduating, no checks activos.

---

## Referencias

- `00-principles.md` § 2 (bases mínimas)
- `01-maturity-model.md` (L1 corresponde a las 5 reglas cumplidas)
- `03-phs-spec.md` (Regla 1)
- `05-audit-dimensions.md` (las 7 dimensiones que NO son obligatorias en vibe)
