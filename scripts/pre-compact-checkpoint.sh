#!/bin/bash
# Pre-Compact Checkpoint Hook
# Fires BEFORE compaction occurs. Since PreCompact output is NOT injected
# as context (it's side-effect only), we save a timestamp marker so the
# SessionStart(compact) hook knows compaction just happened.

# Read JSON input from stdin
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')

# Create marker directory
MARKER_DIR="/tmp/claude-reality"
mkdir -p "$MARKER_DIR"

# Write compaction marker with metadata
MARKER_FILE="$MARKER_DIR/compaction-marker"
cat > "$MARKER_FILE" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "session_id": "$SESSION_ID",
  "cwd": "$CWD",
  "transcript_path": "$TRANSCRIPT"
}
EOF

# If REALITY.md exists in the project, note the compaction event
REALITY_FILE="${CWD:-.}/.claude/REALITY.md"
if [ -f "$REALITY_FILE" ]; then
    touch "$MARKER_DIR/has-reality"
fi

exit 0
