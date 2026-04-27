# Estrategia de branching — Smart Vibe Framework

> Recomendación de branching por modo. Pensada para que un builder no pierda tiempo decidiendo. **No es ley:** si el equipo tiene una preferencia distinta, se documenta en una ADR (`docs/decisions/`).

---

## Principio

El branching debe ser el **mínimo necesario** para el modo en el que estás. Sumar ramas complica el flujo y rara vez aporta valor en un prototipo.

| Modo | Estrategia |
|---|---|
| **vibe** | Trunk-based en `main`. Sin feature branches obligatorias. |
| **graduating** | Trunk-based + feature branches cortas + PR review obligatorio. |
| **production** | GitFlow ligero o trunk-based con release branches. Lo decide la org. |

---

## Modo `vibe` — Trunk-based en `main`

**Regla única:** todo va a `main` con commits pequeños y Conventional Commits.

- Sin feature branches a menos que exista riesgo concreto (ej: experimento que puede romper la app por días).
- Sin PR review obligatorio (eres uno o pocos, el "review" es vos releyendo el diff antes del commit).
- Sin merge commits: commits directos a `main`.
- Si necesitás aislar un experimento, usá `git worktree` o una branch corta `exp/<slug>` que se mergea con `--squash` cuando termina.

### Lo que NO hace falta en vibe

- `develop` branch.
- Release branches.
- Hotfix branches.
- Tags semver formales (v0.x.0 está OK, sin estricto SemVer).

### Lo que SÍ hace falta en vibe

- Conventional Commits para que el journal sea grep-eable.
- `git status` limpio antes de cerrar sesión (commit o stash, no dejar working tree sucio).
- Actualizar `wiki/RESUME.md` y `wiki/docs/teleport/SESSION_CONTEXT.md` antes de cierres largos.

---

## Modo `graduating` — Trunk-based con PRs

Cuando el proyecto va camino a producción, sumar:

- **Feature branches cortas:** `feat/<slug>`, vida ≤ 2 días, mergeo con `--squash`.
- **PR obligatorio:** mínimo 1 review (humano u otro agente). El PR linkea a la spec en `docs/features/`.
- **Branches protegidas:** `main` con required checks (CI, lint, tests).
- **Convención de naming:**
  - `feat/<slug>` — feature nueva.
  - `fix/<slug>` — bug fix.
  - `chore/<slug>` — tooling, deps, refactors sin cambio de comportamiento.
  - `docs/<slug>` — solo docs.
- **Tags SemVer** sí: `v0.x.y` a `v1.0.0` siguiendo SemVer estricto.

---

## Modo `production`

A partir de v1.0.0 en producción, el equipo elige y documenta en ADR:

- **Trunk-based estricto** + feature flags (recomendado para SaaS con CD).
- **GitFlow ligero** (`main` + `develop` + `release/*` + `hotfix/*`) si hay versionado de cliente desplegable.

Smart Vibe no impone uno u otro — esto lo decide la organización según madurez de su pipeline.

---

## Hooks útiles (cualquiera modo)

Sin imponer, recomendamos en `.git/hooks/` o vía herramienta como `husky`:

- `pre-commit` — corre lint y formatter sobre staged files.
- `commit-msg` — valida Conventional Commits con `commitlint`.
- `pre-push` — corre tests rápidos.

En modo vibe estos hooks son opcionales. En graduating son obligatorios.

---

## Reglas anti-pánico

1. **Nunca `git push --force` a `main`.** Si necesitás reescribir historia, abrí branch nueva.
2. **Nunca `--no-verify`.** Si un hook falla, fix o ADR explicando por qué se desactiva.
3. **Nunca `git reset --hard` sin stash previo.** El stash es gratis y salva.
4. **Si dudás, commiteá.** Un commit "WIP: …" es mejor que perder trabajo.
