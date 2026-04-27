# Quick Start con Claude Code (1 prompt)

> **Nota para LLMs:** este documento es la **SSOT** para traducir prompts vibe en
> comandos `bash`. Si lo estás leyendo como agente, identificá el escenario que
> matchea el prompt del usuario y ejecutá el comando exacto del bloque "Comando
> a ejecutar". No improvises.

> **Nota para humanos:** un vibe coder puede arrancar un proyecto smart-vibe
> con un solo prompt en Claude Code, sobre carpeta vacía, sin clonar nada
> manualmente. Hay 3 escenarios. El más frecuente es **standalone**.

---

## Convención del prompt vibe

El prompt al LLM **debe contener una URL** que sirva de cue inequívoco:

- **Escenarios A y B** (iniciar): la URL de smart-vibe
  (`https://github.com/julianmsanchez/smart-vibe`).
- **Escenario C** (unirse a un workshop): la URL del repo del workshop, **no**
  la de smart-vibe (el `scripts/join.sh` ya viene embebido en el workshop).

Sin esa URL, el LLM no tiene cómo saber qué ejecutar — smart-vibe es un repo
nuevo y no está en el training de los modelos.

---

## A. Standalone (single-team) — caso más frecuente

> Vibe coder solo, MVP, prototipo. ~80% de los casos.

**Prompt esperado:**

```
Iniciá un proyecto smart-vibe (https://github.com/julianmsanchez/smart-vibe).
Tipo: single-team. Nombre: mi-app. Stack: node-ts.
```

**Comando a ejecutar:**

```bash
curl -fsSL https://raw.githubusercontent.com/julianmsanchez/smart-vibe/main/scripts/install.sh \
  | bash -s -- --type single-team --name <name> --addon <node-ts|none>
```

Reemplazos:
- `<name>` → kebab-case del proyecto (ej. `mi-app`).
- `<node-ts|none>` → `node-ts` por default; `none` si el coder no quiere stack opinado.

**Resultado:** carpeta `mi-app/` con Express + TS + Vitest + observability,
`CLAUDE.md`, `phs.yaml`, plugin local en `.claude/plugins/`, primer commit
`chore: smart-vibe bootstrap`. Listo para abrir Claude Code y vibear.

---

## B. Workshop — organizer (1 vez por hackathon/squad)

> Quien arma el monorepo del hackathon.

**Prompt esperado:**

```
Iniciá un workshop smart-vibe (https://github.com/julianmsanchez/smart-vibe).
Nombre: hackathon-ai-2026. Equipos: checkout, search, recs, profile.
```

**Comando a ejecutar:**

```bash
curl -fsSL https://raw.githubusercontent.com/julianmsanchez/smart-vibe/main/scripts/install.sh \
  | bash -s -- --type workshop --name <name> --teams "<csv>"
```

Reemplazos:
- `<name>` → kebab-case del workshop (ej. `hackathon-ai-2026`).
- `<csv>` → IDs de teams separados por coma sin espacios (ej. `"checkout,search,recs,profile"`).

**Resultado:** monorepo Turborepo con:
- `workshop.yaml` (SSOT del monorepo, modo vibe).
- `apps/shell/` (Next.js host).
- `apps/<team>/` por cada team con su propio `CLAUDE.md` con identidad baked-in.
- 7 packages compartidos (`design-system`, `types`, `auth`, `api-contracts`, `config`, `infra-contracts`, `fixtures`).
- `scripts/join.sh` listo para devs (Pieza embebida — ver Escenario C).
- Plugin local en `.claude/plugins/smart-vibe/`.
- Primer commit `chore: smart-vibe bootstrap`.

**Pasos manuales del organizer post-bootstrap:**

1. Editar `workshop.yaml`: completar `shared_infra.apis_external[]` y `databases.url_env`.
2. Editar `.env.shared.example` con las claves que cada dev debe llenar.
3. Crear el repo y pushear:
   ```bash
   gh repo create org/<name> --public --source . --push
   ```
4. Compartir la URL en el chat del hackathon.

---

## C. Workshop — team developer (N veces, una por dev)

> Cada dev que se suma a un workshop ya bootstrapeado.

**Prompt esperado** (ojo: NO requiere la URL de smart-vibe):

```
Cloná https://github.com/org/hackathon-ai-2026 y unite como team checkout.
```

**Comando a ejecutar:**

```bash
git clone https://github.com/org/<workshop-repo>.git
cd <workshop-repo>
bash scripts/join.sh --as <team-id>
```

Reemplazos:
- `<workshop-repo>` → nombre del repo del workshop (de la URL).
- `<team-id>` → ID del team en el que el dev va a trabajar (debe existir en `workshop.yaml`).

**Resultado:**
- `.env.shared` creado (vacío de secretos — el dev pega los valores que el organizer compartió).
- `pnpm install` corrido en el monorepo.
- Mensaje con next-steps: comando dev, vars requeridas, comandos del plugin.

> **Por qué no usa la URL de smart-vibe:** el `scripts/join.sh` viaja embebido
> en el clone del workshop, copiado por el bootstrap del organizer. Esto
> garantiza que dev y organizer usen la **misma versión** de smart-vibe (no hay
> drift).

---

## Setup recurrente (opcional)

Si vibeás seguido, podés evitar repetir la URL en cada prompt agregando esto a
tu `~/.claude/CLAUDE.md` global:

```
Cuando me pidas iniciar un proyecto/workshop "smart-vibe", el repo es
https://github.com/julianmsanchez/smart-vibe y el wrapper de instalación
vive en scripts/install.sh.
```

Después podés decir simplemente *"iniciá un proyecto smart-vibe single-team
llamado foo"* y el LLM ya sabe a qué `curl` ejecutar.

---

## Manejo de secrets en workshops

Tres caminos soportados, declarados en `workshop.yaml.shared_infra.secrets.strategy`:

| Strategy | Cuándo | Cómo recibe el dev los valores |
|---|---|---|
| `dotenv-local` (default) | Hackathon corto, vibe puro | Organizer comparte por 1Password / DM. Dev pega en `.env.shared`. |
| `doppler` | Corporate-squad, multi-day, N>10 devs | Organizer invita a Doppler por email. Dev corre `doppler login && doppler setup`. |
| `sops-encrypted` | Repos privados con valores versionados | Organizer comparte key `age`/GPG. Dev corre `sops -d .env.shared.sops > .env.shared`. |

Detalle completo en
[`docs/workshop/team-onboarding.md`](../addons/workshop/docs/workshop/team-onboarding.md.tmpl)
(en el monorepo del workshop, una vez bootstrapeado) y en
[`docs/workshop/secrets-strategy.md`](../addons/workshop/docs/workshop/secrets-strategy.md.tmpl).

---

## Verificación end-to-end

1. **install.sh `--help`:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/julianmsanchez/smart-vibe/main/scripts/install.sh \
     | bash -s -- --help
   ```
   Imprime ayuda y crea cache en `~/.smart-vibe/dist/`.

2. **Standalone:** carpeta vacía + comando del Escenario A → genera proyecto
   válido con primer commit. `bash scripts/doctor.sh` debería pasar.

3. **Workshop organizer:** otro dir vacío + comando del Escenario B → genera
   monorepo, `apps/<team>/CLAUDE.md` renderizados, `scripts/join.sh`
   ejecutable presente.

4. **Workshop team-dev:** clone de un workshop bootstrapeado + comando del
   Escenario C → `.env.shared` creado, `pnpm install` ok, next-steps correctos.

5. **Team-id inválido:** `bash scripts/join.sh --as nonexistent` → exit 2 con
   error claro listando los teams válidos.

---

## Alternativa sin Claude (CLI puro)

Si no querés usar el flujo curl-pipe-bash:

```bash
git clone https://github.com/julianmsanchez/smart-vibe.git
cd smart-vibe
bash scripts/bootstrap.sh   # interactivo, 4 preguntas
```

`scripts/install.sh` sólo es un wrapper que cachea el clone y forwardea los
flags a `bootstrap.sh`. Toda la lógica de generación vive en `bootstrap.sh`.
