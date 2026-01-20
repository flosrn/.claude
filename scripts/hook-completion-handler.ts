#!/usr/bin/env bun
/**
 * Stop hook - Play different sounds based on session success/failure
 *
 * Success: plays finish.mp3
 * Failure: plays Basso.aiff (macOS system sound)
 *
 * Failure is determined by checking tool-usage.log for any errors in the current session
 *
 * YOLO Mode: If /tmp/.apex-yolo-continue exists, launches background
 * automation to continue APEX workflow after Claude exits.
 */

import { $ } from "bun";

const YOLO_CONTINUE_FLAG = "/tmp/.apex-yolo-continue";
const YOLO_CONTINUE_SCRIPT = "/Users/flo/.claude/scripts/apex/yolo-continue.ts";

interface StopHookInput {
  session_id: string;
  transcript_path: string;
  cwd: string;
}

const LOG_FILE = "/Users/flo/.claude/tool-usage.log";
const SUCCESS_SOUND = "/Users/flo/.claude/song/finish.mp3";
const FAILURE_SOUND = "/System/Library/Sounds/Basso.aiff";
const VOLUME = "0.15";

async function checkSessionHadErrors(sessionId: string): Promise<boolean> {
  try {
    const file = Bun.file(LOG_FILE);
    if (!(await file.exists())) {
      return false;
    }

    const content = await file.text();
    const lines = content.trim().split("\n");

    // Track the LAST status for each file in this session
    // If Claude fixed an error, the last status will be "success"
    const fileLastStatus = new Map<string, "success" | "error">();

    for (const line of lines) {
      try {
        const entry = JSON.parse(line);
        if (entry.session_id === sessionId && entry.file_path) {
          fileLastStatus.set(entry.file_path, entry.status);
        }
      } catch {
        // Skip invalid JSON lines
      }
    }

    // Check if ANY file still has an error as its last status
    for (const status of fileLastStatus.values()) {
      if (status === "error") {
        return true;
      }
    }

    return false;
  } catch {
    return false;
  }
}

async function playSound(soundPath: string, volume: string): Promise<void> {
  try {
    await $`afplay -v ${volume} ${soundPath}`.quiet();
  } catch {
    // Silently fail if sound can't be played
  }
}

async function main() {
  // Read input JSON from stdin
  const input = await Bun.stdin.text();

  let hookData: StopHookInput;
  try {
    hookData = JSON.parse(input);
  } catch {
    // If we can't parse input, just play success sound and exit
    await playSound(SUCCESS_SOUND, VOLUME);
    process.exit(0);
  }

  const { session_id } = hookData;

  // Check if session had errors
  const hadErrors = await checkSessionHadErrors(session_id);

  if (hadErrors) {
    // Play failure sound (louder)
    await playSound(FAILURE_SOUND, "0.3");
    // Don't continue YOLO if there were errors
    await $`rm -f ${YOLO_CONTINUE_FLAG}`.quiet();
  } else {
    // Play success sound
    await playSound(SUCCESS_SOUND, VOLUME);

    // Check for YOLO mode continuation
    const yoloContinueFlag = Bun.file(YOLO_CONTINUE_FLAG);
    if (await yoloContinueFlag.exists()) {
      // Launch YOLO continue script in background
      // This script will wait for Claude to exit, then send keystrokes
      Bun.spawn(["bun", YOLO_CONTINUE_SCRIPT], {
        stdout: "inherit",
        stderr: "inherit",
        stdin: "ignore",
      });
    }
  }
}

main().catch(() => process.exit(0));
