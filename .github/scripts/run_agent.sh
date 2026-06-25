#!/bin/bash
set -e

INBOX="INBOX.md"

# Find first pending task
TASK=$(grep -m1 '^\- \[ \]' "$INBOX" 2>/dev/null | sed 's/^- \[ \] //')

if [ -z "$TASK" ]; then
  echo "No pending tasks in INBOX.md — nothing to do."
  exit 0
fi

echo "Found task: $TASK"

# Create a branch for this task
BRANCH="agent/$(date +%Y%m%d-%H%M%S)"
git config user.email "agent@stalk.app"
git config user.name "STALK Agent"
git checkout -b "$BRANCH"

# Set up Claude credentials from secret
mkdir -p ~/.claude
echo "$CLAUDE_CREDENTIALS_B64" | base64 -d > ~/.claude/.credentials.json

# Run the agent
echo "Running Claude agent..."
claude --dangerously-skip-permissions --print \
  "You are working on the STALK iOS app (SwiftUI, Swift 6, @Observable macro, never ObservableObject).

   Task: $TASK

   Rules:
   - Only edit Swift files in the STALK/ directory
   - Build must succeed: xcodebuild -scheme STALK -destination 'platform=iOS Simulator,name=iPhone 17'
   - Keep changes minimal and focused on the task
   - Do not commit — just make the code changes

   Make the changes now." || true

# Check if anything changed
if git diff --quiet && git diff --cached --quiet; then
  echo "Agent made no changes."
  exit 0
fi

# Mark task as done in INBOX.md
DATE=$(date +"%Y-%m-%d")
sed -i '' "s/^- \[ \] $(echo "$TASK" | sed 's/[[\.*^$()+?{|]/\\&/g')/- [x] $TASK — done $DATE/" "$INBOX"

# Commit and push
git add -A
git commit -m "Agent: $TASK

Automated by STALK Agent from INBOX.md

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"

git push origin "$BRANCH"

# Open PR
gh pr create \
  --title "Agent: $TASK" \
  --body "$(cat <<EOF
## Task
$TASK

## Source
Triggered automatically from INBOX.md

## Review
Check the diff and merge if it looks good.
EOF
)" \
  --base main \
  --head "$BRANCH"

echo "Done. PR opened for: $TASK"
