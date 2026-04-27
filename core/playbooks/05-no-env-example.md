# Playbook 05 — No `.env.example`

## Síntoma

- `.env.example` ausente.
- Existe pero está vacío o desactualizado (faltan vars que el código consume).
- Onboarding documentado como "pediles las vars al lead".
- Devs nuevos rompiendo el setup porque les faltan vars.

## Por qué pasa

- Bootstrap inicial sin generar el archivo.
- Vars nuevas se agregan al código sin actualizar el example.
- Asumir que "todos saben qué vars hace falta".

## Severidad

**high.** Bloquea onboarding y hace que cada dev nuevo le robe tiempo a un dev senior.

## Fix

### 1. Detectar vars consumidas

```bash
# Buscar todos los process.env usados
grep -rhoE "process\.env\.[A-Z_][A-Z0-9_]+" src/ \
  | sort -u
```

Output esperado: lista de TODAS las vars que el código lee.

### 2. Comparar con `.env.example`

```bash
# Vars en .env.example
grep -E "^[A-Z_][A-Z0-9_]+=" .env.example | cut -d= -f1 | sort -u

# Diff con las consumidas
diff <(grep -rhoE "process\.env\.[A-Z_][A-Z0-9_]+" src/ | sed 's/process\.env\.//' | sort -u) \
     <(grep -E "^[A-Z_][A-Z0-9_]+=" .env.example | cut -d= -f1 | sort -u)
```

Cualquier var "consumida pero no documentada" es deuda.

### 3. Reescribir `.env.example`

Estructura recomendada:

```bash
# === Server ===
PORT=3000
NODE_ENV=development
LOG_LEVEL=info

# === Database ===
DATABASE_URL=postgres://localhost:5432/myapp_dev
DB_SCHEMA=public

# === Auth ===
INTERNAL_API_TOKEN=change-me-in-development
JWT_SECRET=change-me

# === External APIs ===
# OpenAI (usado en src/features/llm/)
OPENAI_API_KEY=sk-...

# === Storage (opcional) ===
# Comentar si no se usa
# S3_BUCKET=
# S3_REGION=
```

Reglas:

- Agrupar por dominio (server, db, auth, externos).
- Comentario corto sobre qué hace cada var (1 línea).
- Valores dummy realistas (no `xxx`, no `secret`).
- Vars opcionales comentadas con `#`.

### 4. Validación en runtime

El addon `node-ts` viene con `validateConfig()` en `src/config/env.ts`:

```typescript
export function validateConfig(): void {
  const required = ['DATABASE_URL', 'INTERNAL_API_TOKEN'];
  const missing = required.filter((k) => !process.env[k]);
  if (missing.length) {
    throw new Error(`Missing required env vars: ${missing.join(', ')}`);
  }
}
```

Llamar en bootstrap del server. Falla rápido si falta algo.

### 5. Workshop multi-team

Para `addons/workshop/`, ya hay `.env.shared.example` con vars cross-team. Cada team puede tener su `apps/<team>/.env.local` para vars privadas, también con su propio `.env.example`.

## Prevención

1. **Bootstrap genera `.env.example`** desde el template del addon.
2. **Pre-commit hook** que matchea `process.env.X` en código nuevo y verifica que `X` esté en `.env.example`.
3. **`doctor.sh` script** detecta gaps y los reporta como warnings.
4. **Code review**: PR que agrega `process.env.X` debe incluir update a `.env.example`.
5. **Onboarding doc** en README: `cp .env.example .env && edit .env` como primer paso después de `pnpm install`.
