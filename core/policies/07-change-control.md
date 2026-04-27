# Policy 07 · Change Control

> **Dimensión:** Change Control · **Pregunta nuclear:** ¿los cambios son trazables, reversibles y comunicables?

---

## Principio

**Cada cambio tiene que poder revertirse y explicarse.** Sin trazabilidad de cambios, debugging incidentes en prod es arqueología — buscar entre commits aleatorios qué introdujo el bug.

---

## Mínimo en `vibe`

Mapeo a las 5 reglas:

- **Regla 1 — git desde el commit 1.** Repo inicializado, archivos `.gitignore` correctos, `main` como rama base.
- **Regla 3 — Conventional Commits.** Cada commit usa `feat:`, `fix:`, `chore:`, `docs:`, etc. Esto hace el log grep-eable y permite generar changelog en graduating.

---

## Checklist (referencia para graduar)

### Version control hygiene
- [ ] Commits atómicos (un commit = un cambio coherente, no "cosas varias").
- [ ] Mensajes descriptivos: el subject explica el qué, el body explica el por qué.
- [ ] No hay archivos ignorables commiteados (`node_modules/`, `dist/`, `.env`, IDE configs).
- [ ] Working tree limpio antes de cerrar sesión (commit, stash, o branch).

### Branching strategy
- [ ] Estrategia documentada (ver `core/git-branching.md`).
- [ ] PRs con review (≥1 reviewer en graduating).
- [ ] Branches feature efímeras (≤2 días vida).
- [ ] `main` protegida (no force push, no delete).

### CHANGELOG
- [ ] Archivo `CHANGELOG.md` en raíz, formato Keep-a-Changelog.
- [ ] Cada release tiene su sección con `Added/Changed/Fixed/Removed`.
- [ ] Generado parcialmente desde Conventional Commits con tooling al graduar.

### Versioning
- [ ] SemVer estricto desde `v1.0.0` (en vibe `v0.x.y` está OK con SemVer relajado).
- [ ] Breaking changes señalados con `!` o `BREAKING CHANGE:` en el commit.
- [ ] Tag por release (`git tag v0.3.0`).

### Release process
- [ ] Release notes generadas (manual o automático).
- [ ] Rollback plan por release ("revertir tag X y redeploy" o equivalente).
- [ ] Comunicación de release a stakeholders cuando aplique.

---

## Anti-patrones (banderas rojas)

- **Commits "WIP" o "fix"** — el subject debería decir qué se fix-eó. "fix: typo en README" sí; "fix" no.
- **Commits gigantes** — 40 archivos modificados en un commit. Imposible de revisar, imposible de revertir parcialmente.
- **Force push a main** — borra historia de otros. Solo en branches propias.
- **Bypasear hooks (`--no-verify`)** — el hook está ahí por algo. Si está mal calibrado, ajustarlo.
- **`git reset --hard` sin stash previo** — perdés trabajo. Stash es gratis.
- **Mensajes de commit vacíos o copy-paste** — destruyen el journal.
- **Releases sin tag** — imposible reconstruir qué versión está en prod.
- **CHANGELOG inventado retroactivo** — si no se mantuvo en cada release, no es confiable.

---

## Conventional Commits — referencia rápida

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Tipos comunes:

- `feat` — nueva funcionalidad (bump minor en SemVer).
- `fix` — bug fix (bump patch).
- `chore` — tooling, deps, sin cambio de runtime.
- `docs` — solo documentación.
- `refactor` — cambio interno sin cambio de comportamiento.
- `test` — agregar/modificar tests.
- `ci` — pipeline CI.
- `perf` — optimización.
- `BREAKING CHANGE:` en footer o `!` después del tipo → bump major.

Ejemplos:

```
feat(auth): agregar login con magic link

fix(api): manejar timeout de provider externo retornando 503

chore: bump deps menores

docs: actualizar README con setup de DB local

feat!: cambiar contrato de POST /users (rompe clientes <v2)

BREAKING CHANGE: el campo `name` ahora se llama `fullName`.
```
