#!/bin/bash
# Reality Reminder Hook
# Counts Claude turns via a temp file. After 5+ turns of work,
# reminds the user to save reality state before closing.
#
# This runs on every Stop event. To avoid noise:
# - Only shows reminder after 5+ turns
# - Only shows every 10 turns after that
# - Resets when a new session starts (different session ID)

COUNTER_DIR="/tmp/claude-reality"
mkdir -p "$COUNTER_DIR"

# Read session_id from stdin JSON
INPUT=$(cat)
SESSION_KEY=$(echo "$INPUT" | jq -r '.session_id // empty')
if [ -z "$SESSION_KEY" ]; then
    SESSION_KEY="$$"
fi

COUNTER_FILE="$COUNTER_DIR/turns-$SESSION_KEY"

# Initialize or increment
if [ -f "$COUNTER_FILE" ]; then
    COUNT=$(cat "$COUNTER_FILE")
    COUNT=$((COUNT + 1))
else
    COUNT=1
fi

echo "$COUNT" > "$COUNTER_FILE"

# Check if REALITY.md exists in project dir
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
REALITY_FILE="${CWD:-.}/.claude/REALITY.md"
if [ ! -f "$REALITY_FILE" ]; then
    exit 0
fi

# Show reminder at turn 5, then every 10 turns
if [ "$COUNT" -eq 5 ] || [ $((COUNT % 10)) -eq 0 ]; then
    echo ""
    echo "  [Rolling Reality] $COUNT turns in this session. Run /save-reality before closing."
    echo ""
fi

exit 0
