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

# TinaCMS

- **Admin panel:** `/admin` — visual content editor
- **Content:** Stored as markdown/JSON in `/content`, committed to Git
- **Collections:** Defined in `/tina/collections/` — add new content types here
- **Auth:** `tinacms-authjs` with NextAuth.js — username/password login
- **Media:** S3 uploads via `next-tinacms-s3`
- **Database:** Upstash Redis via `upstash-redis-level`
- **Dev mode:** `pnpm dev` uses local auth (no login required) and local database
- **Prod mode:** `pnpm dev:prod` uses real auth + Redis (requires `.env.local`)

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
- **`vercel.json` buildCommand overrides `package.json`:** If `vercel.json` has a `buildCommand`, it completely replaces the `build` script in `package.json`. Any post-build steps (like `scripts/patch-admin.sh`) must be added to BOTH places, or Vercel deploys will silently skip them.

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