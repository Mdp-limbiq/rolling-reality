#!/bin/bash
# Post-Compact Context Injection (SessionStart matcher: compact)
#
# This is the most critical script in Rolling Reality.
# Its stdout IS injected as context that Claude sees and acts on.
#
# Strategy:
# - Inject REALITY.md content directly (the source of truth)
# - Tell Claude explicitly: the compaction summary above may contain
#   outdated or reversed decisions. REALITY.md is the judge.

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

REALITY_FILE="${CWD:-.}/.claude/REALITY.md"
MARKER_DIR="/tmp/claude-reality"
MARKER_FILE="$MARKER_DIR/compaction-marker"
SNAPSHOT_FILE="$MARKER_DIR/reality-snapshot.md"

# Only activate for projects with Rolling Reality
if [ ! -f "$REALITY_FILE" ]; then
    exit 0
fi

# Use the pre-compaction snapshot if available, otherwise read current file
if [ -f "$SNAPSHOT_FILE" ]; then
    REALITY_CONTENT=$(cat "$SNAPSHOT_FILE")
else
    REALITY_CONTENT=$(cat "$REALITY_FILE")
fi

COMPACTION_TIME=""
if [ -f "$MARKER_FILE" ]; then
    COMPACTION_TIME=$(jq -r '.timestamp // "unknown"' "$MARKER_FILE" 2>/dev/null)
fi

# Clean up temp files
rm -f "$MARKER_FILE" "$SNAPSHOT_FILE" "$MARKER_DIR/has-reality"

cat << 'HEADER'
=== ROLLING REALITY: POST-COMPACTION RECOVERY ===

CRITICAL: Context compaction just happened. The summary above was generated
automatically by Claude Code and MAY CONTAIN OUTDATED OR CONTRADICTED INFORMATION.
Decisions that were made early in the session and later reversed will BOTH appear
in the compaction summary with equal weight. Do NOT trust it blindly.

YOUR SOURCE OF TRUTH is the REALITY.md content below. This was captured by the
Rolling Reality system and represents the CURATED, VERIFIED project state.

RULES FOR THIS RECOVERY:
1. Where the compaction summary contradicts REALITY.md, REALITY.md wins.
2. Where the compaction summary has info not in REALITY.md (work done THIS session
   that wasn't saved yet), treat it as TENTATIVE — mention it to the user and ask
   for confirmation before acting on it.
3. After recovery, run /save-reality to persist any in-flight work from this session
   that REALITY.md doesn't yet reflect.
4. Briefly tell the user what you know and what you're unsure about.

HEADER

echo "Compaction occurred at: ${COMPACTION_TIME:-unknown}"
echo ""
echo "=== REALITY.MD (SOURCE OF TRUTH) ==="
echo ""
echo "$REALITY_CONTENT"
echo ""
echo "=== END REALITY.MD ==="
echo ""
echo "Resume by briefing the user on current state based on REALITY.md above."
echo "Flag anything from the compaction summary that seems new but isn't in REALITY.md."

exit 0
