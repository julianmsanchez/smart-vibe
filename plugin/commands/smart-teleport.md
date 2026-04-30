---
name: smart-teleport
description: Carga el contexto del proyecto smart-vibe en una sesión nueva de Claude Code.
---

# /smart-teleport

"Teletransporta" el contexto del proyecto a una sesión nueva. Útil cuando empezás una sesión sin historial previo y querés que el agente entienda el proyecto rápido.

## Qué hace

Lee y resume:

1. `phs.yaml` (modo, stack, vertical, decisiones).
2. `workshop.yaml` si existe (teams + infra compartida).
3. `CLAUDE.md` del repo (instrucciones del builder).
4. `wiki/INDEX.md` (mapa de docs).
5. Últimos 10 commits (para entender qué pasó recientemente).
6. `decisions[]` del PHS (las últimas 10).

Y emite un mensaje compacto que el agente puede usar como bootstrap mental.

## Salida

```
== TELEPORT ==
Proyecto: <nombre> · modo vibe · stack node-ts+postgres

PHS resumido:
- Decisión clave 1: ...
- Decisión clave 2: ...

Workshop:
- 3 teams: team-a, team-b, team-c
- DB strategy: shared-schema-isolated-rows
- APIs externas: openai (acceso: team-a, team-b)

Últimos commits:
- abc123 feat: ...
- def456 fix: ...

Wiki principales:
- wiki/docs/features/onboarding.md
- wiki/architecture/api-contracts.md

== READY ==
```

## Cuándo usar

- Sesión nueva sin contexto previo.
- Saltaste de un branch a otro y querés re-cargar.
- Vas a hacer un cambio importante y querés confirmar el estado actual.

## Diferencia con `/smart-summary`

- `summary` es para **humanos** (presentaciones, status reports).
- `teleport` es para **el agente** (denso, sin prosa, máximo info por byte).

## Implementación

Concatena las salidas de:
- `cat phs.yaml`
- `cat workshop.yaml 2>/dev/null`
- `cat CLAUDE.md`
- `cat wiki/INDEX.md`
- `git log --oneline -n 10`
- Últimas 10 decisiones del PHS.

Lo emite como un único bloque con markers `== TELEPORT ==` / `== READY ==`.
