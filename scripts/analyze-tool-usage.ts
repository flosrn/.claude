#!/usr/bin/env bun
// @ts-nocheck

interface LogEntry {
  timestamp: string;
  session_id: string;
  tool_use_id: string;
  tool_name: string;
  file_path: string;
  status: "success" | "error";
  errors?: string[];
}

const LOG_FILE = "/Users/flo/.claude/tool-usage.log";

async function analyzeToolUsage() {
  console.log("\n📊 Tool Usage Analytics\n");

  const logFile = Bun.file(LOG_FILE);

  if (!(await logFile.exists())) {
    console.log(
      "No log file found. Tool usage tracking will start after first edit.",
    );
    return;
  }

  const content = await logFile.text();
  const lines = content.split("\n").filter(Boolean);

  if (lines.length === 0) {
    console.log("Log file is empty. No tool usage recorded yet.");
    return;
  }

  const entries: LogEntry[] = lines.map((line) => JSON.parse(line));

  // Overall statistics
  const successCount = entries.filter((e) => e.status === "success").length;
  const errorCount = entries.filter((e) => e.status === "error").length;
  const successRate = ((successCount / entries.length) * 100).toFixed(1);

  console.log(`Total operations: ${entries.length}`);
  console.log(`Success: ${successCount} (${successRate}%)`);
  console.log(
    `Errors: ${errorCount} (${(100 - parseFloat(successRate)).toFixed(1)}%)`,
  );

  // Most edited files
  console.log("\n📝 Most edited files:");
  const fileCount = new Map<string, number>();
  for (const entry of entries) {
    fileCount.set(entry.file_path, (fileCount.get(entry.file_path) || 0) + 1);
  }

  const sortedFiles = Array.from(fileCount.entries())
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10);

  for (const [file, count] of sortedFiles) {
    const shortPath = file.split("/").slice(-3).join("/");
    console.log(`  ${count.toString().padStart(3)}x ${shortPath}`);
  }

  // Tool usage breakdown
  console.log("\n🔧 Tool usage breakdown:");
  const toolCount = new Map<string, number>();
  for (const entry of entries) {
    toolCount.set(entry.tool_name, (toolCount.get(entry.tool_name) || 0) + 1);
  }

  for (const [tool, count] of Array.from(toolCount.entries()).sort(
    (a, b) => b[1] - a[1],
  )) {
    console.log(`  ${count.toString().padStart(3)}x ${tool}`);
  }

  // Common errors
  const errorEntries = entries.filter((e) => e.errors && e.errors.length > 0);
  if (errorEntries.length > 0) {
    console.log("\n❌ Common errors:");
    const errorTypes = new Map<string, number>();

    for (const entry of errorEntries) {
      if (entry.errors) {
        for (const error of entry.errors) {
          // Extract error type (TypeScript, ESLint, etc.)
          const type = error.split(":")[0].trim();
          errorTypes.set(type, (errorTypes.get(type) || 0) + 1);
        }
      }
    }

    for (const [type, count] of Array.from(errorTypes.entries()).sort(
      (a, b) => b[1] - a[1],
    )) {
      console.log(`  ${count.toString().padStart(3)}x ${type}`);
    }
  }

  // Recent activity (last 10 entries)
  console.log("\n⏱️  Recent activity (last 10):");
  const recentEntries = entries.slice(-10).reverse();
  for (const entry of recentEntries) {
    const time = new Date(entry.timestamp).toLocaleTimeString();
    const statusIcon = entry.status === "success" ? "✓" : "✗";
    const fileName = entry.file_path.split("/").pop();
    const toolUseIdShort = entry.tool_use_id.slice(-8);
    console.log(
      `  ${time} ${statusIcon} ${entry.tool_name.padEnd(10)} ${fileName} [${toolUseIdShort}]`,
    );
  }

  // Session breakdown
  console.log("\n🔄 Session breakdown:");
  const sessionCount = new Map<string, number>();
  for (const entry of entries) {
    sessionCount.set(
      entry.session_id,
      (sessionCount.get(entry.session_id) || 0) + 1,
    );
  }
  console.log(`  Total sessions: ${sessionCount.size}`);
  console.log(
    `  Average operations per session: ${(entries.length / sessionCount.size).toFixed(1)}`,
  );

  console.log(
    "\n💡 Tip: Run with CLAUDE_HOOK_DEBUG=1 to see detailed hook execution logs\n",
  );
}

// Run the analysis
analyzeToolUsage().catch((error) => {
  console.error("Error analyzing tool usage:", error);
  process.exit(1);
});
