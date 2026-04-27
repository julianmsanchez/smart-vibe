# Smart Vibe — Claude Code plugin

Plugin de Claude Code que expone los comandos `/smart-*` del Smart Vibe Framework. Es un wrapper sobre los scripts y specs del repo.

## Instalación

```bash
# Desde el directorio del plugin (este repo)
claude plugin install ./plugin
```

O publicado vía marketplace (Fase 2).

## Comandos

| Comando | Qué hace |
|---|---|
| `/smart-bootstrap` | Bootstrap interactivo (4 preguntas) → genera proyecto smart-vibe |
| `/smart-phs` | Crea/edita el `phs.yaml` del proyecto actual |
| `/smart-feature` | Scaffolding de una feature con tests + docs |
| `/smart-summary` | Resumen ejecutivo del estado del proyecto |
| `/smart-teleport` | Carga el contexto del proyecto en una nueva sesión |
| `/smart-workshop` | Subcomandos para addon workshop: `init`, `status`, `integration-check` |
| `/smart-graduate` | Checklist + handoff a celeru-pro (modo graduating) |

## Agentes

| Agente | Rol |
|---|---|
| `architect` | Decisiones de arquitectura. Lee el PHS y propone trade-offs. |
| `doc-writer` | Genera/actualiza wiki paralela y READMEs. |
| `phs-helper` | Edita el `phs.yaml` con validación Zod en línea. |

## Cómo se relaciona con el repo

El plugin es la cara de usuario; los binarios viven en el repo:

- `/smart-bootstrap` → invoca `scripts/bootstrap.sh`.
- `/smart-workshop init` → invoca `scripts/bootstrap.sh --type workshop`.
- `/smart-workshop validate` → invoca `scripts/doctor.sh workshop validate`.
- Los agentes leen `core/phs/schema.ts` y `core/workshop-spec/schema.ts`.

## Modos

El plugin detecta el modo (`vibe`/`graduating`/`production`) leyendo `phs.yaml` o `workshop.yaml`. En graduating los comandos exigen más validaciones; en vibe son permisivos.
