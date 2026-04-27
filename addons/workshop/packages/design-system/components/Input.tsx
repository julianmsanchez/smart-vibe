/**
 * Input primitivo compartido.
 */

import type { InputHTMLAttributes } from 'react';
import { tokens } from '../tokens';

export interface InputProps extends InputHTMLAttributes<HTMLInputElement> {}

export function Input({ style, ...rest }: InputProps) {
  const base: React.CSSProperties = {
    padding: `${tokens.spacing.sm} ${tokens.spacing.md}`,
    fontSize: tokens.typography.fontSize.md,
    border: `1px solid ${tokens.colors.border}`,
    borderRadius: tokens.spacing.xs,
    background: tokens.colors.background,
    color: tokens.colors.text,
    outline: 'none',
  };
  return <input style={{ ...base, ...style }} {...rest} />;
}
