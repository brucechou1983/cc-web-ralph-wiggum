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
