# Playbook 04 — No README

## Síntoma

- README.md ausente, vacío, o con el placeholder default de un generador.
- README desactualizado (referencia archivos/comandos que ya no existen).
- README enorme que nadie lee.

## Por qué pasa

- Bootstrap sin template de README.
- Cambios al stack que no se reflejan en docs.
- Confusión sobre qué pertenece al README vs ARCHITECTURE.md vs wiki.

## Severidad

**medium.** No bloquea funcionalidad pero rompe onboarding y multiplica tickets/preguntas.

## Fix

### 1. Estructura mínima del README

5 secciones, 1-2 párrafos cada una:

```markdown
# <Proyecto>

> 1-2 líneas: qué es y para qué sirve.

## Quickstart

# Instalación
git clone ...
pnpm install
cp .env.example .env
# editar .env con valores reales
pnpm dev

## Estructura

src/        - código de aplicación
tests/      - tests automatizados
docs/       - decisiones y arquitectura
scripts/    - utilidades (bootstrap, doctor)

## Scripts útiles

- pnpm dev — levanta el server local
- pnpm test — corre tests
- pnpm lint — lint + format

## Links

- [ARCHITECTURE.md](./ARCHITECTURE.md) — diseño alto nivel
- [PHS](./phs.yaml) — Prototype Handoff Spec
- [docs/adr/](./docs/adr/) — Architecture Decision Records
```

### 2. Qué NO va en el README

- Tutorial extenso → wiki.
- Lista exhaustiva de features → wiki/features/.
- Decisiones de arquitectura → ARCHITECTURE.md o ADR.
- Política de contribución → CONTRIBUTING.md.

### 3. Mantener vivo

Cada vez que cambia:
- Comando del Quickstart (rename script, nuevo step) → update README.
- Estructura de carpetas → update README.
- Stack principal (Node 18 → Node 22) → update README.

## Prevención

1. **Bootstrap genera README** desde `core/templates/README.md.tmpl`. NO empezar de cero.
2. **Convención de wiki paralela**: README minimal, detalle en `wiki/`.
3. **Code review**: si un PR cambia el quickstart sin actualizar README, devolver.
4. **`/smart-summary` lee el README** y reporta si está obsoleto comparado con `phs.yaml.stack`.
