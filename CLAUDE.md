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