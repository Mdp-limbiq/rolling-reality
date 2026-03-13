#!/bin/bash
# Post-Compact Context Injection Hook (SessionStart matcher: compact)
# Fires AFTER compaction resumes the session. stdout IS added as context
# that Claude can see and act on.
#
# This is the critical piece: it tells Claude what just happened and
# instructs it to recover state from REALITY.md.

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

REALITY_FILE="${CWD:-.}/.claude/REALITY.md"
MARKER_DIR="/tmp/claude-reality"
MARKER_FILE="$MARKER_DIR/compaction-marker"

# Check if this project uses Rolling Reality
if [ ! -f "$REALITY_FILE" ]; then
    exit 0
fi

# Build context injection
COMPACTION_TIME=""
if [ -f "$MARKER_FILE" ]; then
    COMPACTION_TIME=$(jq -r '.timestamp // "unknown"' "$MARKER_FILE" 2>/dev/null)
    # Clean up marker
    rm -f "$MARKER_FILE" "$MARKER_DIR/has-reality"
fi

cat << EOF
COMPACTION RECOVERY NOTICE:
Context compaction just occurred${COMPACTION_TIME:+ at $COMPACTION_TIME}. Most of your previous conversation context has been compressed.

IMMEDIATE ACTIONS REQUIRED:
1. Re-read .claude/REALITY.md to restore project state awareness
2. If you were in the middle of a task, check the "Active Work" and "Next Actions" sections
3. Run /save-reality NOW to persist any in-flight work that may have been lost from the conversation window
4. Then continue where you left off

The REALITY.md file contains the last known project state. Your CLAUDE.md already imports it via @.claude/REALITY.md, but re-reading it explicitly ensures you have full context.
EOF

exit 0
