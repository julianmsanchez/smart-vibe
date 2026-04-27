/**
 * ThemeProvider compartido.
 *
 * El shell Next.js lo monta una vez en `app/layout.tsx`. Cada team puede leer
 * el tema con `useTheme()` para componer estilos consistentes.
 *
 * Modo vibe: tema único, derivado de tokens. En graduating se pueden agregar
 * variantes (dark mode, white-label) sin romper la API de useTheme.
 */

'use client';

import { createContext, useContext, type ReactNode } from 'react';
import { tokens, type Tokens } from '../tokens';

const ThemeContext = createContext<Tokens>(tokens);

export interface ThemeProviderProps {
  children: ReactNode;
  /** Override parcial de tokens. Útil para previewing en Storybook. */
  override?: Partial<Tokens>;
}

export function ThemeProvider({ children, override }: ThemeProviderProps) {
  const value = override ? { ...tokens, ...override } : tokens;
  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export function useTheme(): Tokens {
  return useContext(ThemeContext);
}
