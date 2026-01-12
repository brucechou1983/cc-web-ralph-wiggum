#!/bin/bash

# Ralph Wiggum Stop Hook
# Intercepts exit attempts and continues the loop if active

RALPH_STATE="${CLAUDE_PROJECT_DIR}/.claude/ralph-loop.local.md"

# If no state file, allow normal exit
if [ ! -f "$RALPH_STATE" ]; then
    exit 0
fi

# Read state from file
ACTIVE=$(grep '^active:' "$RALPH_STATE" 2>/dev/null | sed 's/active: *//')
ITERATIONS=$(grep '^iterations:' "$RALPH_STATE" 2>/dev/null | sed 's/iterations: *//')
MAX_ITERATIONS=$(grep '^max_iterations:' "$RALPH_STATE" 2>/dev/null | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(grep '^completion_promise:' "$RALPH_STATE" 2>/dev/null | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')

# Extract multiline prompt
PROMPT=$(awk '/^prompt: \|/{flag=1; next} flag' "$RALPH_STATE" 2>/dev/null)

# If loop not active, allow exit
if [ "$ACTIVE" != "true" ]; then
    exit 0
fi

# Check if max iterations reached
if [ -n "$MAX_ITERATIONS" ] && [ "$ITERATIONS" -ge "$MAX_ITERATIONS" ]; then
    echo "══════════════════════════════════════════════════════════════"
    echo "Ralph loop completed: reached max iterations ($MAX_ITERATIONS)"
    echo "══════════════════════════════════════════════════════════════"
    sed -i 's/^active: true/active: false/' "$RALPH_STATE" 2>/dev/null || \
        sed -i '' 's/^active: true/active: false/' "$RALPH_STATE"
    exit 0
fi

# Increment iteration count
NEW_ITERATIONS=$((ITERATIONS + 1))
sed -i "s/^iterations: .*/iterations: $NEW_ITERATIONS/" "$RALPH_STATE" 2>/dev/null || \
    sed -i '' "s/^iterations: .*/iterations: $NEW_ITERATIONS/" "$RALPH_STATE"

# Output continuation message
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "Ralph Loop: Iteration $NEW_ITERATIONS of $MAX_ITERATIONS"
if [ -n "$COMPLETION_PROMISE" ] && [ "$COMPLETION_PROMISE" != "null" ]; then
    echo "Completion trigger: $COMPLETION_PROMISE"
fi
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "Continue working on the task. Previous work is preserved."
echo ""
echo "Task:"
echo "$PROMPT"
echo ""

# Exit code 2 blocks the stop and continues the session
exit 2
