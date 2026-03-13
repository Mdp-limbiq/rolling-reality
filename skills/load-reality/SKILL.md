---
name: load-reality
description: Read REALITY.md and brief on project state. Use at session start to understand context from previous sessions.
allowed-tools: Read, Glob, Grep
---

# Load Reality Protocol

Read `.claude/REALITY.md` and provide a concise briefing covering:

1. **Objective**: What we're building / current goal
2. **Last session**: What happened, what was decided, any concerns raised
3. **Previous session**: One-line summary for additional context
4. **Active work**: Current branch, PR status, build status
5. **Blockers**: Anything unresolved that needs attention
6. **Next actions**: The priority list for this session

If `.claude/reality-archive/` exists, mention how many archived sessions
are available but do NOT read them unless specifically asked.

Format the briefing as a tight summary, not a wall of text.

End with: "Ready to continue. Which action should we start with, or do you have something else in mind?"
