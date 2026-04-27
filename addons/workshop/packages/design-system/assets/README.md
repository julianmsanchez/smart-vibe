# `assets/`

Logos, fuentes, íconos compartidos por el workshop.

Convención:

- `assets/logo/` — variantes del logo (light, dark, monochrome). SVG preferido.
- `assets/fonts/` — fuentes self-hosted si las hay (modo graduating).
- `assets/icons/` — íconos custom. Para librerías estándar (Lucide, Heroicons), instalar como dep en el team que las use.

Los assets se sirven desde el shell:

```typescript
// apps/shell/next.config.js
// Los archivos en packages/design-system/assets/ se copian a public/ en build.
```

En modo vibe está bien tener carpeta vacía y referenciar logos via URL. Materializar acá cuando el branding se estabilice.
