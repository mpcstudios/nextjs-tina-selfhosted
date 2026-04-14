# MPC Studios — Next.js + TinaCMS Self-Hosted Starter

A Next.js 15 starter template with self-hosted TinaCMS for visual content editing, Tailwind CSS, TypeScript, and Claude Code workflow.

Includes: Git-backed content, username/password auth, S3 media uploads, Upstash Redis database.

## One-Click Deploy

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fmpcstudios%2Fnextjs-tina-selfhosted&env=GITHUB_PERSONAL_ACCESS_TOKEN,NEXTAUTH_SECRET,S3_ACCESS_KEY,S3_SECRET_KEY,S3_MEDIA_ROOT,ENABLE_EXPERIMENTAL_COREPACK&envDescription=S3%20uses%20the%20shared%20mpcstudios-media%20bucket.%20Set%20S3_MEDIA_ROOT%20to%20your%20project%20name.%20ENABLE_EXPERIMENTAL_COREPACK%20%3D%201.&envLink=https%3A%2F%2Fgithub.com%2Fmpcstudios%2Fnextjs-tina-selfhosted%2Fblob%2Fmain%2F.env.example&project-name=my-tina-site&stores=%5B%7B%22type%22%3A%22kv%22%7D%5D)

This will:
1. Copy this repo to your GitHub account
2. Create a Vercel project
3. Create an Upstash KV database (auto-sets `KV_REST_API_URL` and `KV_REST_API_TOKEN`)
4. Prompt you for the remaining environment variables

After deploy, log in to the CMS at `https://your-site.vercel.app/admin` with **tinauser** / **tinarocks**.

## What you need before deploying

| Variable | Value |
|----------|-------|
| `GITHUB_PERSONAL_ACCESS_TOKEN` | [Create a token](https://github.com/settings/personal-access-tokens/new) with `repo` scope |
| `NEXTAUTH_SECRET` | Run `openssl rand -base64 32` in your terminal |
| `S3_ACCESS_KEY` | Shared MPC AWS credentials (ask your team) |
| `S3_SECRET_KEY` | Shared MPC AWS credentials (ask your team) |
| `S3_MEDIA_ROOT` | Your project name (e.g., `client-name`) — this is the folder in the shared S3 bucket |
| `ENABLE_EXPERIMENTAL_COREPACK` | `1` |

**Note:** `S3_BUCKET` (`mpcstudios-media`) and `S3_REGION` (`us-east-1`) are pre-configured in the code. All MPC sites share one S3 bucket — each site gets its own folder via `S3_MEDIA_ROOT`.

## Local Development

```bash
pnpm install
pnpm dev
```

- Site: http://localhost:3000
- CMS Admin: http://localhost:3000/admin (no login needed locally)

## Full Setup Instructions

See `setup.txt` for detailed human and Claude Code setup paths.
