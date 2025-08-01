#!/bin/bash

# Setup Claude path for tmux sessions
# This script fixes PATH issues when running claude in tmux

# Find claude executable
CLAUDE_PATH=$(which claude 2>/dev/null)

if [ -z "$CLAUDE_PATH" ]; then
    # Check common installation locations
    POSSIBLE_PATHS=(
        "$HOME/.nvm/versions/node/*/bin/claude"
        "/usr/local/bin/claude"
        "/opt/homebrew/bin/claude"
        "$HOME/.local/bin/claude"
    )
    
    for path_pattern in "${POSSIBLE_PATHS[@]}"; do
        # Use glob expansion to find actual paths
        for actual_path in $path_pattern; do
            if [ -x "$actual_path" ]; then
                CLAUDE_PATH="$actual_path"
                break 2
            fi
        done
    done
fi

if [ -n "$CLAUDE_PATH" ]; then
    echo "Found Claude at: $CLAUDE_PATH"
    CLAUDE_DIR=$(dirname "$CLAUDE_PATH")
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$CLAUDE_DIR:"* ]]; then
        export PATH="$PATH:$CLAUDE_DIR"
        echo "Added $CLAUDE_DIR to PATH"
    fi
    
    # Start claude
    claude "$@"
else
    echo "Error: Claude CLI not found!"
    echo "Please install Claude CLI first:"
    echo "  npm install -g @anthropic-ai/claude-code"
    exit 1
fi