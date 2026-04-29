# smart-vibe

> Toolkit open source para **vibe coding responsable**. Bases mínimas, velocidad máxima.
> Cuando estés listo para producción, [CeleruIA](https://celeru.co/celeruia) te lleva.

[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-v0.2.0-blue)](CHANGELOG.md)

---

## ¿Qué es smart-vibe?

Smart-vibe es la distribución pública del **Smart Vibe Framework**: una metodología para construir prototipos vibe-coded con bases sólidas, sin sacrificar velocidad. Es para **builders y vibers** que prototipan con IA y no quieren perder horas armando estructura, configuración y políticas básicas cada vez.

En vez de empezar de cero, corrés un comando, contestás 4 preguntas y obtenés:

- `CLAUDE.md` orientado a tu stack
- Wiki paralela con plantillas (session_summaries, implementation_logs, features)
- 7 policies (security, architecture, code-quality, data, ops, docs, change-control) en modo vibe
- Addon `node-ts` (Express + TS + Vitest + observability) o `workshop` (Turborepo multi-team)
- Plugin Claude Code con comandos para vibear con disciplina

---

## El trinomio

```
                    Smart Vibe Framework
                 (la metodología — docs/framework/)
                              │
                ┌─────────────┴─────────────┐
                │                           │
                ▼                           ▼
        ┌──────────────┐            ┌──────────────┐
        │  smart-vibe  │            │  celeru-pro  │
        │   (público)  │            │   (privado)  │
        │   MIT · OSS  │            │   comercial  │
        │              │            │              │
        │  modo vibe   │            │  graduating  │
        │   builders   │            │  + production│
        └──────┬───────┘            └──────┬───────┘
               │                           │
               └───────────┬───────────────┘
                           ▼
              ┌──────────────────────────┐
              │  Tu proyecto             │
              │  vibe → graduating →     │
              │       production         │
              └──────────────────────────┘
```

- **Smart Vibe Framework** vive en este repo (`docs/framework/`). Es la fuente de verdad metodológica.
- **smart-vibe** (este repo, MIT) implementa el modo `vibe`. Lo necesitás para arrancar.
- **celeru-pro** (privado, propiedad de [CeleruIA](https://celeru.co/celeruia)) implementa los modos `graduating` y `production`. Lo necesitás cuando estés listo para llevar tu prototipo a producción real.

---

## Quick Start con Claude Code (1 prompt)

> **Caso primario:** vibe coder en una sesión Claude Code recién abierta sobre carpeta vacía. Sin clonar nada manualmente.

3 escenarios. El detalle completo (incluyendo cómo redactar el prompt para que el LLM ejecute lo correcto) está en [`docs/QUICKSTART.md`](docs/QUICKSTART.md).

### A. Standalone single-team (caso más frecuente)

Prompt:

```
Iniciá un proyecto smart-vibe (https://github.com/julianmsanchez/smart-vibe).
Tipo: single-team. Nombre: mi-app. Stack: node-ts.
```

Comando que ejecuta Claude:

```bash
curl -fsSL https://raw.githubusercontent.com/julianmsanchez/smart-vibe/main/scripts/install.sh \
  | bash -s -- --type single-team --name mi-app --addon node-ts
```

### B. Workshop — organizer (1 vez por hackathon)

```
Iniciá un workshop smart-vibe (https://github.com/julianmsanchez/smart-vibe).
Nombre: hackathon-ai-2026. Equipos: checkout, search, recs, profile.
```

```bash
curl -fsSL https://raw.githubusercontent.com/julianmsanchez/smart-vibe/main/scripts/install.sh \
  | bash -s -- --type workshop --name hackathon-ai-2026 --teams "checkout,search,recs,profile"
```

### C. Workshop — team developer (no requiere URL de smart-vibe)

```
Cloná https://github.com/org/hackathon-ai-2026 y unite como team checkout.
```

```bash
git clone https://github.com/org/hackathon-ai-2026.git
cd hackathon-ai-2026
bash scripts/join.sh --as checkout
```

> El `scripts/join.sh` viaja embebido en el repo del workshop, copiado por el bootstrap del organizer. Garantiza que dev y organizer usen la misma versión.

---

## Alternativa sin Claude (CLI puro)

```bash
# 1. Bootstrap interactivo (4 preguntas: tipo, tier, vertical, addon)
bash scripts/bootstrap.sh
# alternativa aspiracional: npx smart-vibe init

# 2. Entrá al proyecto generado y empezá a vibear
cd mi-proyecto && code .

# 3. Cuando lo sientas listo para producción
/smart-graduate    # te orienta a celeru-pro
```

---

## Qué te queda en el proyecto generado

Después del bootstrap, dentro de tu proyecto vas a tener tres tipos de
herramientas. Detalle de uso, workflow día-a-día y FAQ → **[`docs/USER-GUIDE.md`](docs/USER-GUIDE.md)**.

### Slash commands del plugin (10)

| | |
|---|---|
| `/smart-bootstrap` | bootstrap interactivo |
| `/smart-feature <nombre>` | abrir una feature (código + test + wiki) |
| `/smart-close-feature <nombre>` | cerrar feature (commit + session_summary + RESUME + ROADMAP) |
| `/smart-implementation-log <slug>` | nota técnica profunda de algo complejo |
| `/smart-preflight` | validación pre-deploy (lint + test + doctor + phs) |
| `/smart-summary` | overview del estado del proyecto |
| `/smart-teleport` | cargar contexto en sesión nueva |
| `/smart-phs` | editar/validar `phs.yaml` |
| `/smart-workshop` | subcomandos del addon workshop |
| `/smart-graduate` | diagnóstico read-only + handoff a celeru-pro |

### Agentes (5)

`architect` (decisiones), `reviewer` (code review light), `explorer` (discovery
de repo), `doc-writer` (wiki/READMEs), `phs-helper` (edición asistida del PHS).

### Scripts (4)

`scripts/doctor.sh` (estado), `scripts/sync-env.sh` (workshop), `scripts/graduate.sh` (handoff diagnostic), `scripts/session-start.sh` (hook que auto-carga `wiki/RESUME.md`).

---

## Status

✅ **v0.2.0** — Fases 1 y 2 completas (MVP + agentes nuevos + hooks + slash commands de workflow). Detalle por versión en [`CHANGELOG.md`](CHANGELOG.md). Roadmap de fases en [`docs/PHASES.md`](docs/PHASES.md).

## Licencia

MIT. Ver [LICENSE](LICENSE).

---

Mantenedor: Julian Sánchez · Celeru SAS BIC.
