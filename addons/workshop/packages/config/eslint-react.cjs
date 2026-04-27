/**
 * ESLint para apps/packages con React (shell, design-system, teams frontend).
 * Extiende `eslint-base.cjs`.
 */

const base = require('./eslint-base.cjs');

/** @type {import('eslint').Linter.Config} */
module.exports = {
  ...base,
  plugins: [...(base.plugins || []), 'react', 'react-hooks'],
  extends: [
    ...base.extends,
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'plugin:react/jsx-runtime',
  ],
  settings: {
    react: { version: 'detect' },
  },
  rules: {
    ...base.rules,
    'react/prop-types': 'off',
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
  },
  ignorePatterns: [...(base.ignorePatterns || []), '.next/', 'out/'],
};
