#!/bin/bash
set -e

# Rolling Reality - Installer
# Installs the plugin via Claude Code CLI and patches ~/.claude/CLAUDE.md
# with the global Rolling Reality Protocol.

BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${BOLD}$1${NC}"; }
ok()    { echo -e "${GREEN}  ✓ $1${NC}"; }
warn()  { echo -e "${YELLOW}  ! $1${NC}"; }
err()   { echo -e "${RED}  ✗ $1${NC}"; }

echo ""
info "Rolling Reality - Installer"
echo ""

# ─── Check prerequisites ────────────────────────────────────────────

if ! command -v claude &> /dev/null; then
    err "Claude Code CLI not found. Install it first: https://docs.anthropic.com/en/docs/claude-code/quickstart"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    warn "jq not found. Hook scripts need jq for JSON parsing."
    warn "Install it: brew install jq (macOS) or apt install jq (Linux)"
fi

# ─── Determine install source ───────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Install plugin ─────────────────────────────────────────────────

info "Step 1: Installing plugin..."

# Check if already installed
if claude plugin list 2>/dev/null | grep -q "rolling-reality"; then
    warn "Plugin already installed. Updating..."
    claude plugin uninstall rolling-reality --scope user 2>/dev/null || true
fi

# Install from local directory
# Users who cloned the repo install from their local copy
# The plugin system copies files to ~/.claude/plugins/cache/
claude --plugin-dir "$SCRIPT_DIR" --print-only 2>/dev/null && true

# For persistent installation, we need to tell the user to use the marketplace
# or we can directly manipulate settings.json
info "  Registering plugin in user settings..."

SETTINGS_FILE="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"

if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# Check if enabledPlugins exists and add our plugin path
PLUGIN_KEY="rolling-reality@local"

# Use jq to add plugin to enabledPlugins if not already there
if jq -e ".enabledPlugins[\"$PLUGIN_KEY\"]" "$SETTINGS_FILE" &>/dev/null; then
    ok "Plugin already registered in settings"
else
    # Add plugin directory path for local plugin loading
    TMP_FILE=$(mktemp)
    jq --arg key "$PLUGIN_KEY" --arg dir "$SCRIPT_DIR" \
        '.enabledPlugins[$key] = true | .pluginDirs = (.pluginDirs // []) + [$dir] | .pluginDirs |= unique' \
        "$SETTINGS_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$SETTINGS_FILE"
    ok "Plugin registered"
fi

# ─── Patch global CLAUDE.md ──────────────────────────────────────────

info "Step 2: Patching ~/.claude/CLAUDE.md..."

CLAUDE_MD="$HOME/.claude/CLAUDE.md"
REALITY_PROTOCOL='## Rolling Reality Protocol (Global)

Every project that has a `.claude/REALITY.md` file uses the Rolling Reality system for cross-session continuity.

**Session start**: If `.claude/REALITY.md` exists, read it and briefly state what the last session accomplished and what the next actions are.

**Session end**: When the user signals they are done (says "done", "that'\''s all", "bye", "let'\''s wrap up", "save", "close", or similar closing language), AUTOMATICALLY run `/save-reality` without asking. Do not wait for permission. Just do it.

**After compaction**: If `.claude/REALITY.md` exists, re-read it to restore project context that may have been lost from the conversation window.'

if [ -f "$CLAUDE_MD" ]; then
    if grep -q "Rolling Reality Protocol" "$CLAUDE_MD"; then
        ok "Rolling Reality Protocol already in CLAUDE.md"
    else
        echo "" >> "$CLAUDE_MD"
        echo "$REALITY_PROTOCOL" >> "$CLAUDE_MD"
        ok "Appended Rolling Reality Protocol to existing CLAUDE.md"
    fi
else
    echo "$REALITY_PROTOCOL" > "$CLAUDE_MD"
    ok "Created CLAUDE.md with Rolling Reality Protocol"
fi

# ─── Done ────────────────────────────────────────────────────────────

echo ""
info "Installation complete."
echo ""
echo "  What was installed:"
echo "    - Plugin with 3 skills: save-reality, load-reality, init-reality"
echo "    - 3 hooks: PreCompact (checkpoint), SessionStart:compact (recovery), Stop (reminder)"
echo "    - Global Rolling Reality Protocol in ~/.claude/CLAUDE.md"
echo ""
echo "  To set up a project:"
echo "    1. Open Claude Code in your project directory"
echo "    2. Run: /rolling-reality:init-reality [project objective]"
echo "    3. That's it. Sessions will auto-save and auto-recover."
echo ""
echo "  Available skills:"
echo "    /rolling-reality:init-reality  - Bootstrap a new project"
echo "    /rolling-reality:save-reality  - Save session state (auto on session end)"
echo "    /rolling-reality:load-reality  - Load and brief on project state"
echo ""
