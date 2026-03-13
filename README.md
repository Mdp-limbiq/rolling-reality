# Rolling Reality

Cross-session memory for Claude Code. Never lose context after compaction or between sessions.

## The Problem

Claude Code loses all conversational context when:
- You close a session and start a new one
- Context compaction happens (automatic or manual)
- You come back to a project after days/weeks

You're left re-explaining what you were doing, what decisions were made, and what comes next. Every time.

## The Solution

Rolling Reality maintains a `.claude/REALITY.md` file in each project that acts as persistent memory across sessions. It tracks:

- What was accomplished in each session
- Decisions made and **why**
- Active work (branch, PR, status)
- Blockers and open questions
- Concrete next actions

Three hooks protect against context loss:

| Hook | When | What it does |
|---|---|---|
| `PreCompact` | Before compaction | Saves a checkpoint marker |
| `SessionStart:compact` | After compaction | Injects recovery instructions into Claude's context |
| `Stop` | Every Claude response | Reminds you to save after 5+ turns |

## Install

```bash
git clone https://github.com/marianomdo/rolling-reality.git
cd rolling-reality
./install.sh
```

This does two things:
1. Registers the plugin (skills + hooks + scripts) with Claude Code
2. Adds the Rolling Reality Protocol to `~/.claude/CLAUDE.md`

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/quickstart) installed
- `jq` installed (`brew install jq` on macOS, `apt install jq` on Linux)

## Set Up a Project

Open Claude Code in any project and run:

```
/rolling-reality:init-reality My project objective here
```

This creates:
- `.claude/REALITY.md` — the persistent state file
- `.claude/reality-archive/` — monthly archive of older sessions
- Updates `CLAUDE.md` with auto-load and session protocol

## How It Works

```
Session 1                    Session 2                    Session 3
┌──────────┐                ┌──────────┐                ┌──────────┐
│  Work     │   save-reality │  Work     │   save-reality │  Work     │
│  Work     │ ──────────────>│  Work     │ ──────────────>│  Work     │
│  "bye"    │  REALITY.md    │  "done"   │  REALITY.md    │  ...      │
└──────────┘                └──────────┘                └──────────┘

                    Compaction mid-session?
                    ┌──────────┐
                    │  Work     │
                    │  ~compact~│──> PreCompact hook saves marker
                    │  [resume] │<── SessionStart hook injects recovery context
                    │  Work     │    Claude re-reads REALITY.md automatically
                    └──────────┘
```

### Session Start
Claude reads `REALITY.md` (auto-imported via `CLAUDE.md`) and briefs you on what happened last time.

### Session End
When you say "done", "bye", "let's wrap up", etc., Claude automatically runs `/save-reality` — no action needed.

### Compaction Recovery
If compaction happens mid-session, the `SessionStart:compact` hook injects instructions telling Claude to re-read `REALITY.md` and recover context.

## Available Skills

| Skill | Description |
|---|---|
| `/rolling-reality:init-reality [objective]` | Bootstrap Rolling Reality in current project |
| `/rolling-reality:save-reality` | Save session state to REALITY.md |
| `/rolling-reality:load-reality` | Load and brief on project state |

## REALITY.md Structure

```markdown
# Project Reality State

## Objective
What this project is about.

## Session Chain

### Last Session
- Date, accomplishments, decisions, files touched, concerns

### Previous Session
- Compressed summary of the session before last

## Active Work
- Branch, PR, status

## Blockers & Open Questions

## Next Actions
1. Specific, actionable items

## Architecture Decisions Log
- Date: Decision and reasoning
```

Target: under 120 lines. Older sessions get archived to `.claude/reality-archive/YYYY-MM.md`.

## Uninstall

```bash
cd rolling-reality
./uninstall.sh
```

Removes the plugin and protocol from `~/.claude/CLAUDE.md`. Per-project files (`.claude/REALITY.md`, archive) are left untouched.

## Testing Locally

Load the plugin without installing:

```bash
claude --plugin-dir /path/to/rolling-reality
```

## License

MIT
