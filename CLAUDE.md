# Project Context

See `PROJECT_BRIEF.md` for full project details, goals, and brand direction.

---

# Before Writing Any Code

Follow all process, design, and content guidelines in `agents/website-design-skill.md` before writing any code.

---

# Stack

- **Framework:** Next.js 15 (App Router) — Server Components by default, `'use client'` only when needed
- **CMS:** TinaCMS self-hosted — visual editing, Git-backed content, S3 media
- **Styling:** Tailwind CSS only — no CSS modules, no inline styles
- **Language:** TypeScript strict mode — no `any` types
- **Hosting:** Vercel / GitHub
- **Package Manager:** pnpm (required for ESM patches)

---

# Folder Structure

```
/app              → Routes and pages (App Router)
/components       → Reusable UI components
/components/ui    → Base UI primitives
/lib              → Utilities and helpers
/types            → Shared TypeScript types
/public           → Static assets
/tina             → TinaCMS config, database, collections
/tina/collections → Content type definitions
/pages/api        → TinaCMS + S3 API routes (Pages Router — required by TinaCMS)
/content          → Markdown/JSON content files (Git-backed)
/patches          → pnpm patches for ESM compatibility
```

---

# Code Conventions

- Fetch data at the page/layout level, pass down as props — no `useEffect` for data fetching
- One component per file, PascalCase filename matching component name
- Props interfaces defined in the same file as the component
- Named exports only from `/lib` and `/types`
- Route folders: `kebab-case` — constants: `SCREAMING_SNAKE_CASE`
- Use `@/` path aliases for all imports — never relative `../../` paths
- Load all fonts via `next/font/google` or `next/font/local` — never a `<link>` tag in layout

---

# What to Avoid

- `any` types
- `useEffect` for data that can be fetched server-side
- Hardcoded colors outside of the `@theme` block in `globals.css`
- Default exports from `/lib` or `/types`
- UI libraries unless listed in integrations above

---

# New-site setup ritual (post-deploy)

If this site has never been edited via `/admin`, run this ritual once. The user can say **"run the new-site setup"** and you (Claude Code) should drive it sequentially. The user has `infisical`, `vercel`, and `gh` CLIs pre-installed.

**Secret hygiene** — never echo secret values to chat. Use `infisical secrets set --silent ... > /dev/null 2>&1` and shred any temp files. See `~/.claude/projects/-media-ss-My-Passport-MPC-AI-Sites/memory/feedback_secret_hygiene.md` if running for Sal.

## Prerequisites (verify silently)

Run each and confirm exit 0:
```bash
infisical user             # logged in?
vercel whoami              # logged in?
gh auth status             # logged in?
```
If any fails, ask the user to log into that CLI and pause. Do not proceed.

## Step 1 — Install the GitHub App on this repo (browser)

The MPC Studios CMS App must be installed on this site's repo. This requires a browser click; you can't automate it.

Tell the user:
> Open https://github.com/apps/mpc-studios-cms/installations/new in your browser. Pick **"Only select repositories"**, choose **THIS repo**, click Install. After install, the URL ends in `/installations/<NUMBER>` — paste that number here.

Wait for the user to paste the installation ID. Save it as `INSTALLATION_ID` for the rest of the ritual.

## Step 2 — Determine the site slug

The slug is the GitHub repo name (e.g., `client-name`). Get it:
```bash
gh repo view --json name --jq .name
```
Use this as `<slug>` below. Confirm with the user before proceeding.

## Step 3 — Create the Infisical project

Today this is a UI step (Infisical CLI does not yet expose project creation). Tell the user:
> Open https://app.infisical.com → click **+ Add new project** → name it `site-<slug>` (use the slug from step 2) → create.

Wait for confirmation. Then continue.

## Step 4 — Link this repo to the new Infisical project

```bash
infisical init
```
Walk the user through picking **MPC Studios** org → **site-<slug>** project. This writes `.infisical.json` (gitignored — do not commit).

## Step 5 — Add Secret Imports from `mpc-shared` (UI)

Tell the user:
> In Infisical, open the `site-<slug>` project → click into the `prod` environment → look for **+ Add Import** (or the Imports tab) → import from `mpc-shared / prod / /`. This brings in `GITHUB_APP_ID`, `GITHUB_APP_PRIVATE_KEY`, `S3_ACCESS_KEY`, `S3_SECRET_KEY`, `S3_BUCKET`, `S3_REGION` automatically.

(If your Infisical version doesn't expose imports in the UI, skip this — the syncs will still work, you'll just have two separate Vercel sync sources later.)

## Step 6 — Push per-site secrets silently

Generate a fresh `NEXTAUTH_SECRET` and push the per-site values without echoing them:

```bash
NEXTAUTH_SECRET_VAL=$(openssl rand -base64 32)
infisical secrets set --env=prod --silent \
  GITHUB_APP_INSTALLATION_ID="$INSTALLATION_ID" \
  S3_MEDIA_ROOT="<slug>" \
  ENABLE_EXPERIMENTAL_COREPACK="1" \
  NEXTAUTH_SECRET="$NEXTAUTH_SECRET_VAL" \
  > /dev/null 2>&1
unset NEXTAUTH_SECRET_VAL
```

## Step 7 — Pull KV vars from Vercel into Infisical (silently)

```bash
vercel link --yes --project <slug>
vercel env pull /tmp/v.env --environment=production --yes > /dev/null 2>&1
set -a; source /tmp/v.env; set +a
infisical secrets set --env=prod --silent \
  KV_REST_API_URL="$KV_REST_API_URL" \
  KV_REST_API_TOKEN="$KV_REST_API_TOKEN" \
  KV_REST_API_READ_ONLY_TOKEN="$KV_REST_API_READ_ONLY_TOKEN" \
  KV_URL="$KV_URL" \
  REDIS_URL="$REDIS_URL" \
  > /dev/null 2>&1
shred -u /tmp/v.env
unset KV_REST_API_URL KV_REST_API_TOKEN KV_REST_API_READ_ONLY_TOKEN KV_URL REDIS_URL
```

## Step 8 — Set up Infisical → Vercel sync (UI)

Tell the user:
> In the `site-<slug>` Infisical project: **Integrations → Secret Syncs → + Add Sync → Vercel**.
> - **Source**: Production / `/`
> - **Destination**: App Connection `mpcstudios-vercel` → Vercel project `<slug>` → Production
> - **Initial Sync Behavior**: Overwrite Destination Secrets
> - **Disable Secret Deletion**: ON (toggle on)
> - **Auto-Sync**: ON
>
> Save. Then repeat the exact same setup in the `mpc-shared` project (same destination Vercel project + Production env). Both syncs target the same Vercel project; they coexist because deletion is disabled on both.

If the user sees no `mpcstudios-vercel` App Connection, route them to **App Connections → + Add → Vercel → API Token** and have them paste a Vercel access token (scoped to the `mpcstudios` team).

## Step 9 — Trigger first real deploy

```bash
git commit --allow-empty -m "Trigger deploy after Infisical setup" && git push
```

Watch the deploy:
```bash
vercel ls --prod
```
Wait for **Ready**. If **Error**, fetch logs and triage with the user.

## Step 10 — Verify end-to-end

Tell the user:
> Go to `https://<slug>.vercel.app/admin`, log in with `tinauser` / `tinarocks`, change the password, edit any content, save.

Then verify the commit:
```bash
gh api /repos/mpcstudios/<slug>/commits?per_page=1 --jq '.[0].commit.author.name'
```
Expect: `mpc-studios-cms[bot]`. If it says anything else, something's misconfigured — check `GITHUB_APP_INSTALLATION_ID` in Vercel.

Then test S3:
> Upload an image to the post via TinaCMS media manager.
The image URL should be `https://mpcstudios-media.s3.us-east-1.amazonaws.com/<slug>/...`. If the upload fails, check S3 keys synced from `mpc-shared`.

When all three (commit author + content live on site + image upload) work, the site is fully set up.

---

# TinaCMS

- **Admin panel:** `/admin` — visual content editor
- **Content:** Stored as markdown/JSON in `/content`, committed to Git as `mpc-studios-cms[bot]` via the GitHub App
- **Collections:** Defined in `/tina/collections/` — add new content types here
- **Auth:** `tinacms-authjs` with NextAuth.js — username/password login (default `tinauser` / `tinarocks`, change on first login)
- **Media:** S3 uploads via `next-tinacms-s3` to shared `mpcstudios-media` bucket, per-site folder via `S3_MEDIA_ROOT`
- **Database:** Upstash Redis via `upstash-redis-level`
- **Secrets:** All managed in Infisical (`mpc-shared` for cross-MPC values, `site-<slug>` for per-site). Sync pushes to Vercel automatically.
- **Dev mode:** `pnpm dev` uses local auth (no login required) and local LevelDB
- **Prod mode:** `infisical run --env=prod -- pnpm dev:prod` uses real auth + Redis with secrets injected from Infisical (no `.env.local` needed)

## Adding editable content to pages

```tsx
// In a Server Component (app/page.tsx):
import { client } from "@/tina/__generated__/databaseClient";
const res = await client.queries.page({ relativePath: "home.md" });

// In a Client Component (for visual editing):
"use client";
import { useTina, tinaField } from "tinacms/dist/react";
const { data } = useTina(props);
// Use data-tina-field={tinaField(data.page, "title")} for click-to-edit
```

## Adding new collections

1. Create a new file in `/tina/collections/`
2. Import and add it to the `collections` array in `/tina/config.tsx`
3. Create matching content in `/content/<collection-path>/`
4. Run `pnpm dev` to generate types

## Build gotchas

- **Local builds require the env flag:** Run `TINA_PUBLIC_IS_LOCAL=true pnpm build`. Without it, `tinacms build` tries to connect to production Redis and fails with `ECONNREFUSED`.
- **CMS-querying pages must be dynamic:** Any page that calls `client.queries.*` (e.g. blog listing, post detail) needs `export const dynamic = "force-dynamic"` at the top. The local LevelDB database drops its connection during Next.js static generation (`LEVEL_CONNECTION_LOST`), breaking the build.
- **No event handlers in Server Components:** Forms with `onSubmit`, buttons with `onClick`, etc. must be extracted into `"use client"` components. Next.js will throw `Event handlers cannot be passed to Client Component props` at build time otherwise.
- **Don't run concurrent `pnpm install`:** On slower filesystems (USB, network drives), parallel installs cause `ENOTEMPTY` errors. Clean `node_modules` fully before retrying if this happens.
- **External image domains must be whitelisted (placeholders only):** Next.js `<Image>` blocks external URLs by default. When using placeholder services like `picsum.photos`, add them to `images.remotePatterns` in `next.config.js`. This is not needed when images are generated locally to `/public/images/`.
- **Never combine `fill` with `width`/`height` on `<Image>`:** When using `fill`, the image sizes from its parent container. Adding explicit `width`/`height` is invalid and silently breaks rendering. Use `fill` inside a sized parent, or use `width`/`height` without `fill` — never both.

## Customizing admin panel branding

The TinaCMS admin panel (`/admin`) is a pre-built React SPA. The Tina logo is baked into the JS bundle and can't be changed via config. Instead, this starter includes a post-build patch system:

**How it works:**

1. `tinacms build` generates `public/admin/index.html` (gitignored — regenerated every build)
2. `scripts/patch-admin.sh` runs immediately after, applying three changes:
   - Replaces the page `<title>` (default: "TinaCMS" → "MPC Studios CMS")
   - Overwrites the favicon SVG with the MPC cube icon
   - Injects `scripts/admin-branding.html` before `</body>` — a script that uses `MutationObserver` to swap Tina's inline SVG logos with the MPC icon
3. The build script in `package.json` chains these: `tinacms build && bash scripts/patch-admin.sh && next build`

**To change the logo for a new project:**

1. Edit `scripts/admin-branding.html` — replace the SVG markup inside the `I` variable with your client's logo SVG
2. Edit `scripts/patch-admin.sh` — replace the favicon SVG in the heredoc and update the `<title>` text
3. The logo swap targets Tina SVGs by `viewBox` attribute:
   - `viewBox="0 0 1020 254"` — the sidebar wordmark
   - `viewBox="0 0 32 32"` — the small icon above the editor
4. Run `pnpm build` — the patch applies automatically