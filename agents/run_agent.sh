#!/bin/bash
# Usage: ./run_agent.sh [agent_name]
# Example: ./run_agent.sh ceo
# Agents: ceo, cto, cpo, ios_dev, reporter

AGENT=$1
AGENTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$AGENTS_DIR")"

if [ -z "$AGENT" ]; then
  echo "Usage: ./run_agent.sh [ceo|cto|cpo|ios_dev|reporter]"
  exit 1
fi

ROLE_FILE="$AGENTS_DIR/roles/$AGENT.md"

if [ ! -f "$ROLE_FILE" ]; then
  echo "Role file not found: $ROLE_FILE"
  exit 1
fi

echo "🚀 Starting agent: $AGENT"
echo "📁 Working from: $PROJECT_DIR"
echo "📋 Role file: $ROLE_FILE"
echo ""

# Run Claude Code with the agent's role as context
cd "$PROJECT_DIR"
claude --print "$(cat <<EOF
You are running as the following agent. Read your role carefully and execute your responsibilities.

$(cat "$ROLE_FILE")

---

Your working directory is: $PROJECT_DIR
The agents system is in: $AGENTS_DIR
Today's date is: $(date +%Y-%m-%d)

Start by reading COMPANY_STATE.md, then your pending tasks in agents/tasks/, then take action.
EOF
)"
