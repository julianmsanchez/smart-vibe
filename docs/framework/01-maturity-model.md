# 01 · Modelo de Madurez (L0–L5)

> Un proyecto está siempre en un nivel de madurez. El nivel se mide contra las **7 dimensiones** del framework (ver `05-audit-dimensions.md`) y se mapea a uno de los **3 modos** (ver `02-modes.md`).

---

## Mapa rápido

```
L0  Chaos                   ┐
L1  Vibe                    │  modo: vibe
L2  Disciplined Vibe        ┘
L3  Graduating              ── modo: graduating
L4  Production-ready        ┐
L5  Production-mature       ┘  modo: production
```

El nivel **no es lineal en el tiempo** (un proyecto puede regredir si una dimensión cae). El **modo es declarativo** (`project.mode` en el PHS); el **nivel es observable** (lo mide `doctor.sh` y, en graduating, los auditores de `celeru-pro`).

---

## L0 — Chaos

**Síntomas:**
- Sin git, sin README, sin commits estructurados.
- Decisiones de stack/infra implícitas (en la cabeza del builder).
- Secretos en código o en chat.
- No hay forma de reproducir el proyecto en otra máquina.

**Cómo se sale:** correr `bash scripts/bootstrap.sh`. Eso lleva a L1 directo.

## L1 — Vibe

**Síntomas:**
- Repo inicializado, primer commit, README mínimo.
- PHS creado (puede tener campos vacíos).
- Las **5 Reglas de Oro** se cumplen (ver `04-golden-rules.md`).
- Conventional Commits aplicados.
- Sin secretos en repo.
- Hay un addon de stack scaffoldeado.

**Modo declarado:** `vibe`.

**No se exige:**
- Tests (más allá del esqueleto del addon).
- Observability completo.
- ADRs formales.
- Auditoría de las 7 dimensiones.

Es el estado natural cuando salís del bootstrap.

## L2 — Disciplined Vibe

**Síntomas:**
- Todo lo de L1, más:
- PHS **completo** (sin campos vacíos críticos: stack, vertical, tier, mode, addons).
- ADRs escritas para las 3-5 decisiones más grandes (DB, hosting, auth, etc.).
- Policies en modo vibe **leídas y reconocidas** (no necesariamente aplicadas en su totalidad).
- Tests para los happy paths principales.
- Logger estructurado activo (no `console.log`).
- `.env.example` actualizado y `.env` en `.gitignore`.

**Modo declarado:** sigue siendo `vibe`. L2 es "vibe maduro", no graduating todavía.

**Cuándo apuntar a L2:** cuando el prototipo deja de ser exploratorio y empieza a usarse (demo, pre-piloto, MVP cerrado).

## L3 — Graduating

**Síntomas:**
- Todo lo de L2, más:
- `project.mode: graduating` declarado en PHS.
- Pipeline de 7 fases activo (lo opera `celeru-pro`).
- Auditoría 0-5 ejecutada en las 7 dimensiones; resultados registrados.
- Quality gates obligatorios entre fases (no se avanza sin pasar gate).
- Ningún issue **CRITICAL** abierto en risk taxonomy.

**Modo declarado:** `graduating`.

**Salida esperada:** llegar a L4 antes de deployar a producción real. Si una dimensión queda en <3 al final del pipeline, **no se gradúa**: vuelve a graduating con plan remediación.

## L4 — Production-ready

**Síntomas:**
- Todo lo de L3, más:
- Las 7 dimensiones puntuadas en **≥4**.
- Runbooks operativos escritos y ensayados al menos una vez.
- Observability end-to-end (logs estructurados + métricas + alertas básicas).
- Deployment automatizado (CI/CD verde).
- SLA definido (objetivos de uptime, RTO, RPO).
- Backup + restore probado al menos una vez.

**Modo declarado:** `production` (recién entrando).

L4 es el **mínimo aceptable** para que un sistema corra en producción real con tráfico de usuarios reales.

## L5 — Production-mature

**Síntomas:**
- Todo lo de L4, sostenido en el tiempo:
- SLA cumplido por al menos un trimestre.
- Auditorías periódicas (trimestrales o anuales) pasadas.
- Post-mortems documentados de los incidentes que hayan ocurrido.
- Cambios mayores reactivan quality gates (no se mergea a main sin re-auditar dimensión afectada).
- Mejoras continuas registradas en `decisions/` o `wiki/`.

**Modo declarado:** `production` (maduro).

L5 es **operación viva**, no un estado que se alcanza y se conserva sin esfuerzo. Es el target de proyectos en producción de larga vida.

---

## Cómo se mide el nivel

| Modo | Quién mide | Cómo |
|---|---|---|
| vibe (L0–L2) | `bash scripts/doctor.sh` | Checks livianos: git, README, PHS, .env, addon scaffolded, 5 reglas |
| graduating (L3) | `celeru-pro` (auditores) | Auditoría 0-5 en 7 dimensiones × 5 sub-criterios |
| production (L4–L5) | `celeru-pro` (re-audits) | Re-audits periódicos + observability runtime |

`smart-vibe` solo implementa la medición de L0–L2 (modo vibe). De L3 en adelante es competencia de `celeru-pro`.

---

## Anti-patrones de progresión

- **Saltar L1→L4 sin pasar por graduating:** el pipeline existe para detectar deuda invisible. Saltarlo es jugar a la ruleta con producción.
- **Quedarse en L1 indefinidamente:** L1 es saludable mientras estés explorando. Si el código empieza a tener usuarios, apuntá a L2 antes de que se rompa.
- **Reportar L4 sin runbooks:** es L3 con cosmética. No engaña a un incidente real.
- **Regredir sin reconocerlo:** si después de un refactor una dimensión cae, declarálo. El framework prefiere honestidad sobre teatro de madurez.

---

## Referencia cruzada

- Dimensiones y sub-criterios: `05-audit-dimensions.md`
- Pipeline de graduación: `06-pipeline.md`
- Risk taxonomy (CRITICAL/HIGH/MEDIUM/LOW): `08-risk-taxonomy.md`
- Modos: `02-modes.md`
