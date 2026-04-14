# Image Generation Agent

Use this agent when a project requires AI-generated imagery instead of placeholder images.

---

## When to use this agent

Invoke this agent explicitly by saying:
> "Use the image gen agent to generate images for this project"

Do not run this automatically. Only use when requested.

---

## Setup required before running

1. Install dependencies:
   ```bash
   npm install @google/genai
   npm install -D ts-node
   ```

2. Add to `.env.local`:
   ```
   GEMINI_API_KEY=your_key_here
   ```
   Get a key at: https://aistudio.google.com

3. Add to `package.json` scripts:
   ```json
   "generate-images": "ts-node scripts/generate-images.ts"
   ```

---

## What this agent does

1. Reads `PROJECT_BRIEF.md` for project context
2. Builds image prompts based on tone, purpose, and audience
3. Calls the Gemini API to generate images
4. Saves output to `/public/images/{category}/`
5. Updates any picsum.photos references in components to use the generated images

## Output structure

```
/public/images/
  hero/
    hero-main.png
    hero-secondary.png
  backgrounds/
    bg-section-1.png
    bg-section-2.png
  team/
    team-member-1.png
    team-member-2.png
    team-member-3.png
  products/
    product-feature-1.png
    product-feature-2.png
```

---

## Script to create

Create `scripts/generate-images.ts` with the following:

```typescript
import fs from 'fs'
import path from 'path'
import { GoogleGenAI } from '@google/genai'

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY! })

const OUTPUT_DIRS = ['hero', 'backgrounds', 'team', 'products']

function ensureDirectories() {
  OUTPUT_DIRS.forEach(dir => {
    const p = path.join(process.cwd(), 'public', 'images', dir)
    if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true })
  })
}

function readProjectBrief(): string {
  const briefPath = path.join(process.cwd(), 'PROJECT_BRIEF.md')
  if (!fs.existsSync(briefPath)) throw new Error('PROJECT_BRIEF.md not found.')
  return fs.readFileSync(briefPath, 'utf-8')
}

function buildPrompts(brief: string) {
  const tone = brief.match(/Tone[^:]*:\s*(.+)/i)?.[1]?.trim() ?? 'professional and modern'
  const purpose = brief.match(/Primary objective[^:]*:\s*(.+)/i)?.[1]?.trim() ?? 'business website'
  const audience = brief.match(/Who is the target visitor[^:]*:\s*(.+)/i)?.[1]?.trim() ?? 'general audience'

  const style = `High-end editorial photography, natural lighting, shallow depth of field, mood: ${tone}. No text, no logos. Ultra realistic.`

  return [
    { category: 'hero',        filename: 'hero-main',        prompt: `Hero image for a ${purpose} targeting ${audience}. ${style}` },
    { category: 'hero',        filename: 'hero-secondary',   prompt: `Secondary feature image for a ${purpose}. ${style}` },
    { category: 'backgrounds', filename: 'bg-section-1',     prompt: `Subtle background image for a ${tone} website section. Not distracting. ${style}` },
    { category: 'backgrounds', filename: 'bg-section-2',     prompt: `Dark atmospheric background for a ${tone} site. Works behind white text. ${style}` },
    { category: 'team',        filename: 'team-member-1',    prompt: `Professional headshot, friendly and confident, ${tone} setting. No specific identity. ${style}` },
    { category: 'team',        filename: 'team-member-2',    prompt: `Professional headshot, diverse representation, ${tone} environment. ${style}` },
    { category: 'team',        filename: 'team-member-3',    prompt: `Professional headshot, natural office or outdoor setting, ${tone}. ${style}` },
    { category: 'products',    filename: 'product-feature-1', prompt: `Feature image for a ${purpose}. Clean minimal composition. ${style}` },
    { category: 'products',    filename: 'product-feature-2', prompt: `Lifestyle image showing the benefit of ${purpose} for ${audience}. ${style}` },
  ]
}

async function generateImage(prompt: string, outputPath: string) {
  const response = await ai.models.generateContent({
    model: 'gemini-2.0-flash-exp',
    contents: prompt,
  })
  for (const part of response.candidates?.[0]?.content?.parts ?? []) {
    if (part.inlineData?.data) {
      fs.writeFileSync(outputPath, Buffer.from(part.inlineData.data, 'base64'))
      console.log(`  ✓ ${outputPath.replace(process.cwd(), '')}`)
      return
    }
  }
  throw new Error(`No image returned for: ${prompt.slice(0, 60)}`)
}

async function main() {
  if (!process.env.GEMINI_API_KEY) throw new Error('GEMINI_API_KEY not set in .env.local')
  console.log('\n🍌 Generating images from PROJECT_BRIEF.md...\n')
  ensureDirectories()
  const prompts = buildPrompts(readProjectBrief())
  for (const { category, filename, prompt } of prompts) {
    const out = path.join(process.cwd(), 'public', 'images', category, `${filename}.png`)
    try { await generateImage(prompt, out) }
    catch (err) { console.error(`  ✗ ${filename}: ${err}`) }
  }
  console.log('\n✅ Done. Images saved to /public/images/\n')
}

main().catch(err => { console.error('\n❌', err.message); process.exit(1) })
```

---

## After running

- Replace any `picsum.photos` URLs in components with the generated image paths
- Use Next.js `<Image>` component for all generated images
- Commit generated images to the repo only if the client has approved them
- Re-run the script anytime the project brief changes significantly