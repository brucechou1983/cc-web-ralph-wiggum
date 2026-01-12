# Ralph Wiggum Plugin Setup Guide

This guide provides complete step-by-step instructions for setting up the Ralph Wiggum plugin from scratch in any repository for use with Claude Code on the web (claude.ai/code).

## Overview

Ralph Wiggum is an iterative AI development technique that creates autonomous development loops. Named after the Simpsons character, it embodies the philosophy of **persistent iteration despite setbacks**.

The plugin implements a Stop hook that intercepts Claude's exit attempts and re-feeds the same prompt, allowing Claude to iteratively improve its work until completion.

```
You run ONCE:
/ralph-loop "Your task description" --max-iterations 20

Then Claude Code automatically:
1. Works on the task
2. Tries to exit
3. Stop hook blocks exit
4. Same prompt fed back
5. Repeat until completion or max iterations
```

## Prerequisites

* A GitHub repository connected to Claude Code on the web
* Pro, Max, Team, or Enterprise Claude subscription
* Basic familiarity with Claude Code

## Directory Structure

After setup, your repository will have:

```
your-repo/
├── .claude/
│   ├── settings.json              # Hooks configuration
│   ├── commands/
│   │   ├── ralph-loop.md          # Start loop command
│   │   └── cancel-ralph.md        # Cancel loop command
│   └── scripts/
│       ├── setup-ralph-loop.sh    # Loop initialization
│       └── ralph-stop-hook.sh     # Stop hook handler
├── CLAUDE.md                       # Project context (optional)
└── .gitignore                      # Ignore local state file
```

## Setup Instructions

### Step 1: Create the Directory Structure

```bash
mkdir -p .claude/commands
mkdir -p .claude/scripts
```

### Step 2: Create `.claude/settings.json`

This file configures the Stop hook that powers the loop:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/scripts/ralph-stop-hook.sh"
          }
        ]
      }
    ]
  }
}
```

### Step 3: Create `.claude/scripts/ralph-stop-hook.sh`

This script handles the Stop hook logic:

```bash
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
```

### Step 4: Create `.claude/scripts/setup-ralph-loop.sh`

This script initializes a new ralph loop:

```bash
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
```

### Step 5: Create `.claude/commands/ralph-loop.md`

```markdown
---
description: "Start a Ralph Wiggum iterative development loop"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT]"
allowed-tools: ["Bash(${CLAUDE_PROJECT_DIR}/.claude/scripts/setup-ralph-loop.sh:*)"]
---

# Ralph Loop Command

Start an iterative development loop that continues until completion.

## Usage

Execute the setup script with the provided arguments:

Bash("${CLAUDE_PROJECT_DIR}/.claude/scripts/setup-ralph-loop.sh" $ARGUMENTS)

## Arguments

* `PROMPT`: The task description (required)
* `--max-iterations N`: Maximum iterations before stopping (default: 50)
* `--completion-promise TEXT`: Text that signals task completion

## Examples

```
/ralph-loop "Implement user authentication" --max-iterations 20
/ralph-loop "Fix all failing tests" --completion-promise "ALL_TESTS_PASSING"
```

After running this command, work on the task immediately. The Stop hook will automatically continue iterations until the task is complete.
```

### Step 6: Create `.claude/commands/cancel-ralph.md`

```markdown
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
```

### Step 7: Make Scripts Executable

```bash
chmod +x .claude/scripts/setup-ralph-loop.sh
chmod +x .claude/scripts/ralph-stop-hook.sh
```

### Step 8: Update `.gitignore`

Add the local state file to `.gitignore`:

```
# Ralph Wiggum local state
.claude/ralph-loop.local.md
```

### Step 9: Commit and Push

```bash
git add .claude/
git add .gitignore
git commit -m "Add ralph-wiggum plugin for iterative development"
git push
```

## Usage

### Starting a Loop

In Claude Code on the web, type:

```
/ralph-loop "Your task description here" --max-iterations 20
```

Or with a completion promise:

```
/ralph-loop "Migrate all tests from Jest to Vitest. Output DONE when complete." --max-iterations 30 --completion-promise "DONE"
```

### Cancelling a Loop

```
/cancel-ralph
```

### Example Prompts

#### Feature Development

```
/ralph-loop "Implement user authentication with JWT tokens.
Requirements:
  • Login and logout endpoints
  • Token refresh mechanism
  • Password hashing with bcrypt
  • Unit tests for all endpoints
Output FEATURE_COMPLETE when done." --max-iterations 25 --completion-promise "FEATURE_COMPLETE"
```

#### Test Migration

```
/ralph-loop "Migrate all tests from Jest to Vitest.
Success criteria:
  • All tests passing
  • No Jest dependencies remaining
  • Updated CI configuration
Output MIGRATION_DONE when complete." --max-iterations 30 --completion-promise "MIGRATION_DONE"
```

#### Bug Fixing

```
/ralph-loop "Fix all TypeScript errors in the codebase.
Process:
  1. Run tsc --noEmit to find errors
  2. Fix each error
  3. Repeat until no errors
Output NO_ERRORS when tsc passes." --max-iterations 40 --completion-promise "NO_ERRORS"
```

## How It Works

1. **Initialization**: `/ralph-loop` creates a state file (`.claude/ralph-loop.local.md`) with:
   * Active status
   * Iteration count
   * Max iterations
   * Completion promise (optional)
   * The original prompt

2. **Execution**: Claude works on the task normally

3. **Stop Hook**: When Claude tries to exit:
   * The Stop hook checks if a loop is active
   * If active and under max iterations, it blocks exit (exit code 2)
   * Re-injects the original prompt
   * Claude continues working with awareness of previous changes

4. **Completion**: The loop ends when:
   * Max iterations reached
   * User runs `/cancel-ralph`
   * Completion promise detected (if configured)

## Web vs Local Environment

The `CLAUDE_CODE_REMOTE` environment variable indicates the execution context:

* `"true"`: Running on Claude Code web
* Not set or empty: Running locally in CLI

You can use this in scripts if needed:

```bash
if [ "$CLAUDE_CODE_REMOTE" = "true" ]; then
    # Web-specific logic
fi
```

## Philosophy

The Ralph Wiggum technique is based on these principles:

1. **Don't aim for perfect on first try**: Let the loop refine the work
2. **Deterministically bad is informative**: Failures are predictable and teach you how to improve prompts
3. **Prompt engineering matters**: Success depends on writing good prompts
4. **Keep trying until success**: The loop handles retry logic automatically

## Troubleshooting

### Hook Not Triggering

* Verify `.claude/settings.json` is valid JSON
* Check that scripts are executable (`chmod +x`)
* Ensure paths use `${CLAUDE_PROJECT_DIR}` variable

### Loop Not Stopping

* Check if max_iterations is set correctly
* Run `/cancel-ralph` to force stop
* Delete `.claude/ralph-loop.local.md` manually

### Permission Errors

* Ensure scripts have execute permission
* Check that `allowed-tools` in command frontmatter matches the script path

## References

* [Claude Code on the Web Documentation](https://code.claude.com/docs/en/claude-code-on-the-web)
* [Hooks Reference](https://code.claude.com/docs/en/hooks)
* [Original Ralph Wiggum Plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)
* [Geoffrey Huntley's Ralph Technique](https://ghuntley.com/ralph/)

## License

This setup guide is based on the official ralph-wiggum plugin from Anthropic's claude-code repository.
