#!/bin/bash

# Git Compliance Monitor - Enhanced Push Discipline
# Monitors local vs remote commits and enforces push discipline

LOG_FILE="/Users/zippq/aiDev/claudetest/git-compliance.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_unpushed_commits() {
    log_message "=== Git Compliance Check Started ==="
    
    # Fetch latest from remote
    git fetch origin 2>/dev/null
    
    # Check for unpushed commits
    UNPUSHED=$(git log --oneline origin/main..HEAD 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$UNPUSHED" -gt 0 ]; then
        log_message "🚨 WARNING: $UNPUSHED unpushed commits detected!"
        
        # List unpushed commits
        git log --oneline origin/main..HEAD 2>/dev/null | while read commit; do
            log_message "  📝 Unpushed: $commit"
        done
        
        # Auto-push if commits exist
        log_message "🚀 Attempting automatic push to remote..."
        if git push origin main 2>/dev/null; then
            log_message "✅ Successfully pushed $UNPUSHED commits to remote"
            
            # Send success alert to teams
            if [ -f "./send-claude-message.sh" ]; then
                ./send-claude-message.sh frontend:devops-monitor "✅ Git Compliance: Auto-pushed $UNPUSHED commits to remote repository"
                ./send-claude-message.sh frontend:1 "📤 Auto-Push: $UNPUSHED commits pushed to GitHub remote"
                ./send-claude-message.sh backend:1 "📤 Auto-Push: $UNPUSHED commits pushed to GitHub remote"
            fi
        else
            log_message "❌ Failed to push commits - manual intervention required"
            
            # Send failure alert
            if [ -f "./send-claude-message.sh" ]; then
                ./send-claude-message.sh frontend:devops-monitor "🚨 CRITICAL: Failed to auto-push $UNPUSHED commits - manual fix required"
            fi
        fi
    else
        log_message "✅ Repository in sync - no unpushed commits"
    fi
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        UNCOMMITTED=$(git status --porcelain | wc -l | tr -d ' ')
        log_message "⚠️  WARNING: $UNCOMMITTED uncommitted changes detected"
        
        # List uncommitted files
        git status --porcelain | while read status file; do
            log_message "  📂 Uncommitted: $status $file"
        done
        
        # Send uncommitted changes alert
        if [ -f "./send-claude-message.sh" ]; then
            ./send-claude-message.sh frontend:devops-monitor "⚠️ Git Alert: $UNCOMMITTED uncommitted changes detected - teams should commit immediately"
        fi
    fi
    
    log_message "=== Git Compliance Check Complete ==="
    echo ""
}

# Run the compliance check
check_unpushed_commits

# Schedule next check in 10 minutes
if [ "$1" != "--no-reschedule" ]; then
    (sleep 600 && /Users/zippq/aiDev/claudetest/git-compliance-monitor.sh) &
    log_message "📅 Next git compliance check scheduled in 10 minutes"
fi