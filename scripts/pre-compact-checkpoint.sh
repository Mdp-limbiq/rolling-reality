#!/bin/bash
# Pre-Compact Checkpoint Hook
# Fires BEFORE compaction occurs.
#
# Since PreCompact stdout is NOT injected as context, everything here
# is side-effects only. We:
# 1. Save a compaction marker with metadata
# 2. Snapshot the current REALITY.md so the post-compact hook can
#    inject it directly as context (avoids relying on Claude to read it)

INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')

MARKER_DIR="/tmp/claude-reality"
mkdir -p "$MARKER_DIR"

# Write compaction marker
cat > "$MARKER_DIR/compaction-marker" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "session_id": "$SESSION_ID",
  "cwd": "$CWD",
  "transcript_path": "$TRANSCRIPT"
}
EOF

# Snapshot REALITY.md if it exists — this is the key addition.
# The post-compact hook will inject this snapshot directly into context
# so Claude has the ground truth immediately, not just instructions to
# go read a file.
REALITY_FILE="${CWD:-.}/.claude/REALITY.md"
if [ -f "$REALITY_FILE" ]; then
    cp "$REALITY_FILE" "$MARKER_DIR/reality-snapshot.md"
fi

exit 0
