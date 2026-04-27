# Policy 04 · Data

> **Dimensión:** Data · **Pregunta nuclear:** ¿los datos están modelados, persistidos, respaldados y migrables?

---

## Principio

**El schema de datos es un contrato.** Cambiarlo sin migración versionada y sin pensar en data ya persistida es una de las formas más fáciles de romper producción de manera silenciosa.

---

## Mínimo en `vibe`

- Si el proyecto persiste algo, declarar `data.primary_db` en `phs.yaml` (Postgres por default per ADR 0007 si dudas).
- Si hay schema, vivir en migraciones (no `ALTER TABLE` manual). En MVP basta archivos `.sql` numerados o herramienta como `drizzle-kit`/`prisma migrate`/`knex`.
- No hay PII sin que esté identificada (al menos un comentario en el schema diciendo "este campo es PII").

---

## Checklist (referencia para graduar)

### Data model
- [ ] Schema versionado (cada cambio es una migración).
- [ ] Foreign keys declarados donde aplican.
- [ ] Constraints (NOT NULL, UNIQUE, CHECK) usados, no solo validación en app.
- [ ] Índices sobre columnas usadas en WHERE/JOIN frecuentes.

### Migrations
- [ ] Migraciones son archivos en repo, no comandos manuales.
- [ ] Cada migración es reversible (`up` + `down`) o documentada como irreversible con razón.
- [ ] Migraciones probadas en staging antes de prod.
- [ ] Plan de rollback documentado para migraciones destructivas.

### Backup & restore
- [ ] Backup automatizado al menos diario (provider managed: RDS automated, Supabase backups, etc.).
- [ ] Restore probado al menos 1 vez (no es backup hasta que se restaura).
- [ ] RPO (Recovery Point Objective) y RTO (Recovery Time Objective) documentados.

### PII & data classification
- [ ] PII identificada en schema (comentario, anotación, o tabla de clasificación).
- [ ] PII no se loguea ni se serializa accidentalmente.
- [ ] Mecanismo de "right to erasure" pensado (delete cascade, anonimización).
- [ ] Retention policy documentada al graduar.

### Data integrity
- [ ] Validación en app **y** en DB (defensa en profundidad).
- [ ] Operaciones multi-tabla en transacción.
- [ ] Tests de integridad referencial (no quedan FKs huérfanas).

---

## Anti-patrones (banderas rojas)

- **`ALTER TABLE` manual en prod** — irreproducible, perdés history. Siempre via migración versionada.
- **Schema-less que crece sin control** — JSON column con 30 keys distintas según el row. Considerar normalizar si las queries lo necesitan.
- **PII en plaintext columns sin necesidad** — tokens, passwords. Hash o encrypt at rest.
- **`SELECT *` en prod** — leak de columnas que no querías exponer (incluyendo nuevas que se agregan después).
- **Borrado físico sin auditoría** — perdés capacidad de investigar incidentes. Considerar soft delete o tabla de auditoría.
- **DB shared para multi-tenant sin RLS** — bug de query de un tenant ve datos de otros. Catastrófico.
- **Migraciones sin idempotencia** — corres dos veces y rompe. `IF NOT EXISTS` donde aplique.
