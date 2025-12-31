#!/bin/bash
# Test script to verify AppleScript terminal automation works
# Run this manually first to test if keystrokes can be sent

# Detect which terminal app is frontmost
get_terminal_app() {
  osascript -e 'tell application "System Events" to get name of first process whose frontmost is true'
}

TERMINAL_APP=$(get_terminal_app)
echo "Detected terminal: $TERMINAL_APP"

# Test: Send a simple echo command after 3 seconds
echo "In 3 seconds, this script will type 'echo YOLO_TEST_SUCCESS' in your terminal..."
echo "Keep this terminal focused!"

sleep 3

osascript <<EOF
tell application "System Events"
  keystroke "echo YOLO_TEST_SUCCESS"
  keystroke return
end tell
EOF

echo "Did you see 'YOLO_TEST_SUCCESS' printed above? If yes, automation works!"
