# QA Skill

You are a senior QA engineer. Before any page or feature is considered complete, run through this checklist in full. Do not skip sections. Report every issue found and fix them before signing off.

---

## How to invoke this skill

When the user says "QA this page" or "run QA" or "is this ready for the client":
1. Review the relevant code and rendered output
2. Work through every section of this checklist
3. Report a summary of issues found with severity (Critical / Warning / Minor)
4. Fix all Critical and Warning issues before marking complete

---

## 1. Design & Visual

- [ ] Does the page follow the design direction in `agents/website-design-skill.md`?
- [ ] Is there a clear visual hierarchy on every section?
- [ ] Are fonts loading correctly — no system font fallbacks visible?
- [ ] Is the color palette consistent — no hardcoded hex values in components?
- [ ] Are there no 3-equal-card layouts or generic centered hero sections?
- [ ] Does the page feel intentional and designed — not like a template?
- [ ] Is spacing consistent — section padding `py-16` to `py-24`?
- [ ] Are shadows layered and color-tinted — no flat `shadow-md` alone?

---

## 2. Responsive & Mobile

- [ ] Does the layout work correctly on mobile (375px width)?
- [ ] Does the layout work correctly on tablet (768px width)?
- [ ] Does the layout work correctly on desktop (1280px+)?
- [ ] Do all asymmetric layouts collapse cleanly to single-column on mobile?
- [ ] Is `min-h-[100dvh]` used for full-height sections — no `h-screen`?
- [ ] Is the mobile navigation fully functional?
- [ ] Are touch targets large enough (minimum 44x44px)?
- [ ] Is there any horizontal scrolling on mobile? (There should not be)

---

## 3. Typography

- [ ] Is there exactly one `<h1>` per page?
- [ ] Is heading hierarchy logical (h1 → h2 → h3 — no skipped levels)?
- [ ] Is body text `text-base` minimum — nothing smaller?
- [ ] Is `leading-[1.7]` applied to body text?
- [ ] Are distinctive fonts loading — no Inter, Arial, or system fonts?
- [ ] Is line length capped at `max-w-[65ch]` for body text?

---

## 4. Interaction & States

- [ ] Do all buttons have `hover:`, `focus-visible:`, and `active:` states?
- [ ] Do all links have visible hover and focus states?
- [ ] Is `active:scale-[0.98]` applied to all buttons?
- [ ] Are focus rings visible for keyboard navigation?
- [ ] Are transitions using specific properties — no `transition-all`?
- [ ] Do all data-dependent components handle loading states?
- [ ] Do all data-dependent components handle empty states?
- [ ] Do all data-dependent components handle error states?

---

## 5. Accessibility

- [ ] Are semantic HTML elements used correctly (`<nav>`, `<main>`, `<section>`, etc.)?
- [ ] Do all images have descriptive `alt` text?
- [ ] Is color contrast meeting WCAG AA (4.5:1 body, 3:1 large text)?
- [ ] Is the page fully navigable by keyboard?
- [ ] Are form labels above their inputs — never placeholder-only?
- [ ] Do forms have visible error and focus states?

---

## 6. SEO

- [ ] Does every page have a unique `metadata` export with title and description?
- [ ] Is the title 50–60 characters?
- [ ] Is the description 120–160 characters?
- [ ] Are Open Graph tags present?
- [ ] Is a canonical URL set?
- [ ] Is structured data (JSON-LD) present where applicable?
- [ ] Does `app/layout.tsx` have `metadataBase` set?
- [ ] Does `sitemap.ts` include this page?

---

## 7. Performance

- [ ] Are all images using Next.js `<Image>` — no `<img>` tags?
- [ ] Do all images have `width` and `height` set?
- [ ] Do hero/above-the-fold images have the `priority` prop?
- [ ] Are fonts loaded via `next/font` — no `<link>` tags?
- [ ] Are only `transform` and `opacity` being animated?

---

## 8. Code Quality

- [ ] Are there any `any` types in TypeScript?
- [ ] Are there any hardcoded hex values in components?
- [ ] Are `@/` path aliases used — no relative `../../` imports?
- [ ] Are there any default exports from `/lib` or `/types`?
- [ ] Are there any `useEffect` calls for data that could be fetched server-side?
- [ ] Are all `'use client'` directives justified?

---

## 9. Content

- [ ] Is all placeholder copy replaced with real or realistic content?
- [ ] Are there no lorem ipsum strings anywhere?
- [ ] Are there no generic AI clichés ("Elevate", "Seamless", "Unleash")?
- [ ] Is the phone number and address correct (if applicable)?
- [ ] Are all links working — no broken hrefs or `#` placeholders?
- [ ] Are all images loading — no broken image paths?

---

## 10. Pre-Client Checklist

Before sharing with the client, confirm:

- [ ] Site builds without errors (`next build`)
- [ ] No console errors or warnings in the browser
- [ ] All pages are reachable from the navigation
- [ ] Contact form submits correctly and sends confirmation
- [ ] Site is deployed to Vercel and the preview URL is working
- [ ] Environment variables are set in Vercel dashboard
- [ ] `vercel.json` security headers are in place

---

## Severity Guide

**Critical** — Broken functionality, missing pages, console errors, build failures. Must fix before sharing with client.

**Warning** — Design inconsistencies, missing SEO tags, accessibility issues, missing states. Should fix before sharing with client.

**Minor** — Small visual polish issues, minor copy improvements. Fix when possible.