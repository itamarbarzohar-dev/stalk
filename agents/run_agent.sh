#!/bin/bash
# Usage: ./run_agent.sh [agent_name]
# Agents: ceo (alex), cto (maya), cpo (sam), ios_dev (jordan), reporter (dana), ux (luna), cro (rex)

AGENT=$1
AGENTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$AGENT" ]; then
  echo "Usage: ./run_agent.sh [ceo|cto|cpo|ios_dev|reporter|ux|cro]"
  exit 1
fi

# Map role name to agent directory (persona name)
case "$AGENT" in
  ceo)      DIR="alex" ;;
  cto)      DIR="maya" ;;
  cpo)      DIR="sam" ;;
  ios_dev)  DIR="jordan" ;;
  reporter) DIR="dana" ;;
  ux)       DIR="luna" ;;
  cro)      DIR="rex" ;;
  *)        DIR="$AGENT" ;;
esac

AGENT_DIR="$AGENTS_DIR/$DIR"

if [ ! -d "$AGENT_DIR" ]; then
  echo "Agent directory not found: $AGENT_DIR"
  echo "Available agents: ceo, cto, cpo, ios_dev, reporter, ux, cro"
  exit 1
fi

echo "Starting agent: $AGENT ($DIR)"
echo "Working from: $AGENT_DIR"
echo ""

cd "$AGENT_DIR"
claude --print "Today's date is $(date +%Y-%m-%d). Start by reading ../COMPANY_STATE.md, then your pending tasks in ../tasks/, then take action."
