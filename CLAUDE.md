# CLAUDE.md

This file provides guidance to Claude Code when working within the WorkSpaceFramework.

## What This Is

WorkSpaceFramework is a portable, reusable Claude Code configuration framework. It provides rules, commands, skills, and workflows that can be installed into any project via `/setup`.

This is NOT a project to build software in — it IS the framework that governs how Claude behaves across all your projects.

## Framework Structure

```
WorkSpaceFramework/
├── CLAUDE.md                          # This file
├── README.md                          # Human documentation
├── install.ps1                        # Install framework (PowerShell)
├── install.sh                         # Install framework (Bash)
├── .gitignore
│
├── .claude/
│   ├── settings.local.json            # Framework permissions
│   │
│   ├── rules/                         # Behavioral rules (always active)
│   │   ├── roles-and-governance.md    # You=architect, Claude=partner
│   │   ├── consultation-first.md      # Discuss before implementing
│   │   ├── artifact-first.md          # Show me before you build
│   │   ├── user-interaction.md        # Decision framework for interactions
│   │   ├── file-organization.md       # Directory structure conventions
│   │   ├── visual-workflow.md         # Visual design tool integration
│   │   ├── voice-memo-workflow.md     # Voice capture and processing
│   │   ├── work-system.md            # Unified work tracking lifecycle
│   │   ├── documentation-standards.md # When and what to document
│   │   ├── monitoring-observability.md # When and what to monitor
│   │   ├── error-recovery.md          # How to handle failures
│   │   └── git-guidance.md            # Git comfort levels and error translation
│   │
│   ├── commands/                      # Slash commands
│   │   ├── work.md                    # /work — unified work tracking
│   │   ├── commit.md                  # /commit — git commit workflow
│   │   ├── pr.md                      # /pr — pull request creation
│   │   ├── review.md                  # /review — code review
│   │   ├── simplify.md               # /simplify — complexity reduction
│   │   ├── verify.md                  # /verify — full verification
│   │   ├── test.md                    # /test — run tests
│   │   ├── research.md               # /research — fast codebase search
│   │   ├── prototype.md              # /prototype — rapid prototyping
│   │   ├── design-review.md          # /design-review — design validation
│   │   ├── voice.md                   # /voice — voice memo processing
│   │   ├── sketch.md                  # /sketch — pencil.dev integration
│   │   ├── cronitor.md               # /cronitor — Cronitor telemetry monitoring
│   │   ├── release.md               # /release — changelog and release notes
│   │   ├── artifacts.md              # /artifacts — artifact registry and tracking
│   │   ├── doc.md                    # /doc — documentation routing and generation
│   │   ├── patterns.md              # /patterns — interaction analytics and insights
│   │   └── setup.md                   # /setup — install, update, context, remove
│   │
│   ├── providers/                     # Work provider routing
│   │   ├── provider.md               # Interface contract
│   │   ├── local.md                  # Local provider (default)
│   │   ├── ado.md                    # Azure DevOps provider
│   │   └── github.md                 # GitHub provider
│   │
│   ├── skills/                        # Expert panel (pure methodology)
│   │   ├── REGISTRY.md               # Skill directory and collaboration matrix
│   │   ├── CONTEXT.md                # Framework-level shared context
│   │   ├── expert-architect/SKILL.md # System design
│   │   ├── expert-frontend/SKILL.md  # Frontend (stack-agnostic)
│   │   ├── expert-backend/SKILL.md   # Backend (stack-agnostic)
│   │   ├── expert-ux/SKILL.md        # UX/accessibility
│   │   ├── expert-testing/SKILL.md   # Testing methodology
│   │   ├── expert-security/SKILL.md  # Security (OWASP-based)
│   │   ├── expert-devops/SKILL.md    # DevOps/CI-CD
│   │   ├── expert-docs/SKILL.md      # Documentation
│   │   ├── code-review/SKILL.md      # Code review
│   │   ├── research/SKILL.md         # Fast research (Haiku)
│   │   ├── ideate/SKILL.md           # Idea refinement
│   │   ├── prototype/SKILL.md        # Rapid prototyping
│   │   └── verify-app/SKILL.md       # Application verification
│   │
│   ├── templates/                     # Project installation templates
│   │   ├── CLAUDE.md.template
│   │   ├── CONTEXT.md.template
│   │   ├── REGISTRY.md.template
│   │   ├── settings.local.json.template
│   │   ├── extension-skill.md.template
│   │   └── project-rules/
│   │       ├── tech-stack.md.template
│   │       └── domain-patterns.md.template
│   │
│   ├── work/                          # Unified work tracking
│   │   ├── BOARD.md                  # Generated kanban board (gitignored)
│   │   ├── items/                    # Individual work items (source of truth)
│   │   └── archive/                  # Completed items
│   │
│   ├── patterns/                      # Interaction analytics
│   │   ├── sessions/                 # JSONL telemetry (gitignored)
│   │   └── insights/                 # Derived analysis artifacts
│   │
│   ├── artifacts/                     # Implementation artifacts
│   ├── temp/                          # Scratch work (gitignored)
│   ├── memory/                        # Persistent decisions
│   ├── voice-inbox/                   # Voice memo landing zone
│   └── scripts/
│       └── statusline.js             # Context usage monitor
```

## Key Principles

### 1. Governance (roles-and-governance.md)
You are the architect. Claude is your creative partner. Claude suggests and challenges but never over-executes. The "no surprises" principle: you should never see something you didn't expect.

### 2. Consultation First (consultation-first.md)
Default to discussion. Even explicit requests get confirmation before implementation. Slash commands are the exception — invoking a command IS authorization.

### 3. Artifact First (artifact-first.md)
Show before you build. Any non-trivial change requires a visual artifact (mockup, diagram, plan) before code is written. Iterate on the artifact until approved.

### 4. Unified Work System (work-system.md)
One system, one command (`/work`). Items flow through: Captured → Shaping → Ready → In Progress → In Review → Done. No separate idea vs work item distinction.

## Expert Panel Philosophy

Skills teach **pure methodology** — zero tech stack knowledge baked in. Skills reference principles (SOLID, OWASP, Nielsen heuristics, testing pyramids) and get project-specific knowledge from `CONTEXT.md` at runtime.

This means skills never go stale when you switch stacks.

## Default Work Categories

- `ui` — User interface and visual design
- `backend` — Server-side logic and APIs
- `infrastructure` — Build, deploy, CI/CD, tooling
- `performance` — Speed, optimization, caching
- `security` — Auth, permissions, vulnerability fixes
- `docs` — Documentation and developer experience

Projects can customize categories during `/setup`.

## Workflow Templates

### Feature Implementation
1. `/work add "description"` — Capture the idea
2. `/work refine <id>` — Shape it (problem, solution, criteria)
3. `/work ready <id>` — Mark it ready
4. `/work start <id>` — Begin implementation
5. Code → `/test` → `/review` → `/verify`
6. `/commit` → `/pr`
7. `/work done <id>` — Archive

### Quick Fix
1. Discuss the fix → Get approval → Implement → `/test` → `/commit`

### Design-First Feature
1. `/sketch` or `/prototype` — Create visual artifact
2. Review with user → Iterate
3. Approve → Implement
4. `/design-review` → Verify compliance
5. `/commit` → `/pr`

## Context Management

- Use `/clear` between unrelated tasks (built-in Claude Code command)
- Use `/compact` mid-task when context fills (built-in Claude Code command)
- Use Explore agents for heavy file reads
- Status bar shows context usage (green/yellow/red)

## Installing Into Projects

Run `/setup` in a target project to install the framework. This copies rules, commands, and skills, then generates project-specific CLAUDE.md, CONTEXT.md, and REGISTRY.md from templates.
