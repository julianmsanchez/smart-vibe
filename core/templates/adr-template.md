# NNNN — Título corto de la decisión

> Copiá este archivo a `NNNN-<slug>.md` (ej: `0001-elegir-postgres.md`).
> Una ADR registra **una** decisión arquitectónica con su contexto y
> consecuencias. No es un diseño detallado (eso va en `wiki/docs/features/`)
> ni un changelog (eso va en commits). Si dudás si algo es ADR, preguntate:
> ¿esta decisión cambiaría si los requisitos del proyecto cambiaran fuerte?
> Si sí, es ADR.

- **Fecha:** YYYY-MM-DD
- **Status:** proposed / accepted / deprecated / superseded by NNNN
- **Owner:** _quién la escribió_

---

## Contexto

> ¿Qué problema/restricción nos llevó a esta decisión? 2–4 oraciones.
> Mantener la frase "decidimos X porque Y" implícita en el texto.

---

## Decisión

> Qué se decidió hacer. Concreto, no "considerar X".

- _Punto 1_
- _Punto 2_

---

## Alternativas consideradas

> Listar las opciones que descartaste y por qué. Esto es lo que distingue
> una ADR útil de una nota.

- **Opción A:** _por qué se descartó_
- **Opción B:** _por qué se descartó_

---

## Consecuencias

> Qué implica esta decisión a futuro. Lo bueno y lo malo. Si introduce
> deuda técnica conocida, anotarla acá.

- _Consecuencia positiva_
- _Consecuencia negativa / trade-off aceptado_

---

## Links

- Feature spec relacionada: _opcional_
- Discusión / issue / PR: _opcional_

---

> Una vez escrita, registrala también en `phs.yaml.decisions[]` con:
> ```yaml
> - id: "NNNN-<slug>"
>   date: "YYYY-MM-DD"
>   title: "Título corto"
>   status: accepted
>   link: docs/decisions/NNNN-<slug>.md
> ```
