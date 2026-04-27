# MPC Studios — Next.js + TinaCMS Self-Hosted Starter

A Next.js 15 starter template with self-hosted TinaCMS for visual content editing, Tailwind CSS, TypeScript, and a Claude Code workflow.

Includes: Git-backed content, username/password auth, S3 media uploads, Upstash Redis database, GitHub App-based commits, Infisical-managed secrets.

## One-Click Deploy

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fmpcstudios%2Fnextjs-tina-selfhosted&project-name=my-tina-site&stores=%5B%7B%22type%22%3A%22kv%22%7D%5D)

The button creates:
1. A copy of this repo in the **mpcstudios** GitHub org (set Git Scope correctly during deploy)
2. A Vercel project linked to that repo
3. An Upstash KV database (auto-sets `KV_REST_API_URL` and `KV_REST_API_TOKEN`)

The first deploy succeeds with no env vars — but `/admin` will not work yet. Secrets come next, from Infisical.

## After deploy: run the new-site setup

`cd` into your locally cloned copy of the new repo and open Claude Code. Then say:

> Run the new-site setup.

Claude Code reads `CLAUDE.md` and walks through:

1. Verifying you're logged into `infisical`, `vercel`, and `gh` CLIs
2. Installing the **MPC Studios CMS** GitHub App on your new repo (one browser click)
3. Creating an Infisical project named `site-<slug>`
4. Populating per-site secrets and importing shared secrets from `mpc-shared`
5. Configuring the Infisical → Vercel sync
6. Triggering a real deploy
7. Confirming `/admin` saves commit as `mpc-studios-cms[bot]`

The whole thing is ~5 minutes plus one browser click. If you'd rather do each step manually, follow `setup.txt`.

After setup, sign in to `https://your-site.vercel.app/admin` with **tinauser** / **tinarocks** (change the password on first login).

## Local Development

```bash
pnpm install
pnpm dev
```

- Site: http://localhost:3000
- CMS Admin: http://localhost:3000/admin (local mode — no login required, content writes to disk)

For local prod-mode testing (real Infisical secrets, real Redis, commits to your real repo), use:

```bash
infisical run --env=prod -- pnpm dev:prod
```

## Full Setup Instructions

See `setup.txt` for the manual versions of all three setup paths (Claude Code, human step-by-step, and the planned `scripts/spinup-site.sh` automation).
