#!/usr/bin/env bash
# scripts/spinup-site.sh — automate post-deploy setup for a new MPC site
#
# Run this from the root of a freshly-cloned site repo (created via
# `gh repo create mpcstudios/<slug> --template mpcstudios/nextjs-tina-selfhosted-v2`).
#
# Prerequisites: gh, vercel, infisical, jq, curl all installed and authenticated.
#
# What it does:
#   1. Loads (or prompts for) Infisical Machine Identity creds
#   2. Authenticates to Infisical API via Universal Auth
#   3. Creates a Vercel project + Upstash KV
#   4. Pauses for you to install the GitHub App on this repo (browser)
#   5. Creates an Infisical project (site-<slug>) and links via .infisical.json
#   6. Pushes per-site secrets (GitHub App installation ID, NEXTAUTH_SECRET, etc.)
#   7. Pulls Vercel KV env vars into Infisical
#   8. Creates two Vercel Secret Syncs (site + mpc-shared) so secrets flow
#      from Infisical to Vercel automatically
#   9. Triggers the first real deploy
#  10. Prints verification commands

set -euo pipefail

# ─── Constants (the org-level identifiers) ────────────────────────────────────
INFISICAL_API="https://app.infisical.com"
INFISICAL_ORG_ID="3e9a0595-6f8b-43fb-9b8b-de89f4303093"
MPC_SHARED_PROJECT_ID="6b753036-9bde-485b-a1ff-bc1abfb9a478"
VERCEL_APP_CONNECTION_ID="a120f4ee-414d-4ca7-bb54-d43f29057c86"
GITHUB_APP_INSTALL_URL="https://github.com/apps/mpc-studios-cms/installations/new"
VERCEL_TEAM="mpcstudios"

# ─── Helpers ──────────────────────────────────────────────────────────────────
red()    { printf '\033[31m%s\033[0m\n' "$*" >&2; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
bold()   { printf '\033[1m%s\033[0m\n' "$*"; }
die()    { red "ERROR: $*"; exit 1; }
have()   { command -v "$1" >/dev/null 2>&1 || die "Missing CLI: $1"; }

# ─── 0. Pre-flight checks ─────────────────────────────────────────────────────
bold "→ Pre-flight checks"
have gh
have vercel
have infisical
have jq
have curl
have openssl

gh auth status >/dev/null 2>&1 || die "gh not authenticated. Run: gh auth login"
vercel whoami >/dev/null 2>&1 || die "vercel not authenticated. Run: vercel login"
# infisical user check is via 'infisical user' which echoes help if no subcommand;
# the only signal of "logged in" is having an active session — we'll rely on the
# CLI's own checks downstream when we run `infisical secrets set`.

[ -d .git ] || die "Not a git repo. Run this from the new site's root."
SLUG=$(gh repo view --json name --jq .name 2>/dev/null) \
  || die "Couldn't read repo from gh. Are you in the new site's directory?"
green "  ✓ slug: $SLUG"

# ─── 1. Load (or prompt for) Infisical Machine Identity creds ─────────────────
AUTH_FILE="$HOME/.config/mpc-spinup/auth.env"
if [ ! -f "$AUTH_FILE" ]; then
  yellow "First-time setup on this machine."
  echo "I need your Infisical Machine Identity credentials (the mpc-spinup-bot identity)."
  echo "Get them from your team lead / 1Password."
  read -r -p "Client ID: " CID
  read -r -s -p "Client Secret: " CSEC
  echo
  mkdir -p "$(dirname "$AUTH_FILE")"
  umask 077
  printf 'INFISICAL_AUTH_CLIENT_ID="%s"\nINFISICAL_AUTH_CLIENT_SECRET="%s"\n' "$CID" "$CSEC" > "$AUTH_FILE"
  chmod 600 "$AUTH_FILE"
  green "  ✓ saved to $AUTH_FILE (mode 600)"
fi
set -a; . "$AUTH_FILE"; set +a
[ -n "${INFISICAL_AUTH_CLIENT_ID:-}" ] || die "INFISICAL_AUTH_CLIENT_ID empty in $AUTH_FILE"
[ -n "${INFISICAL_AUTH_CLIENT_SECRET:-}" ] || die "INFISICAL_AUTH_CLIENT_SECRET empty in $AUTH_FILE"

# ─── 2. Authenticate to Infisical API ─────────────────────────────────────────
bold "→ Authenticating to Infisical API"
TOKEN=$(curl -fsS -X POST "$INFISICAL_API/api/v1/auth/universal-auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"clientId\":\"$INFISICAL_AUTH_CLIENT_ID\",\"clientSecret\":\"$INFISICAL_AUTH_CLIENT_SECRET\"}" \
  | jq -r '.accessToken // empty')
[ -n "$TOKEN" ] || die "Infisical auth failed. Check $AUTH_FILE."
green "  ✓ token obtained"
api() { curl -fsS -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" "$@"; }

# ─── 3. Create Vercel project + Upstash KV ────────────────────────────────────
bold "→ Vercel project ($SLUG)"
if [ ! -f .vercel/project.json ]; then
  if ! vercel project inspect "$SLUG" --scope "$VERCEL_TEAM" >/dev/null 2>&1; then
    vercel project add "$SLUG" --scope "$VERCEL_TEAM" >/dev/null 2>&1 \
      || die "Failed to create Vercel project."
    green "  ✓ project created"
  else
    green "  ✓ project already exists"
  fi
  vercel link --yes --project "$SLUG" --scope "$VERCEL_TEAM" >/dev/null 2>&1 \
    || die "vercel link failed."
fi
green "  ✓ linked"

bold "→ Connecting Vercel project to GitHub repo (auto-deploys on push)"
vercel git connect --yes >/dev/null 2>&1 || die "vercel git connect failed."
green "  ✓ git connected"

bold "→ Provisioning Upstash for Redis"
if vercel env ls production 2>/dev/null | grep -q "KV_REST_API_URL"; then
  green "  ✓ already provisioned (KV_REST_API_URL exists)"
else
  vercel integration add upstash/upstash-kv \
    --environment production \
    --name "upstash-$SLUG" >/dev/null 2>&1 \
    || die "Failed to provision Upstash KV."
  green "  ✓ provisioned"
fi

# ─── 4. GitHub App install (browser, can't avoid) ─────────────────────────────
bold "→ GitHub App install"
if [ -n "${GITHUB_APP_INSTALLATION_ID:-}" ]; then
  INSTALLATION_ID="$GITHUB_APP_INSTALLATION_ID"
  green "  ✓ using GITHUB_APP_INSTALLATION_ID from env: $INSTALLATION_ID"
else
  echo
  echo "  Open this URL: $GITHUB_APP_INSTALL_URL"
  echo "  Pick 'Only select repositories', choose '$SLUG', click Install."
  echo "  After install, the URL will end in /installations/<NUMBER>."
  echo
  read -r -p "  Paste the installation ID: " INSTALLATION_ID
  [ -n "$INSTALLATION_ID" ] || die "Installation ID is required."
  green "  ✓ installation ID captured"
fi

# ─── 5. Create Infisical project ──────────────────────────────────────────────
bold "→ Creating Infisical project (site-$SLUG)"
PROJECT_RESP=$(api -X POST "$INFISICAL_API/api/v2/workspace" \
  -d "{\"projectName\":\"site-$SLUG\",\"type\":\"secret-manager\",\"description\":\"Per-site secrets for mpcstudios/$SLUG\"}" \
  2>/dev/null || true)
PROJECT_ID=$(printf '%s' "$PROJECT_RESP" | jq -r '.project.id // empty')
if [ -z "$PROJECT_ID" ]; then
  EXISTING_ID=$(api -X GET "$INFISICAL_API/api/v1/workspace" | jq -r --arg n "site-$SLUG" '.workspaces[]? | select(.name==$n) | .id' | head -1)
  if [ -n "$EXISTING_ID" ]; then
    PROJECT_ID="$EXISTING_ID"
    yellow "  Project already exists, using existing: $PROJECT_ID"
  else
    die "Project creation failed: $PROJECT_RESP"
  fi
else
  green "  ✓ created: $PROJECT_ID"
fi

printf '{"workspaceId":"%s","defaultEnvironment":"","gitBranchToEnvironmentMapping":null}\n' "$PROJECT_ID" > .infisical.json
green "  ✓ wrote .infisical.json"

# ─── 6. Push per-site secrets via Infisical CLI (silent) ──────────────────────
# Use Machine Identity token explicitly so we don't rely on the CLI user being
# a member of the freshly-created project.
bold "→ Pushing per-site secrets (silently)"
NEXTAUTH_SECRET_VAL=$(openssl rand -base64 32)
infisical secrets set --env=prod --silent \
  --token="$TOKEN" --projectId="$PROJECT_ID" \
  GITHUB_APP_INSTALLATION_ID="$INSTALLATION_ID" \
  S3_MEDIA_ROOT="$SLUG" \
  ENABLE_EXPERIMENTAL_COREPACK="1" \
  NEXTAUTH_SECRET="$NEXTAUTH_SECRET_VAL" \
  > /dev/null 2>&1 \
  || die "Failed to push per-site secrets."
unset NEXTAUTH_SECRET_VAL
green "  ✓ per-site secrets pushed"

# ─── 7. Pull KV vars from Vercel and push to Infisical (silent) ───────────────
bold "→ Pulling KV vars from Vercel and pushing to Infisical"
TMP_ENV=$(mktemp)
trap 'shred -u "$TMP_ENV" 2>/dev/null || rm -f "$TMP_ENV"' EXIT
vercel env pull "$TMP_ENV" --environment=production --yes >/dev/null 2>&1 \
  || die "Failed to pull Vercel env."
set -a; . "$TMP_ENV"; set +a
infisical secrets set --env=prod --silent \
  --token="$TOKEN" --projectId="$PROJECT_ID" \
  KV_REST_API_URL="${KV_REST_API_URL:-}" \
  KV_REST_API_TOKEN="${KV_REST_API_TOKEN:-}" \
  KV_REST_API_READ_ONLY_TOKEN="${KV_REST_API_READ_ONLY_TOKEN:-}" \
  KV_URL="${KV_URL:-}" \
  REDIS_URL="${REDIS_URL:-}" \
  > /dev/null 2>&1 \
  || die "Failed to push KV vars to Infisical."
shred -u "$TMP_ENV" 2>/dev/null || rm -f "$TMP_ENV"
unset KV_REST_API_URL KV_REST_API_TOKEN KV_REST_API_READ_ONLY_TOKEN KV_URL REDIS_URL
green "  ✓ KV vars pushed"

# ─── 8. Create Vercel Secret Syncs ────────────────────────────────────────────
VERCEL_PROJECT_ID=$(jq -r .projectId .vercel/project.json)
VERCEL_TEAM_ID=$(jq -r .orgId .vercel/project.json)
[ -n "$VERCEL_PROJECT_ID" ] || die "Couldn't read Vercel projectId from .vercel/project.json"
[ -n "$VERCEL_TEAM_ID" ] || die "Couldn't read Vercel teamId (orgId) from .vercel/project.json"

create_vercel_sync() {
  local sync_name="$1"
  local source_project_id="$2"
  api -X POST "$INFISICAL_API/api/v1/secret-syncs/vercel" -d "{
    \"name\": \"$sync_name\",
    \"projectId\": \"$source_project_id\",
    \"connectionId\": \"$VERCEL_APP_CONNECTION_ID\",
    \"environment\": \"prod\",
    \"secretPath\": \"/\",
    \"isAutoSyncEnabled\": true,
    \"syncOptions\": {
      \"initialSyncBehavior\": \"overwrite-destination\",
      \"disableSecretDeletion\": true
    },
    \"destinationConfig\": {
      \"scope\": \"project\",
      \"app\": \"$VERCEL_PROJECT_ID\",
      \"appName\": \"$SLUG\",
      \"env\": \"production\",
      \"teamId\": \"$VERCEL_TEAM_ID\"
    }
  }" >/dev/null
}

bold "→ Creating Vercel sync for site-$SLUG → Vercel"
create_vercel_sync "vercel-sync" "$PROJECT_ID" \
  || die "Failed to create site sync."
green "  ✓ site sync created"

bold "→ Creating Vercel sync for mpc-shared → Vercel ($SLUG)"
create_vercel_sync "mpc-shared-sync-$SLUG" "$MPC_SHARED_PROJECT_ID" \
  || die "Failed to create mpc-shared sync."
green "  ✓ mpc-shared sync created"

# ─── 9. Trigger first real deploy ─────────────────────────────────────────────
bold "→ Triggering first deploy"
git commit --allow-empty -m "Trigger initial deploy after Infisical setup" >/dev/null
git push >/dev/null 2>&1
green "  ✓ pushed"

# ─── 10. Verification instructions ────────────────────────────────────────────
echo
bold "════════════════════════════════════════════════════"
green "Setup complete!"
bold "════════════════════════════════════════════════════"
echo
echo "  Watch the deploy:    vercel ls --prod | grep $SLUG"
echo "  Live site:           https://$SLUG.vercel.app"
echo "  CMS admin:           https://$SLUG.vercel.app/admin   (login: tinauser / tinarocks)"
echo
echo "  Verify after first edit:"
echo "    gh api /repos/mpcstudios/$SLUG/commits?per_page=1 --jq '.[0].commit.author.name'"
echo "    Expected: mpc-studios-cms[bot]"
echo
