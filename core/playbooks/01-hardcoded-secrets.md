# Playbook 01 — Hardcoded secrets

## Síntoma

API keys, passwords, tokens o connection strings literales en el código:

```typescript
const apiKey = "sk-abc123..."; // ❌
const dbUrl = "postgres://user:pass@host/db"; // ❌
```

O en archivos versionados:

- `.env` (en lugar de `.env.example`).
- `config.json` con valores reales.
- Logs commiteados que filtran credenciales.

## Por qué pasa

- Conveniencia inicial: "lo arreglo después".
- Falta de `.env.example` que sirva de plantilla.
- Hooks pre-commit ausentes.
- Copy-paste de configs entre proyectos sin sanitizar.

## Severidad

**critical.** Si la key llega a un repo público o aunque sea privado pero accesible a más gente de la necesaria, asumí filtración → rotar.

## Fix

### 1. Detectar el alcance

```bash
# Buscar patrones comunes
grep -rE "(sk-[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}|api[_-]?key.*=.*['\"]\w{16,})" \
  --include="*.ts" --include="*.js" --include="*.json" .

# Historial de git
git log -p | grep -iE "(api_key|secret|password|token).*=.*['\"]"
```

### 2. Rotar la credencial

**Antes** de hacer cualquier otra cosa: invalidar la key vieja en el provider (OpenAI, AWS, etc.) y emitir una nueva. Asumí que ya está comprometida.

### 3. Mover a env var

```typescript
// Antes
const apiKey = "sk-abc123";

// Después
const apiKey = process.env.OPENAI_API_KEY;
if (!apiKey) throw new Error("OPENAI_API_KEY required");
```

### 4. Agregar a `.env.example`

```bash
# .env.example
OPENAI_API_KEY=sk-...your-key-here...
```

Y a `.gitignore`:

```
.env
.env.local
.env.*.local
```

### 5. Limpiar el historial (si fue commiteado)

```bash
# Si la key estaba en commits, reescribir historial
git filter-repo --invert-paths --path .env  # o el archivo afectado
git push --force-with-lease  # SI Y SOLO SI la rama es tuya
```

Si el repo es público, reescribir historial **no** evita que copias caché en GitHub Archive existan. Asumí filtrada, ya rotaste, todo bien.

## Prevención

1. **Pre-commit hook** con `gitleaks` o `git-secrets`:
   ```bash
   brew install gitleaks
   gitleaks protect --staged
   ```
2. **`.env.example` siempre** en proyectos smart-vibe (lo crea el bootstrap).
3. **Filter regex** local que falla el commit si matchea (ver `core/policies/01-security.md`).
4. **Code review**: cualquier `=` con string largo en config files merece doble check.
5. **Modo graduating**: secrets manager (AWS Secrets, Vault) en lugar de dotenv.
