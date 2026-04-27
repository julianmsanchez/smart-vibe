# Policy 05 · Operations

> **Dimensión:** Operations · **Pregunta nuclear:** ¿el sistema es observable, deployable y recuperable?

---

## Principio

**Un sistema sin observabilidad es una caja negra.** Cuando algo falla en prod (no si, cuando), tenés que poder responder "qué pasó, cuándo, qué request" en minutos, no en horas.

---

## Mínimo en `vibe`

- Logger estructurado (json, no `console.log` crudo). Lo trae el addon `node-ts`.
- Healthcheck endpoint (`/health` o equivalente).
- Saber cómo levantar el server local (`pnpm dev` debe alcanzar) y cómo deployar (aunque sea push manual).

---

## Checklist (referencia para graduar)

### Logging
- [ ] Logger estructurado (Pino, Winston, etc.) configurado.
- [ ] Niveles usados con criterio: `error` (algo falló), `warn` (anomalía), `info` (eventos relevantes), `debug` (detalle dev-only).
- [ ] Correlation ID propagado entre requests/jobs (ver helper en `addons/node-ts/`).
- [ ] No se loguea PII (ver Policy 01).
- [ ] Destination configurable por env var (stdout local, CloudWatch/Datadog/Loki en prod).

### Metrics & monitoring
- [ ] RED metrics expuestos: **R**ate, **E**rrors, **D**uration por endpoint clave.
- [ ] USE metrics de infra: **U**tilization, **S**aturation, **E**rrors.
- [ ] Dashboards (Grafana, CloudWatch, Datadog) con vistas por feature crítica.
- [ ] Percentiles (p50, p95, p99), no solo promedio.

### Alerting
- [ ] Alertas por SLO (no por threshold ad-hoc).
- [ ] Cada alerta tiene runbook linkeado (qué hacer cuando dispara).
- [ ] Escalation path definido (quién recibe, en qué horario, fallback).
- [ ] Reglas de "paging fatigue" (no alertar por cosas que se auto-resuelven).

### Deployment automation
- [ ] CI/CD básico: push a `main` corre tests, build artifact.
- [ ] Deploy a staging automático en cada commit a main.
- [ ] Deploy a prod gated (manual approval o tag-based).
- [ ] Rollback en <5 min (revert de tag, infra-as-code, etc.).

### Disaster recovery
- [ ] Plan documentado: qué hacer si DB cae, si provider X cae.
- [ ] Ensayado al menos 1 vez (game day).
- [ ] RTO/RPO conocidos y comunicados a stakeholders.

---

## Anti-patrones (banderas rojas)

- **`console.log` sin contexto** — no hay request ID, no hay user, no sabés qué request generó la línea. Inservible en prod.
- **Logging excesivo de PII** — los logs están más expuestos de lo que pensás (CloudWatch tiene IAM débil por default).
- **Healthcheck que no chequea nada** — `/health` que responde 200 siempre, mientras la DB está caída. Debe verificar deps críticos.
- **Deploy sin rollback** — push directo a prod sin versionado de artifact. Cuando rompe, hay que git revert + redeploy. Lento.
- **Alertas que nadie atiende** — si una alerta se ignora 3 veces, o está mal calibrada o el ruido la desensibilizó. Eliminar o ajustar.
- **Metric promedio único** — el promedio oculta colas. Siempre p50+p95 mínimo.
- **DR plan teórico** — "hicimos el doc". Si no se ensayó, no funciona.
