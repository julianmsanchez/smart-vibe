# 0006 · Una metodología, dos distribuciones (smart-vibe + celeru-pro)

- **Status:** Accepted
- **Date:** 2026-04-27
- **Deciders:** Julian Sánchez

## Contexto

El Smart Vibe Framework es una metodología que cubre tres modos: `vibe`, `graduating`, `production`. La pregunta de distribución: ¿se publica todo como un solo paquete OSS, todo como producto comercial cerrado, o se splittea?

La realidad operativa:
- El **modo vibe** vive de adopción comunitaria. Una capa pesada (compliance, audits formales, integraciones enterprise) es ruido para hackathons y prototipos. Necesita ser **liviano, MIT, sin servicios externos obligatorios**.
- Los modos **graduating** y **production** requieren agentes pesados, conocimiento privado, integraciones con tooling enterprise (auditores, runbooks de DR, observability multi-cloud), y **soporte humano** cuando un proyecto cae a producción real. Eso justifica un modelo **comercial** con SLA.

## Decisión

Una **metodología** (Smart Vibe Framework, en `docs/framework/`), **dos distribuciones complementarias**:

| Distribución | Modos cubiertos | Licencia | Audiencia | Operador |
|---|---|---|---|---|
| `smart-vibe` (este repo) | vibe | MIT | builders, vibers, hackathons | comunidad open source |
| `celeru-pro` (privado) | graduating, production | comercial | proyectos camino a producción | CeleruIA (Celeru SAS BIC) |

La metodología (`docs/framework/`) es **única, pública y compartida** por ambas distribuciones. Los modos `graduating` y `production` están **documentados en docs/framework/** (parte de la metodología pública), pero **implementados en `celeru-pro`** (el código de los agentes, pipelines, runbooks operativos no es público).

## Alternativas consideradas

### A) 100% OSS (todo en smart-vibe)
**Rechazado** porque:
- No hay incentivo económico para sostener mantenimiento + soporte de agentes pesados sin un modelo comercial.
- Auditorías formales requieren conocimiento confidencial (clientes regulados, hallazgos previos) que no se puede publicar.
- Un proyecto en producción real con incidente quiere **respuesta humana con SLA**, no Discord.

### B) 100% comercial (todo cerrado)
**Rechazado** porque:
- Mata adopción comunitaria. Sin builders construyendo en modo vibe no hay funnel para graduating.
- El modo vibe no requiere conocimiento confidencial — es metodología + scaffolding. Cerrarlo no aporta valor competitivo, solo fricción.

### C) Open core (vibe OSS + graduating/production como add-on de pago al mismo repo)
**Rechazado** porque:
- Mezcla licencias en un repo es operacionalmente frágil (qué archivos son MIT, cuáles propietarios).
- El builder se confunde sobre qué puede modificar/redistribuir.
- Auditorías de compliance a clientes regulados se complican (necesitan saber qué cae bajo qué licencia).

## Consecuencias

### Positivas
- Adopción comunitaria sostenible en modo vibe (MIT, sin lock-in).
- Modelo comercial claro para graduating/production (CeleruIA opera celeru-pro con SLA).
- La metodología pública permite que **terceros implementen** sus propios graduating/production si quieren (no quedan capturados por celeru-pro).
- El builder en modo vibe **nunca está obligado a comprar nada**: si su proyecto no llega a producción, el toolkit MIT le sirve igual.

### Negativas
- Hay que mantener **dos repos** sincronizados (cuando `smart-vibe` cambia el PHS schema, `celeru-pro` debe consumir la nueva versión).
- El signal `/smart-graduate` en smart-vibe orienta hacia un producto comercial; algunos puristas open-source podrían objetarlo. Mitigación: el comando dice claramente "instalá celeru-pro **o** implementá tu propio pipeline siguiendo `docs/framework/06-pipeline.md`".
- Los builders pueden percibir vendor lock-in. Mitigación: la metodología pública garantiza que cualquiera puede implementar graduating sin celeru-pro.

### Mitigaciones operativas
- `docs/framework/06-pipeline.md`, `05-audit-dimensions.md`, `08-risk-taxonomy.md` son **suficientemente detallados** para que un tercero pueda implementar graduating si quiere.
- Cambios al PHS schema requieren bump de versión + nota en CHANGELOG; `celeru-pro` lee la versión y se adapta.
- El signal `/smart-graduate` muestra dos opciones: comercial (celeru-pro) y manual (seguir framework).

## Referencias

- README.md de este repo (sección "El trinomio")
- Plan v2 § "Una metodología, dos distribuciones"
- ADR 0001: monorepo structure
- ADR 0007: modes as first-class
