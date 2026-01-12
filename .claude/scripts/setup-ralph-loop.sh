#!/bin/bash

# Parse arguments
PROMPT=""
MAX_ITERATIONS=50
COMPLETION_PROMISE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --completion-promise)
            COMPLETION_PROMISE="$2"
            shift 2
            ;;
        *)
            if [ -z "$PROMPT" ]; then
                PROMPT="$1"
            else
                PROMPT="$PROMPT $1"
            fi
            shift
            ;;
    esac
done

if [ -z "$PROMPT" ]; then
    echo "Error: No prompt provided"
    echo "Usage: setup-ralph-loop.sh \"Your task\" [--max-iterations N] [--completion-promise TEXT]"
    exit 1
fi

# Create state file
STATE_FILE="${CLAUDE_PROJECT_DIR}/.claude/ralph-loop.local.md"

cat > "$STATE_FILE" << EOF
active: true
iterations: 0
max_iterations: $MAX_ITERATIONS
completion_promise: "$COMPLETION_PROMISE"
prompt: |
  $PROMPT
EOF

echo "══════════════════════════════════════════════════════════════"
echo "Ralph Loop Initialized"
echo "══════════════════════════════════════════════════════════════"
echo "Max iterations: $MAX_ITERATIONS"
if [ -n "$COMPLETION_PROMISE" ]; then
    echo "Completion promise: $COMPLETION_PROMISE"
fi
echo ""
echo "The loop will continue until:"
echo "  • Max iterations reached ($MAX_ITERATIONS)"
echo "  • You run /cancel-ralph"
if [ -n "$COMPLETION_PROMISE" ]; then
    echo "  • Claude outputs: $COMPLETION_PROMISE"
fi
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "Starting task:"
echo "$PROMPT"

exit 0
