#!/bin/bash

# Team Git Workflow - Enhanced Commit and Push Process
# To be used by all development teams

TEAM_NAME="$1"
COMMIT_MESSAGE="$2"

if [ -z "$TEAM_NAME" ] || [ -z "$COMMIT_MESSAGE" ]; then
    echo "Usage: $0 <team-name> <commit-message>"
    echo "Example: $0 frontend 'Add user authentication components'"
    exit 1
fi

LOG_FILE="/Users/zippq/aiDev/claudetest/team-git-activity.log"

log_activity() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$TEAM_NAME] $1" | tee -a "$LOG_FILE"
}

log_activity "=== Starting Git Workflow ==="

# Check for uncommitted changes
if git diff-index --quiet HEAD --; then
    log_activity "⚠️  No changes to commit"
    exit 0
fi

# Add all changes
log_activity "📝 Adding all changes to staging..."
git add .

# Create comprehensive commit message
FULL_MESSAGE="$COMMIT_MESSAGE

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Commit changes
log_activity "💾 Committing changes..."
if git commit -m "$FULL_MESSAGE"; then
    COMMIT_HASH=$(git rev-parse --short HEAD)
    log_activity "✅ Commit successful: $COMMIT_HASH"
    
    # Immediately push to remote
    log_activity "🚀 Pushing to remote repository..."
    if git push origin main; then
        log_activity "✅ Successfully pushed to GitHub remote"
        
        # Send success notification
        if [ -f "./send-claude-message.sh" ]; then
            ./send-claude-message.sh frontend:devops-monitor "✅ [$TEAM_NAME] Committed and pushed: $COMMIT_MESSAGE ($COMMIT_HASH)"
        fi
    else
        log_activity "❌ Failed to push to remote - manual intervention required"
        
        # Send failure alert
        if [ -f "./send-claude-message.sh" ]; then
            ./send-claude-message.sh frontend:devops-monitor "🚨 [$TEAM_NAME] PUSH FAILED for commit $COMMIT_HASH - requires immediate attention"
        fi
        exit 1
    fi
else
    log_activity "❌ Commit failed"
    exit 1
fi

log_activity "=== Git Workflow Complete ==="