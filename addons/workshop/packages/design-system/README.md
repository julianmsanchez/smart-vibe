# `@workshop/design-system`

Sistema de diseño compartido del workshop. Lo usan tanto el shell como cada team. Cuatro subcarpetas:

- **`tokens/`** — JSON tokens (colores, spacing, typography). Fuente de verdad visual. Se importan tipados.
- **`theme/`** — `ThemeProvider` para Next.js. El shell lo monta una vez en `app/layout.tsx`.
- **`components/`** — primitivos compartidos (Button, Input). Cada team los puede usar o componer.
- **`assets/`** — logos, fuentes, íconos. Se referencian por path desde el shell.

## Filosofía

**Tokens > componentes.** En modo vibe priorizar que todos los teams pinten desde la misma paleta y respeten spacing. Componer botones idénticos puede esperar; tener colores divergentes no.

## Uso

```typescript
// Importar tokens
import { tokens } from '@workshop/design-system/tokens';
const primary = tokens.colors.primary;

// Wrappear shell con ThemeProvider
import { ThemeProvider } from '@workshop/design-system/theme';

// Usar primitivos
import { Button, Input } from '@workshop/design-system/components';
```

## Override por team

Si un team necesita una variación visual: crear un wrapper en su propio package, **no** mutar tokens compartidos. Si la variación es estructural (otra paleta para una vertical), abrir issue y discutir antes de crear `tokens-<vertical>.json`.

## Versioning

`workspace:*`. Breaking changes en tokens/components vía PR atómico que actualiza a todos los consumidores. Política completa en `docs/workshop/versioning.md`.

## TODO Fase 2

- Style Dictionary integration (export a CSS/iOS/Android).
- Storybook para `components/`.
- Dark mode tokens.
