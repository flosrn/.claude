import { $ } from "bun";
import { basename, dirname, resolve } from "node:path";

export function detectWorktree(
	gitDir: string,
	commonDir: string,
	topLevel: string,
): { isWorktree: boolean; repo: string; slug: string } {
	const isWorktree = resolve(gitDir.trim()) !== resolve(commonDir.trim());
	const repo = basename(dirname(resolve(commonDir.trim())));
	const slug = basename(resolve(topLevel.trim()));
	return { isWorktree, repo, slug };
}

export interface GitStatus {
	branch: string;
	hasChanges: boolean;
	staged: {
		added: number;
		deleted: number;
		files: number;
	};
	unstaged: {
		added: number;
		deleted: number;
		files: number;
	};
	isWorktree: boolean;
	repo: string;
	worktreeSlug: string;
}

export async function getGitStatus(): Promise<GitStatus> {
	try {
		const isGitRepo = await $`git rev-parse --git-dir`.quiet().nothrow();
		if (isGitRepo.exitCode !== 0) {
			return {
				branch: "no-git",
				hasChanges: false,
				staged: { added: 0, deleted: 0, files: 0 },
				unstaged: { added: 0, deleted: 0, files: 0 },
				isWorktree: false,
				repo: "",
				worktreeSlug: "",
			};
		}

		const branchResult = await $`git branch --show-current`.quiet().text();
		const branch = branchResult.trim() || "detached";

		const commonDir = (await $`git rev-parse --git-common-dir`.quiet().nothrow().text()).trim();
		const gitDir = (await $`git rev-parse --git-dir`.quiet().nothrow().text()).trim();
		const topLevel = (await $`git rev-parse --show-toplevel`.quiet().nothrow().text()).trim();
		const wt = detectWorktree(gitDir, commonDir, topLevel);

		const diffCheck = await $`git diff-index --quiet HEAD --`.quiet().nothrow();
		const cachedCheck = await $`git diff-index --quiet --cached HEAD --`
			.quiet()
			.nothrow();

		if (diffCheck.exitCode !== 0 || cachedCheck.exitCode !== 0) {
			const unstagedDiff = await $`git diff --numstat`.quiet().text();
			const stagedDiff = await $`git diff --cached --numstat`.quiet().text();
			const stagedFilesResult = await $`git diff --cached --name-only`
				.quiet()
				.text();
			const unstagedFilesResult = await $`git diff --name-only`.quiet().text();

			const parseStats = (diff: string) => {
				let added = 0;
				let deleted = 0;
				for (const line of diff.split("\n")) {
					if (!line.trim()) continue;
					const [a, d] = line
						.split("\t")
						.map((n) => Number.parseInt(n, 10) || 0);
					added += a;
					deleted += d;
				}
				return { added, deleted };
			};

			const unstagedStats = parseStats(unstagedDiff);
			const stagedStats = parseStats(stagedDiff);

			const stagedFilesCount = stagedFilesResult
				.split("\n")
				.filter((f) => f.trim()).length;
			const unstagedFilesCount = unstagedFilesResult
				.split("\n")
				.filter((f) => f.trim()).length;

			return {
				branch,
				hasChanges: true,
				staged: {
					added: stagedStats.added,
					deleted: stagedStats.deleted,
					files: stagedFilesCount,
				},
				unstaged: {
					added: unstagedStats.added,
					deleted: unstagedStats.deleted,
					files: unstagedFilesCount,
				},
				isWorktree: wt.isWorktree,
				repo: wt.repo,
				worktreeSlug: wt.slug,
			};
		}

		return {
			branch,
			hasChanges: false,
			staged: { added: 0, deleted: 0, files: 0 },
			unstaged: { added: 0, deleted: 0, files: 0 },
			isWorktree: wt.isWorktree,
			repo: wt.repo,
			worktreeSlug: wt.slug,
		};
	} catch {
		return {
			branch: "no-git",
			hasChanges: false,
			staged: { added: 0, deleted: 0, files: 0 },
			unstaged: { added: 0, deleted: 0, files: 0 },
			isWorktree: false,
			repo: "",
			worktreeSlug: "",
		};
	}
}
