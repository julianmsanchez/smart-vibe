# SSOT (Single Sources of Truth secundarios)

> Esta carpeta es para **información operativa estable** que no cabe en el PHS pero que es punto de referencia único: contactos, links externos importantes, cuentas que usa el proyecto, env vars descritas, accesos a dashboards, recurrencias, etc.

> **No** es para metadata del proyecto (eso es `phs.yaml`). **No** es para decisiones arquitectónicas (eso es `docs/decisions/` en el repo). **Sí** es para "estos son los datos operativos que necesitás para operar el proyecto".

---

## Qué archivos viven acá

Crear archivos `.md` por tema. Sugeridos según vayas necesitándolos:

| Archivo sugerido | Cuando crearlo |
|---|---|
| `accounts.md` | Cuando uses ≥2 servicios externos con cuentas. Lista cuentas, owners, billing. |
| `env-vars.md` | Cuando `.env.example` no alcance (ej: vars con setup ritual, rotación, etc.). |
| `external-services.md` | APIs externas usadas, URLs, status pages, links a docs. |
| `dashboards.md` | Links a dashboards (analytics, observability, billing). |
| `contacts.md` | Owners de servicios externos, contactos de soporte. |
| `recurring-tasks.md` | Tareas recurrentes (ej: rotar X cada 90d, revisar Y mensualmente). |

---

## Reglas

1. **Un tema por archivo.** No archivos enormes mezclando todo.
2. **Sin secretos.** Nunca passwords, tokens, API keys. Si hay que referenciar, usar nombre de la var de entorno.
3. **Updatear cuando cambia.** Si dejás un dato desactualizado, mejor borrarlo que mentir.
4. **Link a fuentes externas cuando aplique.** Esta wiki no es para duplicar info que ya vive en otros lados.

---

## Ejemplo de archivo (`accounts.md`)

```markdown
# Accounts

## Vercel
- **Owner:** Juan
- **Plan:** Hobby
- **URL:** https://vercel.com/juan-team
- **Billing:** card ****1234

## Supabase
- **Owner:** Juan
- **Plan:** Free
- **URL:** https://supabase.com/dashboard/project/...
- **Notas:** free tier hasta 50K rows/month
```

---

> Si esta carpeta crece mucho, podés organizarla con subcarpetas. Si crece poco, está bien con archivos planos.
