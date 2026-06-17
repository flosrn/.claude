import { expect, test } from "bun:test";
import { detectWorktree } from "./git";

test("detects a linked worktree and extracts repo + slug", () => {
  const r = detectWorktree(
    "/Users/flo/Code/gapilabs/gapila/.git/worktrees/889-website-signals",
    "/Users/flo/Code/gapilabs/gapila/.git",
    "/Users/flo/Code/gapilabs/gapila/.worktrees/889-website-signals",
  );
  expect(r).toEqual({ isWorktree: true, repo: "gapila", slug: "889-website-signals" });
});

test("primary checkout is not a worktree", () => {
  const r = detectWorktree(
    "/Users/flo/Code/gapilabs/gapila/.git",
    "/Users/flo/Code/gapilabs/gapila/.git",
    "/Users/flo/Code/gapilabs/gapila",
  );
  expect(r.isWorktree).toBe(false);
});
