# Framework Context

Shared context for the WorkSpaceFramework itself.

**Note**: When this framework is installed into a project via `/setup`, each project gets its own `CONTEXT.md` with project-specific details. This file describes the framework, not any particular project.

## What This Is

WorkSpaceFramework is a portable Claude Code configuration framework. It provides:
- Behavioral rules governing how Claude interacts
- Slash commands for common workflows
- Expert panel skills (pure methodology, stack-agnostic)
- Work item tracking system
- Templates for installing into new projects

## For Project-Specific Context

When skills reference `CONTEXT.md`, they should read the PROJECT's CONTEXT.md (generated during `/setup`), which contains:

### Expected Sections in Project CONTEXT.md

```markdown
# Project Context

## Tech Stack
| Component | Technology | Notes |
|-----------|------------|-------|
| [layer] | [technology] | [details] |

## Project Structure
[Directory tree of the project]

## Key Patterns
[Established patterns, database helpers, API conventions, etc.]

## Test Commands
| Suite | Command | Description |
|-------|---------|-------------|
| [suite] | [command] | [what it tests] |

## Verify Steps
| Step | Command | Mode |
|------|---------|------|
| [step] | [command] | [quick/standard/full] |

## Design System (if applicable)
[Color tokens, component library, typography, spacing]

## Environment Variables
[Required env vars with descriptions]

## Development Workflow
[How to start dev servers, run tests, deploy]
```

## Framework Development

If you're working ON the framework itself (not in a project that uses it):
- Rules are in `.claude/rules/`
- Commands are in `.claude/commands/`
- Skills are in `.claude/skills/`
- Templates are in `.claude/templates/`
- The work board tracks framework development items
