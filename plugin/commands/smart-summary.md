---
name: smart-summary
description: Resumen ejecutivo del estado del proyecto (PHS, modo, deuda, decisiones recientes).
---

# /smart-summary

Genera un resumen del proyecto que cabe en una pantalla. Útil para:

- Onboarding de un dev nuevo.
- Reporte semanal a stakeholders.
- Re-cargar contexto en una sesión nueva (también `/smart-teleport`).

## Qué incluye

```
PROYECTO: <nombre>  ·  modo: vibe  ·  vertical: general  ·  tier: 1
─────────────────────────────────────────────────────────
Stack:     <runtime>+<framework>+<db>
Type:      single-team | workshop (con N teams)
Created:   <fecha>

Madurez (L0-L5):  L1   ████░░░░░░  (vibe)

Decisiones recientes (últimas 5):
  • <fecha> · <título>
  • ...

TODOs activos (de wiki):
  • <título>
  • ...

Deuda detectada (de doctor.sh):
  ⚠ phs.yaml.compliance vacío (OK en vibe, requerido en graduating)
  ⚠ Sin tests en src/features/checkout/
  ✓ All policies cumplidas

Próximos pasos sugeridos:
  1. Completar X
  2. Validar Y
  3. Documentar Z
```

## Implementación

1. Lee `phs.yaml`.
2. Si `type=workshop`: lee también `workshop.yaml` y enumera teams.
3. Corre `bash scripts/doctor.sh --quiet` y captura los warnings.
4. Lee últimas N entradas de `phs.yaml.decisions[]`.
5. Lee TODOs marcados en wiki/* (heurística: líneas con `TODO:` o `- [ ]`).
6. Calcula nivel de madurez aproximado (mode→L1/2/3, completitud del PHS, etc.).

## Cuándo usar

- Cada lunes / inicio de semana.
- Antes de presentar el proyecto a alguien externo.
- Para auditarte a vos mismo si un proyecto está creciendo limpio.
