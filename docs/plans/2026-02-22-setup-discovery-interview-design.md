# Design: /setup Discovery Interview

**Date**: 2026-02-22
**Status**: Approved

## Summary

Redesign the `/setup` command from a mechanical "gather tech stack, copy files" process into a consultative discovery interview. Claude interviews the user about their project, recommends a tech stack based on findings, and generates pre-shaped epic-level work items as the initial project roadmap.

## Approach

Single-pass interview with final synthesis (Approach A). The discovery file (`discovery.md`) acts as the state machine for resumability. No separate `/discover` command — the interview IS the setup.

## Architecture

```
install.ps1 / install.sh          /setup (inside project)
─────────────────────             ──────────────────────────────
1. Copy framework files     →     2. Discovery interview (Phases 1-4)
   (mechanical, no interview)     3. Synthesis & confirmation (Phase 5)
                                  4. Tech stack recommendation
                                  5. Epic generation (4-8 items)
                                  6. Generate project-specific files
                                     (CLAUDE.md, CONTEXT.md, REGISTRY.md)
                                  7. Summary & next steps
```

Install scripts stay unchanged. `/setup` becomes the intelligent configuration step.

## Interview Structure

5 phases, one question at a time, conversational. Claude skips questions already answered or not relevant.

### Phase 1 — Vision & Purpose
- Project name and elevator pitch
- Target users/audience
- Problem being solved
- What success looks like

### Phase 2 — Existing Context & Artifacts
- Brand assets (logos, color palettes, style guides)
- Wireframes or mockups (Figma, pencil.dev, sketches)
- Process maps or flowcharts
- User stories or requirements docs
- API specs or database schemas
- Competitor references or inspiration sites

Artifacts get catalogued by reference (path/URL) in discovery.md, not copied.

### Phase 3 — Constraints & Context
- Timeline / deadlines
- Team size (when > 1, triggers follow-up questions for Team Members table and Git Workflow conventions — see team scaling features)
- Hosting preferences
- Compliance / regulatory needs
- Budget constraints
- User's skill level and learning goals

### Phase 4 — Domain Deep-Dive
- Key entities / domain objects
- Core user journeys (happy path)
- Integration points (3rd party APIs, auth, payment, etc.)
- Known technical challenges or risks

### Phase 5 — Synthesis & Confirmation
- Claude presents structured summary
- User confirms or corrects
- Becomes final discovery.md

Claude reads the room — doesn't robotically ask every question. Skips what's already been answered or isn't relevant.

## Tech Stack Recommendation

After the interview, Claude recommends a stack based on discovery signals:

| Signal | Influences |
|--------|-----------|
| Project complexity | Framework weight, build tooling |
| User skill level & learning goals | Familiar vs. aspirational choices |
| Domain requirements (realtime, heavy data, media) | Backend language, database type |
| Integrations needed | API style, auth approach |
| Timeline pressure | Convention-over-config vs. flexible |
| Team size | Monolith vs. services, DX tooling |
| Existing artifacts (e.g., Figma with React components) | Frontend framework |

Claude presents **one recommended stack** with rationale tied to interview findings, plus **one alternative** if there's a legitimate trade-off.

If the user already stated their stack during the interview, Claude skips recommendation — just confirms and moves on.

## Epic Generation

Claude derives 4-8 epic-level work items from the discovery findings:

- Core user journeys become epics
- Non-trivial infrastructure needs become an epic
- Substantial integration points become epics
- A project scaffolding epic is always first

### Epic format

Items land in **Shaping** stage with pre-populated content:
- One-liner
- Problem statement
- Proposed solution
- Suggested experts
- Open questions

Claude presents the full list. User approves, adds, removes, or merges before they're written to disk.

### Scope guardrails
- Target 4-8 epics
- Stay high-level — detailed requirements come during `/work refine`
- No sub-tasks or implementation plans at this stage

## Discovery File

Lives at `.claude/artifacts/discovery/discovery.md`. Grows incrementally as questions are answered.

### Format

```markdown
# Project Discovery

**Started**: 2026-02-22
**Status**: interviewing | recommending-stack | generating-epics | complete
**Phase**: 1-vision | 2-artifacts | 3-constraints | 4-domain | 5-synthesis

## Vision & Purpose
- **Name**: ...
- **Pitch**: ...
- **Users**: ...
- **Problem**: ...
- **Success**: ...

## Existing Materials
| Type | Reference | Notes |
|------|-----------|-------|

## Constraints & Context
- **Timeline**: ...
- **Team**: ...
- **Hosting**: ...
- **Compliance**: ...
- **Skill level**: ...

## Domain
- **Entities**: ...
- **Key journeys**: ...
- **Integrations**: ...
- **Risks**: ...

## Tech Stack
**Status**: pending | confirmed
| Layer | Choice | Rationale |
|-------|--------|-----------|

## Epics
**Status**: pending | approved
| ID | Title | Category |
|----|-------|----------|
```

### Resume behavior

When `/setup` is invoked and `discovery.md` exists:

**If status is not `complete`:**
- **Continue** — pick up where we left off
- **Start over** — archive old discovery, begin fresh
- **Review & update** — show current summary, let user edit, then continue

**If status is `complete`:**
- **Update** — re-enter specific sections, re-run stack/epic generation
- **Start over** — full redo

After each answered question, Claude updates the relevant section of discovery.md. At most one answer is lost if session ends unexpectedly.

## Files Changed

| File | Change |
|------|--------|
| `.claude/commands/setup.md` | **Rewrite.** Replace Steps 1-2 with 5-phase interview. Add tech stack recommendation. Add epic generation. Steps 3-7 (file generation) consume discovery.md. |
| `.claude/rules/work-system.md` | **Minor addition.** Note that `/setup` can seed the board with initial epics. |

## Files Unchanged

- `.claude/templates/CONTEXT.md.template` — placeholders already cover interview output
- `.claude/templates/CLAUDE.md.template` — same placeholders still work
- `install.ps1` / `install.sh` — no interviews, just file copying
- `/setup update` subcommand — unchanged
- Work system, board format, item format — unchanged

## New File Created by /setup

```
.claude/artifacts/discovery/
└── discovery.md    # Interview findings, stack decision, epic list
```

Persists after setup as a project origin document.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Single vs. split command | Single `/setup` | Discovery IS setup. Splitting adds cognitive overhead without benefit. |
| Interview style | Conversational, one question at a time | Respects user's time, doesn't overwhelm. Claude skips irrelevant questions. |
| Epic detail level | Pre-shaped (Shaping stage) | User chose this — Claude fills problem statement, proposed solution, experts from interview context. |
| Resume mechanism | discovery.md as state machine | Incremental saves after each answer. Status + Phase fields track position. |
| Artifact handling | Catalogue by reference | Don't copy files. Record paths/URLs for later use during implementation. |
| Epic count | 4-8 target | Fewer = under-explored. More = needs consolidation. |
| Stack recommendation | One primary + one alternative | Opinionated but not dogmatic. Skip if user already stated preference. |
