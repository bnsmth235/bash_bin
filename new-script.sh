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
else
    echo "✓ Made '$SCRIPT_NAME' executable"
fi

# Add alias to ~/.bashrc if the script has a .sh extension
if [[ "$SCRIPT_NAME" == *.sh ]]; then
    SCRIPT_BASE="${SCRIPT_NAME%.sh}"
    SCRIPT_PATH="$(cd "$(dirname "$SCRIPT_NAME")" && pwd)/$(basename "$SCRIPT_NAME")"
    ALIAS_LINE="alias $SCRIPT_BASE=\"$SCRIPT_PATH\""
    
    # Check if alias already exists in .bashrc
    if grep -q "alias $SCRIPT_BASE=" ~/.bashrc 2>/dev/null; then
        echo "⚠ Alias '$SCRIPT_BASE' already exists in ~/.bashrc"
    else
        echo "" >> ~/.bashrc
        echo "# Alias added by new-script.sh on $(date +%Y-%m-%d)" >> ~/.bashrc
        echo "$ALIAS_LINE" >> ~/.bashrc
        echo "✓ Added alias '$SCRIPT_BASE' to ~/.bashrc"
        echo ""
        echo "Run 'source ~/.bashrc' or start a new terminal to use: $SCRIPT_BASE"
    fi
else
    echo ""
    echo "You can now run: ./$SCRIPT_NAME"
fi
