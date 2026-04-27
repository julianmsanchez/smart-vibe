# `@workshop/config`

Configuraciones compartidas: ESLint, Prettier, TypeScript. Cada team y package extiende de acá.

## Contenido

- `eslint-base.cjs` — reglas TS base (sin React).
- `eslint-react.cjs` — extiende base + React/React Hooks.
- `prettier.config.cjs` — Prettier compartido.
- `tsconfig.base.json` — tsconfig base (`strict: true`, `target: ES2022`).

## Uso

### ESLint (team backend / package puro TS)

```js
// .eslintrc.cjs
module.exports = {
  extends: [require.resolve('@workshop/config/eslint-base')],
};
```

### ESLint (team frontend / app Next.js)

```js
module.exports = {
  extends: [require.resolve('@workshop/config/eslint-react')],
};
```

### Prettier

```js
// prettier.config.cjs (raíz del monorepo o del team)
module.exports = require('@workshop/config/prettier');
```

### TypeScript

```json
// tsconfig.json
{
  "extends": "@workshop/config/tsconfig",
  "compilerOptions": { "outDir": "dist" },
  "include": ["src/**/*"]
}
```

## Extender

Si tu team necesita una regla extra, **agregala en tu `.eslintrc.cjs` local**, no modifiques el config compartido. Si la regla pinta para todos, PR al config base.

## Política de cambios

Cambiar reglas acá afecta a todos los teams. Antes de abrir PR:

1. Confirmar que la regla no rompe builds existentes (correr `pnpm lint` en raíz).
2. Si rompe, agregar autofix o coordinar migración.
