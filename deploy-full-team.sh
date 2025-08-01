#!/bin/bash

# Full Team Deployment Script - Improved for Future Projects
# This script properly deploys Claude agents in tmux sessions

PROJECT_NAME=${1:-"project"}
SPEC_DIR=${2:-"./specs"}

echo "🚀 Deploying Full AI Development Team for: $PROJECT_NAME"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load NVM environment
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Use Node v22.15.1 where Claude is installed
if command -v nvm &> /dev/null; then
    nvm use v22.15.1
fi

# Kill existing sessions
echo "Cleaning up existing sessions..."
tmux kill-session -t orchestrator 2>/dev/null
tmux kill-session -t frontend 2>/dev/null
tmux kill-session -t backend 2>/dev/null

# Create Orchestrator
echo "Creating Orchestrator session..."
tmux new-session -d -s orchestrator -c "$SCRIPT_DIR"
tmux send-keys -t orchestrator:0 "export NVM_DIR=\"$HOME/.nvm\"" Enter
tmux send-keys -t orchestrator:0 "[ -s \"$NVM_DIR/nvm.sh\" ] && source \"$NVM_DIR/nvm.sh\"" Enter
tmux send-keys -t orchestrator:0 "nvm use v22.15.1" Enter
sleep 2
tmux send-keys -t orchestrator:0 "claude --dangerously-skip-permissions" Enter
sleep 3
tmux send-keys -t orchestrator:0 "2" Enter  # Accept dangerous permissions

# Create Frontend Team
echo "Creating Frontend team..."
tmux new-session -d -s frontend -c "$SCRIPT_DIR"

# Frontend PM Window
tmux rename-window -t frontend:0 "frontend-pm"
tmux send-keys -t frontend:0 "export NVM_DIR=\"$HOME/.nvm\"" Enter
tmux send-keys -t frontend:0 "[ -s \"$NVM_DIR/nvm.sh\" ] && source \"$NVM_DIR/nvm.sh\"" Enter
tmux send-keys -t frontend:0 "nvm use v22.15.1" Enter
sleep 2
tmux send-keys -t frontend:0 "claude --dangerously-skip-permissions" Enter
sleep 3
tmux send-keys -t frontend:0 "2" Enter

# Frontend Developer Window
tmux new-window -t frontend -n "frontend-dev"
tmux send-keys -t frontend:1 "export NVM_DIR=\"$HOME/.nvm\"" Enter
tmux send-keys -t frontend:1 "[ -s \"$NVM_DIR/nvm.sh\" ] && source \"$NVM_DIR/nvm.sh\"" Enter
tmux send-keys -t frontend:1 "nvm use v22.15.1" Enter
sleep 2
tmux send-keys -t frontend:1 "claude --dangerously-skip-permissions" Enter
sleep 3
tmux send-keys -t frontend:1 "2" Enter

# Frontend UI Tester Window
tmux new-window -t frontend -n "frontend-ui-test"
tmux send-keys -t frontend:2 "export NVM_DIR=\"$HOME/.nvm\"" Enter
tmux send-keys -t frontend:2 "[ -s \"$NVM_DIR/nvm.sh\" ] && source \"$NVM_DIR/nvm.sh\"" Enter
tmux send-keys -t frontend:2 "nvm use v22.15.1" Enter
sleep 2
tmux send-keys -t frontend:2 "claude --dangerously-skip-permissions" Enter
sleep 3
tmux send-keys -t frontend:2 "2" Enter

# Create Backend Team
echo "Creating Backend team..."
tmux new-session -d -s backend -c "$SCRIPT_DIR"

# Backend PM Window
tmux rename-window -t backend:0 "backend-pm"
tmux send-keys -t backend:0 "export NVM_DIR=\"$HOME/.nvm\"" Enter
tmux send-keys -t backend:0 "[ -s \"$NVM_DIR/nvm.sh\" ] && source \"$NVM_DIR/nvm.sh\"" Enter
tmux send-keys -t backend:0 "nvm use v22.15.1" Enter
sleep 2
tmux send-keys -t backend:0 "claude --dangerously-skip-permissions" Enter
sleep 3
tmux send-keys -t backend:0 "2" Enter

# Backend Developer Window
tmux new-window -t backend -n "backend-dev"
tmux send-keys -t backend:1 "export NVM_DIR=\"$HOME/.nvm\"" Enter
tmux send-keys -t backend:1 "[ -s \"$NVM_DIR/nvm.sh\" ] && source \"$NVM_DIR/nvm.sh\"" Enter
tmux send-keys -t backend:1 "nvm use v22.15.1" Enter
sleep 2
tmux send-keys -t backend:1 "claude --dangerously-skip-permissions" Enter
sleep 3
tmux send-keys -t backend:1 "2" Enter

# Backend API Tester Window
tmux new-window -t backend -n "backend-api-test"
tmux send-keys -t backend:2 "export NVM_DIR=\"$HOME/.nvm\"" Enter
tmux send-keys -t backend:2 "[ -s \"$NVM_DIR/nvm.sh\" ] && source \"$NVM_DIR/nvm.sh\"" Enter
tmux send-keys -t backend:2 "nvm use v22.15.1" Enter
sleep 2
tmux send-keys -t backend:2 "claude --dangerously-skip-permissions" Enter
sleep 3
tmux send-keys -t backend:2 "2" Enter

echo "⏳ Waiting for all Claude agents to start..."
sleep 10

echo "📋 Briefing all agents..."

# Brief Orchestrator
./send-claude-message.sh orchestrator:0 "You are the TMUX Orchestrator. Read prompt.md and all specifications in $SPEC_DIR directory. Deploy and coordinate all teams for $PROJECT_NAME development. All team agents are now properly running with Claude in their sessions."

# Brief Frontend Team
./send-claude-message.sh frontend:0 "You are the Frontend Project Manager for $PROJECT_NAME. Read the frontend specifications and coordinate with your team to implement the frontend requirements. Ensure git discipline and quality standards."

./send-claude-message.sh frontend:1 "You are the Frontend Developer for $PROJECT_NAME. Read the frontend specifications and implement the React/TypeScript frontend. Follow git discipline: commit every 30 minutes with meaningful messages."

./send-claude-message.sh frontend:2 "You are the Frontend UI Tester for $PROJECT_NAME. Test the user interface, ensure responsive design, accessibility, and user experience quality. Work with the dev team to fix issues."

# Brief Backend Team
./send-claude-message.sh backend:0 "You are the Backend Project Manager for $PROJECT_NAME. Read the backend specifications and coordinate with your team to implement the API and database requirements. Ensure git discipline and quality standards."

./send-claude-message.sh backend:1 "You are the Backend Developer for $PROJECT_NAME. Read the backend specifications and implement the Node.js/Express API with MongoDB. Follow git discipline: commit every 30 minutes with meaningful messages."

./send-claude-message.sh backend:2 "You are the Backend API Tester for $PROJECT_NAME. Test all API endpoints, ensure proper error handling, validation, and performance. Work with the dev team to fix issues."

echo ""
echo "✅ Full AI Development Team Successfully Deployed!"
echo ""
echo "📊 Team Status:"
echo "  Orchestrator:  tmux attach-session -t orchestrator"
echo "  Frontend Team: tmux attach-session -t frontend"
echo "  Backend Team:  tmux attach-session -t backend"
echo ""
echo "🚀 All agents are briefed and ready for autonomous development!"