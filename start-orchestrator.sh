#!/bin/bash

# Start TMUX Orchestrator with proper NVM environment
# This script ensures Claude CLI works correctly in tmux sessions

# Load NVM if it exists
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    echo "Loading NVM..."
    source "$NVM_DIR/nvm.sh"
fi

# Load NVM bash completion if it exists
if [ -s "$NVM_DIR/bash_completion" ]; then
    source "$NVM_DIR/bash_completion"
fi

# Use Node v22.15.1 where Claude is installed
if command -v nvm &> /dev/null; then
    echo "Current Node version: $(nvm current)"
    echo "Switching to Node v22.15.1 where Claude is installed..."
    nvm use v22.15.1
fi

# Verify claude is available
if ! command -v claude &> /dev/null; then
    echo "Error: Claude CLI not found after loading NVM environment"
    echo "Current PATH: $PATH"
    echo "Node version: $(node --version 2>/dev/null || echo 'Not found')"
    exit 1
fi

echo "Claude CLI found at: $(which claude)"
echo "Node version: $(node --version)"

# Kill existing orchestrator session if it exists
tmux kill-session -t orchestrator 2>/dev/null

# Create new orchestrator session with proper environment
echo "Creating orchestrator tmux session..."
tmux new-session -d -s orchestrator -c "/Users/zippq/aiDev/claudetest"

# Send environment setup commands to the session
tmux send-keys -t orchestrator:0 "export NVM_DIR=\"$HOME/.nvm\"" Enter
tmux send-keys -t orchestrator:0 "[ -s \"$NVM_DIR/nvm.sh\" ] && source \"$NVM_DIR/nvm.sh\"" Enter
tmux send-keys -t orchestrator:0 "[ -s \"$NVM_DIR/bash_completion\" ] && source \"$NVM_DIR/bash_completion\"" Enter

# Set the node version in tmux session to v22.15.1
if command -v nvm &> /dev/null; then
    tmux send-keys -t orchestrator:0 "nvm use v22.15.1" Enter
    sleep 2
fi

# Start Claude with dangerous permissions skip
echo "Starting Claude in orchestrator session with permissions skip..."
tmux send-keys -t orchestrator:0 "claude --dangerously-skip-permissions" Enter

sleep 3

# Check if Claude started successfully
echo "Checking if Claude started successfully..."
tmux capture-pane -t orchestrator:0 -p | tail -5

echo ""
echo "✅ Orchestrator session created!"
echo "To attach: tmux attach-session -t orchestrator"
echo "To send messages: ./send-claude-message.sh orchestrator:0 \"Your message\""