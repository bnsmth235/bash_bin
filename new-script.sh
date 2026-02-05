#!/bin/bash
# new-script.sh - Make a new script executable and ready to use
# Usage: ./new-script.sh <script-name>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <script-name>"
    echo "Example: $0 my-script.sh"
    exit 1
fi

SCRIPT_NAME="$1"

# Check if the script file exists
if [ ! -f "$SCRIPT_NAME" ]; then
    echo "Error: File '$SCRIPT_NAME' not found"
    exit 1
fi

# Make the script executable
chmod +x "$SCRIPT_NAME"

# Add to git if we're in a git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    git add "$SCRIPT_NAME"
    echo "✓ Made '$SCRIPT_NAME' executable"
    echo "✓ Added '$SCRIPT_NAME' to git"
    echo ""
    echo "You can now run: ./$SCRIPT_NAME"
else
    echo "✓ Made '$SCRIPT_NAME' executable"
    echo ""
    echo "You can now run: ./$SCRIPT_NAME"
fi
