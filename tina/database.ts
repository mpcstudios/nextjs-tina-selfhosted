import { createDatabase, createLocalDatabase } from "@tinacms/datalayer";
import { RedisLevel } from "upstash-redis-level";
import { GitHubAppProvider } from "./github-app-provider";

const isLocal = process.env.TINA_PUBLIC_IS_LOCAL === "true";

const owner = (process.env.GITHUB_OWNER ||
  process.env.VERCEL_GIT_REPO_OWNER) as string;
const repo = (process.env.GITHUB_REPO ||
  process.env.VERCEL_GIT_REPO_SLUG) as string;
const branch = (process.env.GITHUB_BRANCH ||
  process.env.VERCEL_GIT_COMMIT_REF ||
  "main") as string;

if (!branch) {
  throw new Error(
    "No branch found. Make sure that you have set the GITHUB_BRANCH or process.env.VERCEL_GIT_COMMIT_REF environment variable."
  );
}

function makeGitProvider() {
  const appId = process.env.GITHUB_APP_ID as string;
  const privateKey = process.env.GITHUB_APP_PRIVATE_KEY as string;
  const installationId = process.env.GITHUB_APP_INSTALLATION_ID as string;
  if (!appId || !privateKey || !installationId) {
    throw new Error(
      "Missing GitHub App env vars. Set GITHUB_APP_ID, GITHUB_APP_PRIVATE_KEY, and GITHUB_APP_INSTALLATION_ID. See CLAUDE.md → New-site setup ritual."
    );
  }
  return new GitHubAppProvider({
    appId,
    privateKey,
    installationId,
    owner,
    repo,
    branch,
  });
}

export default isLocal
  ? createLocalDatabase()
  : createDatabase({
      gitProvider: makeGitProvider(),
      // @ts-expect-error RedisLevel type incompatibility with abstract-level
      databaseAdapter: new RedisLevel<string, Record<string, any>>({
        redis: {
          url:
            (process.env.KV_REST_API_URL as string) || "http://localhost:8079",
          token: (process.env.KV_REST_API_TOKEN as string) || "example_token",
        },
        debug: process.env.DEBUG === "true" || false,
      }),
      namespace: branch,
    });
