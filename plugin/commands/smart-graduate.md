---
name: smart-graduate
description: Checklist + handoff de un proyecto smart-vibe a celeru-pro (modo graduating).
---

# /smart-graduate

Prepara el proyecto para subir del modo `vibe` al modo `graduating`. Es un checklist + handoff a `celeru-pro` (que opera el modo graduating).

## Qué hace

1. Corre `phsSchema.safeParse()` con reglas estrictas de graduating.
2. Reporta gaps (campos requeridos vacíos, decisiones sin documentar, sin tests, etc.).
3. Si hay gaps, ofrece:
   - Llenar interactivamente (`/smart-phs add-decision`, etc.).
   - Listar las 7 policies y qué falta para cumplir cada una.
4. Si no hay gaps, escribe `phs.yaml.mode: graduating` y emite handoff:
   - Reporte de madurez L1→L2 con evidencia.
   - Lista de cambios que vendrán (audit formal de las 7 dimensiones, pipeline 7-fases).
   - URL/comando para invocar celeru-pro (cuando exista).

## Pre-checks (modo vibe → graduating)

Validaciones obligatorias antes de graduar:

- [ ] `phs.yaml.project` completo (name, mode, type, vertical, tier).
- [ ] `phs.yaml.stack` declarado.
- [ ] `phs.yaml.decisions[]` con al menos 5 entries documentadas.
- [ ] README.md del repo describe el proyecto.
- [ ] Al menos un test corriendo en CI.
- [ ] Sin secretos en repo (filter pre-commit verde).
- [ ] Si `type=workshop`: `workshop.yaml` válido + integration-check verde.

## Salida exitosa

```
✓ PHS válido para graduating.
✓ 7 policies cubiertas.
✓ Handoff escrito en docs/graduate-handoff.md.

Próximos pasos:
1. Instalar celeru-pro (privado, requiere licencia).
2. Correr `celeru-pro audit` para pipeline 7-fases formal.
3. Mantener PHS.mode=graduating durante la fase de hardening.
```

## Implementación

1. Lee `phs.yaml`.
2. Aplica `phsSchema` con `mode=graduating` (más estricto).
3. Para cada policy en `core/policies/*.md`, verifica que el repo cumple los mínimos declarados.
4. Si todo OK: edita `phs.yaml.mode` y escribe handoff.
5. Si hay gaps: emite reporte y NO toca el `mode`.

## Importante

Este comando es **conservador**: nunca cambia `mode` sin OK explícito del usuario al final del checklist. Graduar es decisión humana.
