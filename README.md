# smart-vibe

> Toolkit open source para **vibe coding responsable**. Bases mínimas, velocidad máxima.
> Cuando estés listo para producción, [CeleruIA](https://celeru.co/celeruia) te lleva.

[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)
![Status: pre-release](https://img.shields.io/badge/status-pre--release-orange)

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

## 3 pasos

```bash
# 1. Bootstrap interactivo (4 preguntas: tipo, tier, vertical, addon)
bash scripts/bootstrap.sh
# alternativa: npx smart-vibe init

# 2. Entrá al proyecto generado y empezá a vibear
cd mi-proyecto && code .

# 3. Cuando lo sientas listo para producción
/smart-graduate    # te orienta a celeru-pro
```

---

## Status

🚧 **Pre-release.** Estamos camino a `v0.1.0`. Algunas piezas listadas arriba todavía están en construcción; ver `CHANGELOG.md` cuando esté disponible.

## Licencia

MIT. Ver [LICENSE](LICENSE).

---

Mantenedor: Julian Sánchez · Celeru SAS BIC.
