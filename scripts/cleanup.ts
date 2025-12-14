#!/usr/bin/env bun
/**
 * Cleanup script for Claude Code configuration directory
 * Removes old debug files and file-history directories to save disk space
 *
 * Usage:
 *   bun /Users/flo/.claude/scripts/cleanup.ts [--dry-run] [--keep N]
 *
 * Options:
 *   --dry-run  Show what would be deleted without actually deleting
 *   --keep N   Keep the N most recent files (default: 50)
 */

import { readdir, stat, rm } from "node:fs/promises";
import { join } from "node:path";

interface CleanupOptions {
  dryRun: boolean;
  keepCount: number;
}

interface FileInfo {
  path: string;
  mtime: Date;
}

const CLAUDE_DIR = "/Users/flo/.claude";
const DEBUG_DIR = join(CLAUDE_DIR, "debug");
const HISTORY_DIR = join(CLAUDE_DIR, "file-history");

function parseArgs(): CleanupOptions {
  const args = process.argv.slice(2);
  let dryRun = false;
  let keepCount = 50;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--dry-run") {
      dryRun = true;
    } else if (args[i] === "--keep" && args[i + 1]) {
      keepCount = parseInt(args[i + 1], 10);
      i++;
    }
  }

  return { dryRun, keepCount };
}

async function getFilesWithMtime(dir: string): Promise<FileInfo[]> {
  try {
    const entries = await readdir(dir);
    const files: FileInfo[] = [];

    for (const entry of entries) {
      if (entry === "latest") continue; // Skip symlinks
      const fullPath = join(dir, entry);
      try {
        const stats = await stat(fullPath);
        files.push({ path: fullPath, mtime: stats.mtime });
      } catch {
        // Skip files we can't stat
      }
    }

    return files.sort((a, b) => b.mtime.getTime() - a.mtime.getTime());
  } catch {
    return [];
  }
}

async function cleanupDirectory(
  dir: string,
  options: CleanupOptions,
  isDirectory: boolean = false,
): Promise<{ deleted: number; freed: number }> {
  const files = await getFilesWithMtime(dir);
  const toDelete = files.slice(options.keepCount);

  let deleted = 0;
  let freed = 0;

  for (const file of toDelete) {
    try {
      const stats = await stat(file.path);
      const size = stats.isDirectory() ? 0 : stats.size; // Approximate for dirs

      if (options.dryRun) {
        console.log(`Would delete: ${file.path}`);
      } else {
        await rm(file.path, { recursive: isDirectory });
      }
      deleted++;
      freed += size;
    } catch (error) {
      console.error(`Failed to delete ${file.path}:`, error);
    }
  }

  return { deleted, freed };
}

function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

async function main() {
  const options = parseArgs();

  console.log("Claude Code Cleanup Script");
  console.log("==========================");
  console.log(`Mode: ${options.dryRun ? "DRY RUN" : "LIVE"}`);
  console.log(`Keeping: ${options.keepCount} most recent files\n`);

  // Cleanup debug directory
  console.log("Cleaning debug/ ...");
  const debugResult = await cleanupDirectory(DEBUG_DIR, options, false);
  console.log(
    `  ${options.dryRun ? "Would delete" : "Deleted"}: ${debugResult.deleted} files (${formatBytes(debugResult.freed)})`,
  );

  // Cleanup file-history directory
  console.log("\nCleaning file-history/ ...");
  const historyResult = await cleanupDirectory(HISTORY_DIR, options, true);
  console.log(
    `  ${options.dryRun ? "Would delete" : "Deleted"}: ${historyResult.deleted} directories`,
  );

  // Summary
  const totalDeleted = debugResult.deleted + historyResult.deleted;
  console.log("\n==========================");
  console.log(
    `Total ${options.dryRun ? "would delete" : "deleted"}: ${totalDeleted} items`,
  );
  console.log(
    `Space ${options.dryRun ? "would free" : "freed"}: ${formatBytes(debugResult.freed)}`,
  );

  if (options.dryRun) {
    console.log("\nRun without --dry-run to actually delete files.");
  }
}

main().catch(console.error);
