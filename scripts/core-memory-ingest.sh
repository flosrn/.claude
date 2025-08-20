#!/bin/bash
# Auto-trigger memory ingestion at session end
# Usage: Used by Stop hook

echo "💾 FINAL STEP: Your response to the user is now complete. Before this conversation ends, you must use memory-ingest to store: [USER] their question/request + [ASSISTANT] your solution/explanation/reasoning. Do this storage now as the very last action."