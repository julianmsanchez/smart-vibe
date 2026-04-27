/**
 * Design tokens compartidos.
 *
 * Fuente de verdad visual del workshop. Importable tipado:
 *
 *   import { tokens } from '@workshop/design-system/tokens';
 *
 * Modificar acá implica un breaking change visual. Coordinar con todos los
 * teams (política en docs/workshop/versioning.md).
 */

import colors from './colors.json';
import spacing from './spacing.json';
import typography from './typography.json';

export const tokens = {
  colors,
  spacing,
  typography,
} as const;

export type Tokens = typeof tokens;
export type ColorToken = keyof typeof colors;
export type SpacingToken = keyof typeof spacing;
