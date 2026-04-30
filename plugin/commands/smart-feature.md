---
name: smart-feature
description: Scaffolding de una feature nueva con tests, docs y entry en el PHS.
---

# /smart-feature

Crea el esqueleto de una feature: archivos de código, tests, doc en wiki, y registra la decisión en el PHS si aplica.

## Argumentos

- `<nombre>` — slug de la feature (kebab-case). Ej: `user-onboarding`, `checkout-flow`.

## Qué hace

1. Detecta el stack (lee `phs.yaml.stack`).
2. Detecta el tipo (`single-team` o `workshop`):
   - **single-team:** crea archivos en `src/features/<nombre>/`.
   - **workshop:** pregunta a qué team pertenece y crea en `apps/<team>/src/features/<nombre>/`.
3. Genera:
   - Archivo principal con un handler/componente stub.
   - Test stub con un `it.todo()`.
   - Entry en `wiki/docs/features/<nombre>.md` con secciones: Contexto, Decisiones, Estado, TODOs.
4. Si la feature implica un endpoint cross-team (workshop), sugiere agregar el schema en `@workshop/api-contracts`.
5. Pregunta si querés agregar una entry a `phs.yaml.decisions[]`.

## Implementación

Esqueleto generado depende del stack:

| Stack | Archivos generados |
|---|---|
| node-ts (Express) | `routes.ts`, `service.ts`, `routes.test.ts`, wiki entry |
| next.js (shell) | `page.tsx`, `loading.tsx`, wiki entry |
| Otro | Sólo wiki entry + recordar usuario que defina manualmente |

## Cuándo usar

- Empezar una feature nueva con guardrails de docs y test.
- Mantener el wiki sincronizado sin trabajo manual.

## Cuándo NO usar

- Cambios pequeños / refactors. Para eso, edición directa.
