import { Octokit } from "@octokit/rest";
import { createAppAuth } from "@octokit/auth-app";
import { Base64 } from "js-base64";
import type { GitProvider } from "@tinacms/datalayer";

export interface GitHubAppProviderOptions {
  appId: string;
  privateKey: string;
  installationId: string | number;
  owner: string;
  repo: string;
  branch: string;
  commitMessage?: string;
  rootPath?: string;
}

export class GitHubAppProvider implements GitProvider {
  octokit: Octokit;
  owner: string;
  repo: string;
  branch: string;
  rootPath?: string;
  commitMessage?: string;

  constructor(args: GitHubAppProviderOptions) {
    this.owner = args.owner;
    this.repo = args.repo;
    this.branch = args.branch;
    this.commitMessage = args.commitMessage;
    this.rootPath = args.rootPath;
    this.octokit = new Octokit({
      authStrategy: createAppAuth,
      auth: {
        appId: args.appId,
        privateKey: args.privateKey,
        installationId: args.installationId,
      },
    });
  }

  async onPut(key: string, value: string) {
    const path = this.rootPath ? `${this.rootPath}/${key}` : key;
    let sha: string | undefined;
    try {
      const { data } = await this.octokit.repos.getContent({
        owner: this.owner,
        repo: this.repo,
        path,
        ref: this.branch,
      });
      if (!Array.isArray(data) && "sha" in data) {
        sha = data.sha;
      }
    } catch (e) {}

    await this.octokit.repos.createOrUpdateFileContents({
      owner: this.owner,
      repo: this.repo,
      path,
      message: this.commitMessage || "Edited with TinaCMS",
      content: Base64.encode(value),
      branch: this.branch,
      sha,
    });
  }

  async onDelete(key: string) {
    const path = this.rootPath ? `${this.rootPath}/${key}` : key;
    let sha: string | undefined;
    try {
      const { data } = await this.octokit.repos.getContent({
        owner: this.owner,
        repo: this.repo,
        path,
        ref: this.branch,
      });
      if (!Array.isArray(data) && "sha" in data) {
        sha = data.sha;
      }
    } catch (e) {}

    if (!sha) {
      throw new Error(
        `Could not find file ${path} in repo ${this.owner}/${this.repo}`
      );
    }

    await this.octokit.repos.deleteFile({
      owner: this.owner,
      repo: this.repo,
      path,
      message: this.commitMessage || "Edited with TinaCMS",
      branch: this.branch,
      sha,
    });
  }
}
