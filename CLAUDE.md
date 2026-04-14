# Project Context

See `PROJECT_BRIEF.md` for full project details, goals, and brand direction.

---

# Before Writing Any Code

Follow all process, design, and content guidelines in `agents/website-design-skill.md` before writing any code.

---

# Stack

- **Framework:** Next.js (App Router) — Server Components by default, `'use client'` only when needed
- **Styling:** Tailwind CSS only — no CSS modules, no inline styles
- **Language:** TypeScript strict mode — no `any` types
- **Hosting:** Vercel / GitHub

---

# Folder Structure

```
/app              → Routes and pages
/app/api          → API route handlers
/components       → Reusable UI components
/components/ui    → Base UI primitives
/lib              → Utilities and helpers
/types            → Shared TypeScript types
/public           → Static assets
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