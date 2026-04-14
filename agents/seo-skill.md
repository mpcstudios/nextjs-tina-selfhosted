# SEO Skill

You are an SEO specialist. Every page you build must be fully optimized for search engines and social sharing out of the box. SEO is not an afterthought — it is built in from the start.

---

## 1. Before Writing Any Page

Read `PROJECT_BRIEF.md` to understand:
- The business, its location, and its audience
- The primary keywords and services
- The geographic focus (local SEO vs. national)

Use this context to inform all meta titles, descriptions, and structured data.

---

## 2. Metadata — Every Page

Every page must export a `metadata` object using Next.js built-in metadata API:

```typescript
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Page Title | Brand Name',
  description: 'Concise, compelling description under 160 characters.',
  openGraph: {
    title: 'Page Title | Brand Name',
    description: 'Concise, compelling description under 160 characters.',
    url: 'https://www.domain.com/page',
    siteName: 'Brand Name',
    images: [
      {
        url: 'https://www.domain.com/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Descriptive alt text',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Page Title | Brand Name',
    description: 'Concise, compelling description under 160 characters.',
    images: ['https://www.domain.com/og-image.jpg'],
  },
  robots: {
    index: true,
    follow: true,
  },
  alternates: {
    canonical: 'https://www.domain.com/page',
  },
}
```

**Rules:**
- Title: 50–60 characters max
- Description: 120–160 characters max
- Every page gets a unique title and description — never duplicate
- Canonical URL on every page
- OG image: 1200x630px, saved to `/public/og/`

---

## 3. Root Layout Metadata

`app/layout.tsx` must include base metadata with `metadataBase`:

```typescript
export const metadata: Metadata = {
  metadataBase: new URL('https://www.domain.com'),
  title: {
    default: 'Brand Name — Tagline',
    template: '%s | Brand Name',
  },
  description: 'Default site description.',
}
```

---

## 4. Semantic HTML & Heading Hierarchy

- One `<h1>` per page — never more
- Heading order must be logical: `h1` → `h2` → `h3` — never skip levels
- Use `<article>`, `<section>`, `<nav>`, `<main>`, `<header>`, `<footer>` correctly
- Never use headings for styling — use them for structure only

---

## 5. Structured Data (JSON-LD)

Add relevant structured data to pages using a `<Script>` component in Next.js:

**Local Business (for local/service businesses):**
```typescript
const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'LocalBusiness',
  name: 'Business Name',
  description: 'Business description',
  url: 'https://www.domain.com',
  telephone: '+19561234567',
  address: {
    '@type': 'PostalAddress',
    streetAddress: '123 Main St',
    addressLocality: 'City',
    addressRegion: 'TX',
    postalCode: '78000',
    addressCountry: 'US',
  },
}
```

**Website:**
```typescript
const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'WebSite',
  name: 'Brand Name',
  url: 'https://www.domain.com',
}
```

---

## 6. Images

- Every `<Image>` must have a descriptive `alt` tag — never empty unless purely decorative
- Descriptive file names: `construction-aggregate-south-texas.jpg` not `IMG_1234.jpg`
- Next.js `<Image>` handles WebP/AVIF conversion automatically — always use it

---

## 7. Sitemap & Robots

Create `app/sitemap.ts`:

```typescript
import { MetadataRoute } from 'next'

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    { url: 'https://www.domain.com', lastModified: new Date(), changeFrequency: 'monthly', priority: 1 },
    { url: 'https://www.domain.com/about', lastModified: new Date(), changeFrequency: 'monthly', priority: 0.8 },
    { url: 'https://www.domain.com/contact', lastModified: new Date(), changeFrequency: 'yearly', priority: 0.5 },
  ]
}
```

Create `app/robots.ts`:

```typescript
import { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  return {
    rules: { userAgent: '*', allow: '/' },
    sitemap: 'https://www.domain.com/sitemap.xml',
  }
}
```

---

## 8. Performance & Core Web Vitals

- Always use Next.js `<Image>` — never `<img>` tags
- Always set `width` and `height` on images to prevent layout shift (CLS)
- Use `priority` prop on hero/above-the-fold images
- Fonts loaded via `next/font` — never `<link>` tags
- No render-blocking scripts

---

## 9. Local SEO (when applicable)

If the project is a local or regional business (read `PROJECT_BRIEF.md`):
- Include city and region in page titles where natural
- Include full address and phone number in footer and contact page
- Add LocalBusiness structured data on the homepage
- Include a Google Maps embed on the contact page
- Use location-specific language in headings and copy

---

## 10. What to Avoid

- Duplicate title tags or meta descriptions across pages
- Missing canonical URLs
- `<img>` tags instead of Next.js `<Image>`
- Empty or missing `alt` text
- Multiple `<h1>` tags on a single page
- Skipping structured data on business sites
- Generic file names for images
- Missing sitemap or robots.txt