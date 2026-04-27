# `apps/shell/`

Shell Next.js que orquesta la UI del workshop. Monta cada team en `/{team_id}` (configurable en `workshop.yaml.shell.mounts_teams_at`).

## Responsabilidades

- Layout global (header, navegación entre teams).
- ThemeProvider del design-system aplicado a todos los teams.
- Routing de `/{team_id}` a la app del team correspondiente (vía rewrites/proxies o renderizado directo según el modo).
- Página landing con la lista de teams.

## NO responsabilidades

- Lógica de dominio de los teams (eso vive en `apps/<team>/`).
- Auth real (eso es `packages/auth/`).
- Datos compartidos (eso es `packages/types/` + `packages/api-contracts/`).

## Cómo correr

```bash
# Solo shell:
pnpm dev --filter=@workshop/shell

# Shell + un team:
pnpm dev --filter=@workshop/shell --filter=...team-checkout
```

## Routing entre teams

Tres opciones según el modo del workshop:

1. **Iframe (más simple)** — `/{team_id}` renderiza un iframe apuntando al dev server del team.
2. **Reverse proxy (Next.js rewrites)** — `next.config.js` con rewrites a los servers de cada team.
3. **Bundling completo** — cada team se compila como package y el shell los importa directamente.

V0.1.0 deja la decisión al builder; el shell scaffolded usa la opción 1 (iframe) por simplicidad.
