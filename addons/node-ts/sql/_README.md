# `sql/` — migraciones y seed data

Carpeta convencional para SQL del proyecto. En modo vibe vale tener migraciones simples como archivos numerados; al graduar conviene una herramienta dedicada (`drizzle-kit`, `prisma migrate`, `knex`, `node-pg-migrate`).

## Estructura sugerida

```
sql/
├── migrations/
│   ├── 0001_init.sql
│   ├── 0002_add_users.sql
│   └── ...
├── seeds/
│   └── dev_seed.sql
└── _README.md
```

## Convenciones

- **Numeración monotónica** — `NNNN_descripcion.sql`, sin saltos.
- **Idempotencia** donde sea posible — `CREATE TABLE IF NOT EXISTS`, `CREATE INDEX IF NOT EXISTS`.
- **Una migración = un cambio coherente** (no mezclar ALTER de 3 tablas distintas).
- **Reversibilidad** — para cada `up`, considerar `down` (puede vivir en otro archivo `NNNN_descripcion.down.sql` o como comentario).
- **Sin DROP destructivo en migraciones automáticas** — drops manuales con backup previo.

## Cuándo migrar a una tool dedicada

Antes de graduar:

- Cuando hay >10 migraciones.
- Cuando el equipo crece >2 personas.
- Cuando necesitás rollback automatizado en CD.

## PII

Marcá las columnas con PII en comentarios SQL:

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,        -- PII: email
  full_name TEXT,                     -- PII: nombre completo
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

Esto permite generar `data-classification.md` automáticamente al graduar.
