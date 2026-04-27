/**
 * Botón primitivo compartido.
 *
 * Tres variantes: primary, secondary, ghost. Si hace falta otra, abrir
 * discusión antes de fork-ear en un team.
 */

import type { ButtonHTMLAttributes, ReactNode } from 'react';
import { tokens } from '../tokens';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost';
  children: ReactNode;
}

export function Button({ variant = 'primary', children, style, ...rest }: ButtonProps) {
  const base: React.CSSProperties = {
    padding: `${tokens.spacing.sm} ${tokens.spacing.md}`,
    borderRadius: tokens.spacing.xs,
    fontSize: tokens.typography.fontSize.md,
    fontWeight: tokens.typography.fontWeight.medium,
    border: '1px solid transparent',
    cursor: 'pointer',
  };
  const variants: Record<string, React.CSSProperties> = {
    primary: {
      background: tokens.colors.primary,
      color: '#fff',
    },
    secondary: {
      background: tokens.colors.surface,
      color: tokens.colors.text,
      borderColor: tokens.colors.border,
    },
    ghost: {
      background: 'transparent',
      color: tokens.colors.primary,
    },
  };
  return (
    <button style={{ ...base, ...variants[variant], ...style }} {...rest}>
      {children}
    </button>
  );
}
