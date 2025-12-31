#!/usr/bin/env bun

/**
 * APEX Clipboard Hook
 *
 * Automatically copies the next APEX command to clipboard when writing APEX files.
 * Uses early-exit strategy for performance (~15ms for non-APEX files).
 *
 * Triggers:
 *   - analyze.md → /apex:2-plan <folder>
 *   - plan.md → /apex:5-tasks <folder> (complex) or /apex:3-execute <folder> (simple)
 *   - tasks/index.md → /apex:3-execute <folder>
 *
 * YOLO Mode:
 *   If .yolo flag exists in task folder, creates /tmp/.apex-yolo-continue
 *   to trigger automatic continuation after Claude exits.
 */

const YOLO_CONTINUE_FLAG = "/tmp/.apex-yolo-continue";

// STEP 1: Read stdin
const input = await Bun.stdin.text();

// STEP 2: Fast path - extract file_path via regex on raw JSON (no parsing)
const filePathMatch = input.match(/"file_path"\s*:\s*"([^"]+)"/);
if (!filePathMatch?.[1]) {
  process.exit(0);
}
const filePath = filePathMatch[1];

// STEP 3: Fast path - detect APEX file pattern
// Matches: .claude/tasks/<folder>/analyze.md, plan.md, or tasks/index.md
const apexMatch = filePath.match(
  /\.claude\/tasks\/([^/]+)\/(analyze|plan|tasks\/index)\.md$/
);
if (!apexMatch?.[1] || !apexMatch[2]) {
  // DEBUG: Log why we're exiting
  console.log(JSON.stringify({ systemMessage: `⏭️ Not APEX file: ${filePath.slice(-50)}` }));
  process.exit(0); // EXIT RAPIDE - not an APEX file
}

const folder: string = apexMatch[1];
const phase: string = apexMatch[2];

// STEP 4: Slow path - Parse full JSON for APEX files only
interface HookInput {
  tool_input: {
    file_path: string;
    content?: string;
  };
  tool_response: {
    // Write tool fields
    success?: boolean;
    type?: "create" | "update";
    filePath?: string;
    // Edit tool fields
    oldString?: string;
    newString?: string;
  };
}

let hookData: HookInput;
try {
  hookData = JSON.parse(input);
} catch {
  process.exit(0);
}

// Skip if write/edit was not successful
// Write tool: { type: "create" | "update", filePath }
// Edit tool: { filePath, oldString, newString } (no type field)
const response = hookData.tool_response;
const isWriteSuccess = response && (response.type === "create" || response.type === "update");
const isEditSuccess = response && response.filePath && response.oldString !== undefined;
const isSuccess = isWriteSuccess || isEditSuccess || response?.success === true;
if (!isSuccess) {
  console.log(JSON.stringify({ systemMessage: `⏭️ Write/Edit not successful: ${JSON.stringify(response).slice(0, 100)}` }));
  process.exit(0);
}

// STEP 5: Determine next command based on phase
function getNextCommand(
  phase: string,
  folder: string,
  content: string | undefined
): { command: string; reason?: string } {
  switch (phase) {
    case "analyze":
      return { command: `/apex:2-plan ${folder}` };

    case "plan": {
      // Intelligent detection: count file sections (### `) in plan
      // If >= 6 files, suggest task decomposition
      const fileCount = content
        ? (content.match(/### `[^`]+`/g) || []).length
        : 0;

      if (fileCount >= 6) {
        return {
          command: `/apex:5-tasks ${folder}`,
          reason: ` (${fileCount} files detected)`,
        };
      }
      return { command: `/apex:3-execute ${folder}` };
    }

    case "tasks/index":
      return { command: `/apex:3-execute ${folder}` };

    default:
      return { command: "" };
  }
}

const content = hookData.tool_input?.content;
const { command, reason } = getNextCommand(phase, folder, content);

if (!command) {
  process.exit(0);
}

// STEP 6: Copy to clipboard using pbcopy
async function copyToClipboard(text: string): Promise<boolean> {
  try {
    const proc = Bun.spawn(["pbcopy"], {
      stdin: new TextEncoder().encode(text),
    });
    const exitCode = await proc.exited;
    return exitCode === 0;
  } catch {
    return false;
  }
}

const copied = await copyToClipboard(command);
if (!copied) {
  // pbcopy failed (e.g., SSH session) - exit silently
  process.exit(0);
}

// STEP 7: Check for YOLO mode
// Build the task folder path from filePath
const taskFolderMatch = filePath.match(/(.+\.claude\/tasks\/[^/]+)\//);
const taskFolder = taskFolderMatch?.[1];
let yoloMode = false;
let yoloCommand = command;

if (taskFolder) {
  const yoloFlagPath = `${taskFolder}/.yolo`;
  const yoloFlag = Bun.file(yoloFlagPath);

  if (await yoloFlag.exists()) {
    yoloMode = true;

    // Determine if we should propagate --yolo
    // Stop YOLO at execute phase (user needs to review each task)
    const isExecutePhase = command.includes("/apex:3-execute");

    if (!isExecutePhase) {
      yoloCommand = `${command} --yolo`;
      // Update clipboard with --yolo flag
      await copyToClipboard(yoloCommand);
    } else {
      // Execute phase: delete the .yolo flag to stop the chain
      await Bun.write(yoloFlagPath, "").catch(() => {});
      try {
        const { $ } = await import("bun");
        await $`rm -f ${yoloFlagPath}`.quiet();
      } catch {}
    }

    // Create YOLO continue flag for Stop hook (only if not execute phase)
    if (!isExecutePhase) {
      const nextPhase =
        phase === "analyze" ? "plan" : phase === "plan" ? "tasks" : "execute";

      // Extract project path from file path (everything before /.claude/)
      const projectPathMatch = filePath.match(/^(.+)\/\.claude\/tasks\//);
      const projectPath = projectPathMatch?.[1] || process.cwd();

      const yoloData = {
        nextCommand: yoloCommand,
        folder,
        phase: nextPhase,
        projectPath,
      };

      await Bun.write(YOLO_CONTINUE_FLAG, JSON.stringify(yoloData));
    }
  }
}

// STEP 8: Output structured message
const yoloSuffix = yoloMode ? " 🔄" : "";
const output = {
  systemMessage: `📋 Copied: ${yoloMode ? yoloCommand : command}${reason || ""}${yoloSuffix}`,
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: yoloMode
      ? "APEX YOLO mode: will auto-continue after exit"
      : "APEX next command copied to clipboard",
  },
};

console.log(JSON.stringify(output));
