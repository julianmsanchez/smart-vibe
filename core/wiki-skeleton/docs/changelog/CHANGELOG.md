# CHANGELOG — wiki

> Changelog **interno del builder** (visible en la wiki). Se enfoca en
> cambios funcionales, decisiones, milestones de discovery — todo lo que
> querés que tu yo del futuro o un nuevo dev encuentre en una sola página.
>
> Si tu proyecto también publica versiones para usuarios externos (npm,
> binarios, API), mantené **además** un `CHANGELOG.md` raíz formato
> [Keep a Changelog](https://keepachangelog.com). Este de acá es la
> bitácora interna, no el comunicado público.

Formato libre. Sugerencia: una sección por sprint/semana/release con
3 buckets — `Added`, `Changed`, `Notes`.

---

## [Unreleased]

### Added
- _qué se incorporó_

### Changed
- _qué se modificó (comportamiento, contratos, docs)_

### Notes
- _decisiones, deuda asumida, links a session_summaries o ADRs relevantes_

---

## Convenciones

- **Granularidad:** una entrada por cambio significativo. No por archivo.
- **Linkear:** cuando cierre una feature, agregar link al
  `wiki/features/<slug>.md` y/o al `wiki/docs/session_summaries/<fecha>-<slug>.md`.
- **ADRs:** decisiones arquitectónicas siguen yendo a `docs/decisions/`
  (raíz del proyecto). Acá referenciá la ADR, no la dupliques.
- **Cierre de sprint/release:** mover `[Unreleased]` a una sección
  fechada (`[YYYY-MM-DD]` o `[v0.x.0]`).
