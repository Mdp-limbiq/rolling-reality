---
name: save-reality
description: Persist the current session state to REALITY.md for cross-session continuity. Automatically invoked by Claude when a session ends, or manually with /rolling-reality:save-reality.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Save Reality Protocol

You are performing an end-of-session state persistence. This is critical
for continuity across Claude Code sessions. The user's future sessions
depend on the quality of what you write here.

## Locate REALITY.md

Look for `.claude/REALITY.md` in the current project directory.
If it doesn't exist, create it using the template structure below.

## Steps

1. **Read** `.claude/REALITY.md` to understand current state
2. **Check** if `.claude/reality-archive/` exists and what's in it
3. **Analyze this entire conversation** to extract:
   - What was accomplished (concrete, verifiable outcomes only)
   - Decisions made and WHY (the reasoning matters more than the decision)
   - Files that were created, modified, or deleted (with paths)
   - Any risks, concerns, or technical debt introduced
   - What should happen next (be specific and actionable)
4. **Rotate the session chain**:
   - If "Previous Session" has content, append it to
     `.claude/reality-archive/YYYY-MM.md` (create file if needed)
   - Move current "Last Session" content -> "Previous Session" (compress to 5-6 lines max)
   - Write a new "Last Session" with full detail from THIS conversation
5. **Update all other sections**:
   - Update "Objective" if it evolved during this session
   - Update "Active Work" (branch, PR, build/test status)
   - Update "Blockers & Open Questions" (remove resolved, add new)
   - Append to "Architecture Decisions Log" if any decisions were made
   - Write concrete "Next Actions" (3-5 items, priority ordered)
6. **Enforce size limit**:
   - Target: under 120 lines total
   - If exceeding, move older Architecture Decisions to the archive
   - NEVER truncate Next Actions or Last Session - those are sacred

## Template for new REALITY.md

If no REALITY.md exists, create it with this structure:

```markdown
# Project Reality State

## Objective


## Session Chain

### Last Session
- **Date**:
- **Accomplished**:
  -
- **Decisions made**:
  -
- **Key files touched**:
- **Risks/concerns**:

### Previous Session
(no previous session yet)

## Active Work
- **Branch**:
- **PR**:
- **Status**:

## Blockers & Open Questions


## Next Actions
1.
2.
3.

## Architecture Decisions Log

```

## Writing Rules

- Be factual and specific. No filler, no "great progress was made".
- Use exact file paths when referencing changes.
- Decisions need the WHY, not just the WHAT.
- Next Actions must be actionable by a fresh Claude session that has
  ZERO context beyond REALITY.md. Write them as if briefing a new developer.
- Date format: YYYY-MM-DD
- If the session was short or exploratory with no real changes, say so
  honestly. Don't inflate.

## Archive Format

When archiving to `.claude/reality-archive/YYYY-MM.md`, use:

```markdown
## Session: YYYY-MM-DD
- **Accomplished**: [summary]
- **Decisions**: [summary]
---
```
