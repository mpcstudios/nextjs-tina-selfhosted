# MPC Studios — Next.js + TinaCMS Self-Hosted Starter

A Next.js 15 starter template with self-hosted TinaCMS for visual content editing, Tailwind CSS, TypeScript, and Claude Code workflow.

Includes: Git-backed content, username/password auth, S3 media uploads, Upstash Redis database.

## One-Click Deploy

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fmpcstudios%2Fnextjs-tina-selfhosted&env=GITHUB_PERSONAL_ACCESS_TOKEN,NEXTAUTH_SECRET,S3_ACCESS_KEY,S3_SECRET_KEY,S3_REGION,S3_BUCKET,ENABLE_EXPERIMENTAL_COREPACK&envDescription=See%20.env.example%20in%20the%20repo%20for%20details%20on%20each%20variable.%20ENABLE_EXPERIMENTAL_COREPACK%20should%20be%20set%20to%201.&envLink=https%3A%2F%2Fgithub.com%2Fmpcstudios%2Fnextjs-tina-selfhosted%2Fblob%2Fmain%2F.env.example&project-name=my-tina-site&stores=%5B%7B%22type%22%3A%22kv%22%7D%5D)

This will:
1. Copy this repo to your GitHub account
2. Create a Vercel project
3. Create an Upstash KV database (auto-sets `KV_REST_API_URL` and `KV_REST_API_TOKEN`)
4. Prompt you for the remaining environment variables

After deploy, log in to the CMS at `https://your-site.vercel.app/admin` with **tinauser** / **tinarocks**.

## What you need before deploying

| Variable | Where to get it |
|----------|----------------|
| `GITHUB_PERSONAL_ACCESS_TOKEN` | [GitHub Settings → Personal Access Tokens](https://github.com/settings/personal-access-tokens/new) — needs `repo` scope |
| `NEXTAUTH_SECRET` | Run `openssl rand -base64 32` in your terminal |
| `S3_ACCESS_KEY` | AWS IAM user credentials |
| `S3_SECRET_KEY` | AWS IAM user credentials |
| `S3_REGION` | e.g., `us-east-1` |
| `S3_BUCKET` | Your S3 bucket name |
| `ENABLE_EXPERIMENTAL_COREPACK` | Set to `1` |

## Local Development

```bash
pnpm install
pnpm dev
```

- Site: http://localhost:3000
- CMS Admin: http://localhost:3000/admin (no login needed locally)

## Full Setup Instructions

See `setup.txt` for detailed human and Claude Code setup paths.
