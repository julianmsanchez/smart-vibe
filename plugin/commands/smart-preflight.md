---
name: smart-preflight
description: Validación pre-deploy — lint, test, doctor, light policies check. Falla rápido antes de promover.
---

# /smart-preflight

Chequeo previo a un deploy / merge / tag. Falla rápido si algo no está en
condiciones, sin entrar a audit profundo (ese es `/smart-audit` en
celeru-pro).

## Qué chequea (en orden, falla a la primera)

1. **Working tree limpio:** sin archivos sin staged inesperados.
   - `git status --porcelain` debe estar vacío o sólo con archivos esperados.
2. **Lint:** `{{PACKAGE_MANAGER}} lint` (si existe el script).
3. **Typecheck:** `{{PACKAGE_MANAGER}} typecheck` o `tsc --noEmit` (si TS).
4. **Tests:** `{{PACKAGE_MANAGER}} test` (suite completa).
5. **doctor:** `bash scripts/doctor.sh` con exit code 0.
6. **PHS válido:** `bash scripts/doctor.sh phs validate phs.yaml`.
7. **Workshop (si aplica):** `bash scripts/doctor.sh workshop validate workshop.yaml`.
8. **Light review (opcional):** invoca al agente `reviewer` sobre el último
   commit. Reporta `block` como fail; `warn`/`info` como info.

## Argumentos

- `--skip <step>` — saltar un step (ej. `--skip lint`).
- `--review` — incluir el step 8 (light review). Off por default.
- `--quiet` — sólo errores.

## Qué NO hace

- **Audit profundo con scoring 0-5:** eso es `/smart-audit` en celeru-pro.
- **Compliance check formal:** ídem (Ley 1581, SOC 2, etc. → celeru-pro).
- **Deploy:** sólo valida; el deploy lo decidís vos. Si pasa preflight,
  el siguiente paso natural es `git push` o tu script de deploy.

## Output

```
preflight: <project> · mode=vibe

✓ working tree limpio
✓ lint     (12 archivos)
✓ typecheck
✓ test     (43 pass, 0 fail, 2.1s)
✓ doctor   (0 fails, 1 warn — phs.yaml.compliance vacío, OK en vibe)
✓ phs validate
- workshop validate (skipped, single-team)
✓ ready for promote
```

Falla:

```
preflight: <project> · mode=vibe

✓ working tree limpio
✓ lint
✗ typecheck — src/api/login.ts:42 type error
- test (skipped, blocked by typecheck)
- doctor (skipped)
- phs validate (skipped)

→ corregí typecheck y volvé a correr.
```

## Cuándo usar

- Antes de `git push` a `main` o a una rama protegida.
- Antes de un tag.
- Como step previo a `/smart-graduate` (graduate exige preflight limpio).
- En CI como sanity check.

## Cuándo NO usar

- Para chequeos de seguridad profundos (eso es `/smart-audit`).
- Para validar features individuales en mitad del trabajo (`/smart-feature` o un test runner alcanza).

## Relación con otros comandos

- `/smart-close-feature` → cierra una feature (commit + docs).
- `/smart-preflight` → valida que todo el proyecto está limpio.
- `/smart-graduate` → handoff a celeru-pro (exige preflight limpio).
- `/smart-audit` → audit profundo con scoring (vive en celeru-pro, no acá).
