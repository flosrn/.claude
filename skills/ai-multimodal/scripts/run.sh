#!/bin/bash
# Wrapper script that activates venv before running Python scripts
# Usage: ./run.sh gemini_batch_process.py [args...]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
VENV_DIR="$SKILL_DIR/.venv"

# Create venv if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    pip install google-genai python-dotenv pillow >/dev/null 2>&1
else
    source "$VENV_DIR/bin/activate"
fi

# Run the requested script with all arguments
SCRIPT_NAME="${1:-gemini_batch_process.py}"
shift
python "$SCRIPT_DIR/$SCRIPT_NAME" "$@"
