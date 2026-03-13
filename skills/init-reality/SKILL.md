---
name: init-reality
description: Bootstrap the Rolling Reality system in the current project. Creates .claude/REALITY.md, reality-archive/, and configures CLAUDE.md for automatic cross-session continuity.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "[project objective]"
---

# Initialize Rolling Reality

Set up the Rolling Reality system in the current project directory for
automatic cross-session state persistence.

## Steps

### 1. Create directory structure

```bash
mkdir -p .claude/reality-archive
```

### 2. Create .claude/REALITY.md

Create `.claude/REALITY.md` with the following content. If `$ARGUMENTS`
was provided, use it as the Objective. Otherwise leave it as TBD.

```markdown
# Project Reality State

## Objective
$ARGUMENTS

## Session Chain

### Last Session
(no sessions yet)

### Previous Session
(no previous session yet)

## Active Work
- **Branch**: 
- **PR**: 
- **Status**: initialized

## Blockers & Open Questions


## Next Actions
1. Define project objective and scope (if not already set)
2. Explore existing codebase structure
3. Identify first task to work on

## Architecture Decisions Log

```

### 3. Create or update CLAUDE.md

Check if a `CLAUDE.md` exists at the project root.

**If it does NOT exist**, create it:

```markdown
# Project

## Project State
@.claude/REALITY.md

## Session Protocol
- At the START of every session: read .claude/REALITY.md and begin by briefly stating what the last session accomplished and what the next actions are. Do NOT run /load-reality unless the user asks - just read the file directly since it's already imported above.
- At the END of every session: when the user signals they're done (says "done", "that's all", "bye", "let's wrap up", "save", "close", or similar closing language), AUTOMATICALLY run /save-reality without asking. Do not wait for permission. Just do it.
- If the conversation has been substantive (real work was done, decisions were made, files were changed) and you sense the user might be wrapping up, proactively say: "I'll save our session state before we close."
- After compaction: re-read .claude/REALITY.md to restore project context that may have been lost.
```

**If it DOES exist**, check if it already imports REALITY.md. If not,
add the following block at the TOP of the existing CLAUDE.md (before
existing content):

```markdown
## Project State
@.claude/REALITY.md

## Session Protocol
- At the START of every session: read .claude/REALITY.md and begin by briefly stating what the last session accomplished and what the next actions are. Do NOT run /load-reality unless the user asks - just read the file directly since it's already imported above.
- At the END of every session: when the user signals they're done (says "done", "that's all", "bye", "let's wrap up", "save", "close", or similar closing language), AUTOMATICALLY run /save-reality without asking. Do not wait for permission. Just do it.
- If the conversation has been substantive (real work was done, decisions were made, files were changed) and you sense the user might be wrapping up, proactively say: "I'll save our session state before we close."
- After compaction: re-read .claude/REALITY.md to restore project context that may have been lost.
```

### 4. Add to .gitignore (if git repo)

If a `.gitignore` exists, check if `.claude/reality-archive/` is already
listed. If not, append:

```
# Rolling Reality - session archive
.claude/reality-archive/
```

Do NOT gitignore `.claude/REALITY.md` or `CLAUDE.md` - those should be
committed so collaborators get the same context.

### 5. Confirm

After setup, print a summary:

```
Rolling Reality initialized.

Created:
  .claude/REALITY.md        - project state (survives compaction, chains sessions)
  .claude/reality-archive/  - monthly archive of older sessions
  CLAUDE.md                 - configured with auto-load and session protocol

How it works:
  - Session start: REALITY.md loads automatically via CLAUDE.md import
  - Session end: Claude auto-runs /save-reality when you say "done"/"bye"/etc
  - Compaction: REALITY.md re-loads from disk (untouched by compaction)
  - Manual: /save-reality and /load-reality available anytime

Ready to work. What's the first task?
```
