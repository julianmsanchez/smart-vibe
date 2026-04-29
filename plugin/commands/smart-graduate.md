---
name: smart-graduate
description: Diagnóstico de readiness + handoff a celeru-pro. Read-only. No cambia phs.yaml.mode.
---

# /smart-graduate

Espejo de readiness para pasar de modo `vibe` a modo `graduating`. **No es un gate**: no tiene umbrales que aprueben/rechacen; es un diagnóstico que te muestra dónde está el proyecto para que vos decidas si querés graduar.

> Modo graduating lo opera `celeru-pro` (repo privado, requiere licencia). Este comando vive en smart-vibe y prepara el handoff. La transición es decisión humana.

## Filosofía

- **Read-only.** Nunca edita `phs.yaml.mode` ni ningún archivo del proyecto excepto el handoff doc.
- **Sin umbrales arbitrarios.** No exige "5 ADRs" ni "X% de cobertura". Reporta hechos.
- **Tres categorías:** crítico (blockers reales para auditar), recomendado (señales de calidad), inventario (datos sin juicio).
- **Acción concreta.** Cada finding incluye path + comando para investigar/arreglar.

## Qué hace

1. Lee `phs.yaml`, `workshop.yaml` (si aplica), `docs/decisions/`, `wiki/`, `src/`, `.env.*`, `.github/workflows/`.
2. Clasifica findings en 3 baldes (criterios abajo).
3. Imprime tabla resumen + top 3 acciones a stdout.
4. Escribe `docs/graduate-handoff.md` con inventario completo + findings + open questions.
5. **No toca** `phs.yaml`. Si querés graduar, editá `mode: graduating` manualmente después de revisar el handoff.

## Categorías de findings

### Crítico (blockers reales)

Estos rompen cualquier auditoría posterior. Si aparecen, el handoff doc los lista con resaltado.

- `.env` commiteado al repo (secrets leak).
- Tokens prohibidos detectados por `~/.openclaw/credentials/smart-vibe/extraction-filter` (si existe).
- `phs.yaml` ausente o YAML inválido.
- README.md ausente o vacío (< 50 bytes).
- Sin un solo test (`.test.ts/.test.tsx/.spec.ts` no encontrados).
- `.gitignore` ausente.
- En workshop: `workshop.yaml` ausente o `sync-env.sh --check` con drift.

### Recomendado (quality signals)

Señales que fortalecen la auditoría. Se reportan con conteo + path; **no** se gate-keep.

- `phs.yaml.stack` declarado (no `~`).
- `phs.yaml.decisions[]` con entries.
- ADRs en `docs/decisions/` consistentes con `phs.yaml.decisions[]` (cross-check).
- `.env.example` cubre todas las vars consumidas en `src/` (mismo check que doctor.sh).
- `wiki/PRD.md` con secciones llenas (no `_TODO_` en personas/KPIs).
- CI configurado (`.github/workflows/*.yml` presente).
- 7 policies de `docs/policies/` con marca de revisión (aplica / no aplica / postergada).
- Workshop: `bash scripts/doctor.sh` con 0 warns.

### Inventario (datos sin juicio)

Hechos que celeru-pro va a querer saber para dimensionar el audit. Sin valoración.

- LOC en `src/` (excluyendo node_modules).
- N de archivos de test.
- N de ADRs en `docs/decisions/` (incluye `_template.md`? exclúyelo).
- N de session summaries en `wiki/docs/session_summaries/`.
- N de módulos en `wiki/PRD.md` sección 3.
- Edad: días desde primer commit.
- Lenguaje + framework + runtime (de `phs.yaml.stack` o detectado).
- Workshop: N de teams, N de APIs externas en `workshop.yaml.shared_infra.apis_external[]`.

## Output a stdout

Tabla compacta. Ejemplo:

```
=== /smart-graduate — diagnóstico de readiness ===

Proyecto: petcare (vibe, single-team, salud)
Edad:     14 días · Smart-vibe v0.1.4

Crítico    (blockers reales): 0  ✓
Recomendado (quality signals): 3
Inventario:                    ver docs/graduate-handoff.md

Recomendados pendientes:
  ⚠ phs.yaml.stack es ~  → declarar runtime/framework/db
  ⚠ docs/decisions/ vacío → registrar decisiones tomadas
  ⚠ .env.example no cubre 2 vars consumidas en src/ → bash scripts/doctor.sh

Top 3 acciones (priorizadas):
  1. Llenar phs.yaml.stack (5 min) — bloqueante para audit técnica.
  2. Documentar 1-3 ADRs reales en docs/decisions/ (15-30 min).
  3. Completar .env.example con DATABASE_URL, OPENAI_API_KEY.

Handoff escrito en: docs/graduate-handoff.md (250 líneas)
```

## Output a docs/graduate-handoff.md

Markdown con:

- **Header:** proyecto, fecha del diagnóstico, versión de smart-vibe que lo generó, hash del commit actual.
- **Inventario completo** (todos los counts).
- **Findings crítico** con path + comando de fix.
- **Findings recomendado** con path + comando de fix.
- **Open questions para celeru-pro:** preguntas abiertas que el builder tiene que responderle al auditor (tier real con justificación, vertical context, integraciones obligatorias, deadlines, presupuesto). Plantilla con prompts.
- **Próximos pasos:** instalar celeru-pro (privado), correr `celeru-pro audit`, mantener `phs.yaml.mode=graduating` durante el hardening.

El handoff doc es **el artefacto que celeru-pro consume**. Está pensado para que un auditor humano lea 5 minutos y entienda el estado.

## Importante

- **Read-only sobre el proyecto.** Sólo escribe `docs/graduate-handoff.md`.
- **No cambia `phs.yaml.mode`.** Eso es decisión humana; lo edita el builder a mano cuando quiere.
- **No requiere internet.** Toda la lógica corre local.
- **Idempotente.** Re-correrlo sobrescribe el handoff con datos frescos.
- **Sin dependencias TS.** Implementación bash + python3 (mismo patrón que doctor.sh y sync-env.sh).

## Implementación (high-level)

1. Reusa los checks de `scripts/doctor.sh` (parse YAML, env diff, test count, etc.).
2. Agrega cross-checks nuevos: ADRs ↔ `phs.yaml.decisions[]`, PRD `_TODO_` count, policies marca-de-revisión.
3. Render del handoff via heredoc con secciones fijas.
4. Stdout = derivado del handoff (top-N findings + counts agregados).

## Cuándo correrlo

- Cuando sentís que el proyecto está listo para hardening formal.
- Antes de invitar a un auditor externo.
- Como check de salud cada N semanas (`/smart-graduate` no es destructivo).
- Antes de pedirle a celeru-pro que corra el audit completo.

## Cuándo NO correrlo

- En CI bloqueante (no es un gate, es un diagnóstico).
- Esperando que apruebe/rechace (no devuelve exit code de pass/fail; siempre exit 0 salvo error de runtime).
