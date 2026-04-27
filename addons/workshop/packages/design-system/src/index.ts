/**
 * Re-export raíz del design-system.
 *
 * Para imports más específicos preferí los subpaths:
 * - `@workshop/design-system/tokens`
 * - `@workshop/design-system/theme`
 * - `@workshop/design-system/components`
 */

export { tokens } from '../tokens';
export { ThemeProvider, useTheme } from '../theme';
export { Button, Input } from '../components';
