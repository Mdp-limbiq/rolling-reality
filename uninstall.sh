#!/bin/bash
set -e

# Rolling Reality - Uninstaller
# Removes the plugin and optionally cleans up ~/.claude/CLAUDE.md

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()  { echo -e "${BOLD}$1${NC}"; }
ok()    { echo -e "${GREEN}  ✓ $1${NC}"; }
warn()  { echo -e "${YELLOW}  ! $1${NC}"; }

echo ""
info "Rolling Reality - Uninstaller"
echo ""

# ─── Remove plugin from settings ────────────────────────────────────

SETTINGS_FILE="$HOME/.claude/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    info "Removing plugin from settings..."
    TMP_FILE=$(mktemp)
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    jq --arg dir "$SCRIPT_DIR" \
        'del(.enabledPlugins["rolling-reality@local"]) | .pluginDirs = (.pluginDirs // [] | map(select(. != $dir)))' \
        "$SETTINGS_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$SETTINGS_FILE"
    ok "Plugin removed from settings"
fi

# ─── Remove protocol from CLAUDE.md ─────────────────────────────────

CLAUDE_MD="$HOME/.claude/CLAUDE.md"

if [ -f "$CLAUDE_MD" ] && grep -q "Rolling Reality Protocol" "$CLAUDE_MD"; then
    info "Removing Rolling Reality Protocol from CLAUDE.md..."
    # Remove the Rolling Reality Protocol section
    TMP_FILE=$(mktemp)
    sed '/^## Rolling Reality Protocol/,/^## [^R]\|^$/{ /^## [^R]/!d; }' "$CLAUDE_MD" > "$TMP_FILE"
    # Clean up trailing blank lines
    sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$TMP_FILE" > "$CLAUDE_MD"
    rm -f "$TMP_FILE"
    ok "Removed Rolling Reality Protocol from CLAUDE.md"
fi

# ─── Clean up temp files ────────────────────────────────────────────

if [ -d "/tmp/claude-reality" ]; then
    rm -rf "/tmp/claude-reality"
    ok "Cleaned up temp files"
fi

# ─── Done ────────────────────────────────────────────────────────────

echo ""
info "Uninstall complete."
echo ""
echo "  Note: Per-project files were NOT removed."
echo "  Each project may still have:"
echo "    .claude/REALITY.md"
echo "    .claude/reality-archive/"
echo "    CLAUDE.md (with Session Protocol section)"
echo ""
echo "  These contain your session history and are safe to keep or remove manually."
echo ""
