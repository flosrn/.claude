#!/usr/bin/env bun
/**
 * Stop hook - Play different sounds based on session success/failure
 *
 * Success: plays finish.mp3
 * Failure: plays Basso.aiff (macOS system sound)
 *
 * Failure is determined by checking tool-usage.log for any errors in the current session
 */

import { $ } from "bun";

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

    for (const line of lines) {
      try {
        const entry = JSON.parse(line);
        if (entry.session_id === sessionId && entry.status === "error") {
          return true;
        }
      } catch {
        // Skip invalid JSON lines
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
  } else {
    // Play success sound
    await playSound(SUCCESS_SOUND, VOLUME);
  }
}

main().catch(() => process.exit(0));
