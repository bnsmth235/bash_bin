#!/bin/bash
# activate.sh - Activates a Python virtual environment
# Recursively searches for 'activate' file in subdirectories or current directory

# Function to find and source the activate script
find_and_activate() {
    local search_dir="${1:-.}"
    
    # Find all files named 'activate' in bin directories (common venv structure)
    local activate_file=$(find "$search_dir" -type f -path "*/bin/activate" 2>/dev/null | head -n 1)
    
    if [ -z "$activate_file" ]; then
        # Fallback: search for any file named 'activate'
        activate_file=$(find "$search_dir" -type f -name "activate" 2>/dev/null | head -n 1)
    fi
    
    if [ -n "$activate_file" ]; then
        echo "Found activate script: $activate_file"
        echo "Activating virtual environment..."
        source "$activate_file"
        echo "Virtual environment activated!"
        return 0
    else
        echo "Error: No 'activate' file found in $search_dir or its subdirectories"
        return 1
    fi
}

# Main execution
if [ $# -eq 0 ]; then
    # No arguments: search in current directory
    find_and_activate "."
else
    # Search in provided directory
    find_and_activate "$1"
fi
