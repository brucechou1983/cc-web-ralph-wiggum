# Ralph Wiggum Plugin for Claude Code

A ready-to-use iterative AI development loop plugin for Claude Code on the web (claude.ai/code).

## What is Ralph Wiggum?

Ralph Wiggum is an iterative AI development technique that creates autonomous development loops. Named after the Simpsons character, it embodies the philosophy of **persistent iteration despite setbacks**.

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

## Quick Start

1. **Fork or clone this repository** to your GitHub account
2. **Connect it to Claude Code** on the web
3. **Start using Ralph loops** with the `/ralph-loop` command

That's it! The plugin is pre-configured and ready to use.

## Usage

### Starting a Loop

```
/ralph-loop "Your task description here" --max-iterations 20
```

With a completion promise:

```
/ralph-loop "Fix all failing tests" --completion-promise "ALL_TESTS_PASSING"
```

### Cancelling a Loop

```
/cancel-ralph
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `PROMPT` | The task description | (required) |
| `--max-iterations N` | Maximum iterations before stopping | 50 |
| `--completion-promise TEXT` | Text that signals task completion | (none) |

## Example Prompts

### Feature Development

```
/ralph-loop "Implement user authentication with JWT tokens.
Requirements:
  - Login and logout endpoints
  - Token refresh mechanism
  - Password hashing with bcrypt
  - Unit tests for all endpoints
Output FEATURE_COMPLETE when done." --max-iterations 25 --completion-promise "FEATURE_COMPLETE"
```

### Bug Fixing

```
/ralph-loop "Fix all TypeScript errors in the codebase.
Process:
  1. Run tsc --noEmit to find errors
  2. Fix each error
  3. Repeat until no errors
Output NO_ERRORS when tsc passes." --max-iterations 40 --completion-promise "NO_ERRORS"
```

### Test Migration

```
/ralph-loop "Migrate all tests from Jest to Vitest.
Success criteria:
  - All tests passing
  - No Jest dependencies remaining
  - Updated CI configuration
Output MIGRATION_DONE when complete." --max-iterations 30 --completion-promise "MIGRATION_DONE"
```

## Repository Structure

```
├── .claude/
│   ├── settings.json              # Hooks configuration
│   ├── commands/
│   │   ├── ralph-loop.md          # Start loop command
│   │   └── cancel-ralph.md        # Cancel loop command
│   └── scripts/
│       ├── setup-ralph-loop.sh    # Loop initialization
│       └── ralph-stop-hook.sh     # Stop hook handler
├── README.md                       # This file
├── ralph-wiggum.md                 # Detailed setup guide
└── .gitignore                      # Ignores local state file
```

## How It Works

1. **Initialization**: `/ralph-loop` creates a state file with iteration tracking
2. **Execution**: Claude works on the task normally
3. **Stop Hook**: When Claude tries to exit, the hook blocks it and re-injects the prompt
4. **Completion**: Loop ends when max iterations reached, `/cancel-ralph` is run, or completion promise is detected

## Troubleshooting

### Loop Not Stopping

* Run `/cancel-ralph` to force stop
* Delete `.claude/ralph-loop.local.md` manually if needed

### Hook Not Triggering

* Ensure scripts have execute permission (`chmod +x .claude/scripts/*.sh`)
* Check `.claude/settings.json` is valid JSON

For detailed setup instructions and customization, see [ralph-wiggum.md](ralph-wiggum.md).

## References

* [Claude Code on the Web Documentation](https://code.claude.com/docs/en/claude-code-on-the-web)
* [Hooks Reference](https://code.claude.com/docs/en/hooks)
* [Geoffrey Huntley's Ralph Technique](https://ghuntley.com/ralph/)

## License

Based on the official ralph-wiggum plugin from Anthropic's claude-code repository.
