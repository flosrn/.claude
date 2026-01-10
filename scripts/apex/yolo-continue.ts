#!/usr/bin/env bun
/**
 * APEX YOLO Continue Script
 *
 * Called by Stop hook when YOLO mode is active.
 * Opens a NEW terminal window/pane to run the next APEX phase.
 * This allows multi-session work - you don't need to keep the terminal focused!
 *
 * Strategies (in order of preference):
 * 1. tmux: If inside tmux, create new window (works in fullscreen!)
 * 2. Ghostty: AppleScript new window
 * 3. iTerm2: AppleScript
 * 4. Terminal.app: AppleScript (fallback)
 */

import { $ } from "bun";

const YOLO_FLAG = "/tmp/.apex-yolo-continue";
const DELAY_BEFORE_NEW_TERMINAL_MS = 500; // Small delay to let Claude fully exit

interface YoloData {
  nextCommand: string;
  folder: string;
  phase: string;
  projectPath: string;
}

function isInsideTmux(): boolean {
  return !!process.env.TMUX;
}

async function detectTerminal(): Promise<"tmux" | "ghostty" | "iterm" | "terminal"> {
  // First priority: tmux (works in fullscreen!)
  if (isInsideTmux()) return "tmux";

  // Check if Ghostty is installed
  try {
    const result = await $`which ghostty`.quiet();
    if (result.exitCode === 0) return "ghostty";
  } catch {}

  // Check if iTerm is running or installed
  try {
    const result =
      await $`osascript -e 'application "iTerm" is running'`.quiet();
    if (result.stdout.toString().includes("true")) return "iterm";
  } catch {}

  // Fallback to Terminal.app
  return "terminal";
}

async function openNewTab(
  command: string,
  terminal: "tmux" | "ghostty" | "iterm" | "terminal",
  workingDir: string
): Promise<void> {
  // Escape single quotes in command for shell
  const escapedCommand = command.replace(/'/g, "'\\''");
  const fullCommand = `cd '${workingDir}' && ${escapedCommand}`;

  switch (terminal) {
    case "tmux":
      // tmux: Create new window in current session (works in fullscreen!)
      // This is the best option - no AppleScript needed, works everywhere
      await $`tmux new-window -n "YOLO" ${fullCommand}`.quiet();
      break;

    case "ghostty": {
      // Ghostty: Use split pane (Cmd+Shift+D) - works in fullscreen!
      // IMPORTANT: Direct keystroke + return does NOT work in Ghostty!
      // Workaround from alfred-ghostty-script: use clipboard + Cmd+V + return
      // This is the only proven method that works with Ghostty.

      // Step 1: Copy command to clipboard
      const proc = Bun.spawn(["pbcopy"], {
        stdin: new TextEncoder().encode(fullCommand),
      });
      await proc.exited;

      // Step 2: AppleScript to create split, navigate to it, paste, press return
      // NOTE: After Cmd+Shift+D, Ghostty creates split below but focus may stay on original
      // Use Cmd+Alt+Down to explicitly move focus to the new pane
      const scriptContent = `tell application "Ghostty"
    activate
end tell
delay 0.3
tell application "System Events" to tell process "Ghostty"
    -- Create vertical split (new pane below)
    keystroke "d" using {command down, shift down}
end tell
delay 0.8
tell application "System Events" to tell process "Ghostty"
    -- Navigate to the new pane (down) to ensure focus is correct
    key code 125 using {command down, option down}
end tell
delay 0.3
tell application "System Events" to tell process "Ghostty"
    -- Paste and execute
    keystroke "v" using {command down}
    delay 0.1
    keystroke return
end tell`;
      const scriptPath = "/tmp/.apex-yolo-applescript.scpt";
      await Bun.write(scriptPath, scriptContent);
      await $`osascript ${scriptPath}`.quiet();
      await $`rm -f ${scriptPath}`.quiet();
      break;
    }

    case "iterm":
      // iTerm2: Use AppleScript to open new tab
      const itermScript = `
tell application "iTerm"
    activate
    tell current window
        create tab with default profile
        tell current session
            write text "${fullCommand.replace(/"/g, '\\"')}"
        end tell
    end tell
end tell
`;
      await $`osascript -e ${itermScript}`.quiet();
      break;

    case "terminal":
      // Terminal.app: Use AppleScript for new tab
      const terminalScript = `
tell application "Terminal"
    activate
    tell application "System Events"
        keystroke "t" using command down
    end tell
    delay 0.3
    do script "${fullCommand.replace(/"/g, '\\"')}" in front window
end tell
`;
      await $`osascript -e ${terminalScript}`.quiet();
      break;
  }
}

async function main() {
  // Check if YOLO flag exists
  const flagFile = Bun.file(YOLO_FLAG);
  if (!(await flagFile.exists())) {
    // No YOLO mode active, exit silently
    process.exit(0);
  }

  // Read the flag data
  let yoloData: YoloData;
  try {
    yoloData = await flagFile.json();
  } catch {
    console.error("Failed to parse YOLO flag data");
    await $`rm -f ${YOLO_FLAG}`.quiet();
    process.exit(1);
  }

  // Delete the flag immediately to prevent re-triggering
  await $`rm -f ${YOLO_FLAG}`.quiet();

  const { nextCommand, folder, phase, projectPath } = yoloData;

  // Log what we're about to do
  console.log(`\n🔄 YOLO Mode: Opening new terminal for next phase...`);
  console.log(`   Next: ${nextCommand}`);

  // Detect terminal and spawn background process
  const terminal = await detectTerminal();
  console.log(`   Terminal: ${terminal}`);

  // Small delay to ensure Claude has fully exited
  await new Promise((resolve) =>
    setTimeout(resolve, DELAY_BEFORE_NEW_TERMINAL_MS)
  );

  // Open new terminal with the command
  // The command runs `cc` (claude alias) with the APEX command
  const claudeCommand = `cc "${nextCommand}"`;
  await openNewTab(claudeCommand, terminal, projectPath);

  // Return output for the hook
  const output = {
    systemMessage: `🔄 YOLO: Opening new ${terminal} window for ${phase} phase...`,
    hookSpecificOutput: {
      hookEventName: "Stop",
      additionalContext: `APEX YOLO mode: will run ${nextCommand} in new terminal`,
    },
  };

  console.log(JSON.stringify(output));
}

main().catch(console.error);
