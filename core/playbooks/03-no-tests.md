# Playbook 03 — No tests

## Síntoma

Feature en producción sin tests automatizados. Indicadores:

- `coverage report` muestra archivos críticos en 0%.
- `pnpm test` corre 5 tests para un proyecto de 50 features.
- Bug fixes que no agregan test de regresión.
- "Funciona en mi máquina" como argumento de PR.

## Por qué pasa

- Modo vibe: optimizar para velocidad inicial, tests "después".
- Stack que no facilita testing (DB compartida, side effects everywhere).
- Falta de plantilla / setup → cada test es trabajo desde cero.
- Cultura del equipo: "los tests son para QA".

## Severidad

**medium en vibe / high en graduating.** En vibe un proyecto puede vivir con pocos tests si la complejidad lógica es baja. En graduating cualquier feature crítica sin test es deuda bloqueante.

## Fix

### 1. Identificar lo testeable y crítico

No tester todo. Priorizar:

1. **Lógica de negocio pura** (cálculos, validaciones, transformaciones).
2. **Endpoints sensibles** (auth, escritura, pagos).
3. **Bugs históricos** (cada bug solo se acepta cerrado con test de regresión).

NO priorizar:

- Glue code que llama otra cosa.
- UI puramente declarativa.
- Wrappers de librerías.

### 2. Setup minimal

El addon `node-ts` ya viene con vitest + un test placeholder:

```typescript
// src/example.test.ts
import { describe, it, expect } from 'vitest';

describe('example', () => {
  it('passes', () => {
    expect(1 + 1).toBe(2);
  });
});
```

Correr `pnpm test`. Si falla el setup, fix antes de seguir.

### 3. Patrón básico

```typescript
// src/features/checkout/calculate-total.ts
export function calculateTotal(items: Item[], taxRate: number): number {
  // ...
}

// src/features/checkout/calculate-total.test.ts
import { describe, it, expect } from 'vitest';
import { calculateTotal } from './calculate-total';

describe('calculateTotal', () => {
  it('aplica IVA', () => {
    expect(calculateTotal([{ price: 100 }], 0.21)).toBe(121);
  });

  it('item vacío → 0', () => {
    expect(calculateTotal([], 0.21)).toBe(0);
  });

  it('redondea a 2 decimales', () => {
    expect(calculateTotal([{ price: 33.333 }], 0)).toBe(33.33);
  });
});
```

### 4. Cobertura mínima

Modo vibe target: **30%** de líneas en archivos `src/features/*`.
Modo graduating target: **70%** + 100% en lógica crítica.

```bash
pnpm test -- --coverage
```

### 5. CI

`addons/node-ts/.github/workflows/ci.yml.tmpl` ya corre tests. Confirmar que CI rompe si el coverage cae bajo el umbral.

## Prevención

1. **Plantilla de feature** (`/smart-feature`) genera test stub con `it.todo()`. Obliga a marcar como completo o explicar el skip.
2. **Bug → test rule:** cada PR de fix debe incluir test que reproduce el bug.
3. **Code review**: PR sin test para feature nueva requiere justificación explícita.
4. **Modo graduating**: coverage gate en CI.
5. **Tests rápidos**: si los tests tardan, los devs los skipean. Mantener `pnpm test` debajo de 30s en vibe.
