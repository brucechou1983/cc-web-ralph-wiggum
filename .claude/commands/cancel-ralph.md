---
description: "Cancel an active Ralph Wiggum loop"
---

# Cancel Ralph Loop

Stop the current Ralph Wiggum iteration loop.

## Instructions

1. Check if `.claude/ralph-loop.local.md` exists
2. If it exists, set `active: false` in the file
3. Confirm cancellation to the user

## Implementation

Run this command to cancel:

Bash("sed -i 's/^active: true/active: false/' \"${CLAUDE_PROJECT_DIR}/.claude/ralph-loop.local.md\" 2>/dev/null || sed -i '' 's/^active: true/active: false/' \"${CLAUDE_PROJECT_DIR}/.claude/ralph-loop.local.md\"")

Then confirm: "Ralph loop cancelled. The session will exit normally now."
