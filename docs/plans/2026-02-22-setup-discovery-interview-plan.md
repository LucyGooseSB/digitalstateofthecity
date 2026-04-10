# /setup Discovery Interview Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rewrite the `/setup` command to run a consultative discovery interview before configuring the project, recommend a tech stack, and generate pre-shaped epic work items.

**Architecture:** The `/setup` command becomes a multi-phase interview that saves state to `.claude/artifacts/discovery/discovery.md`. The discovery file acts as resume checkpoint and project origin document. Tech stack recommendation and epic generation happen after the interview, before framework file generation.

**Tech Stack:** Markdown command definitions (Claude Code instruction files). No application code.

**Design doc:** `docs/plans/2026-02-22-setup-discovery-interview-design.md`

---

### Task 1: Rewrite setup.md — Header, Usage, and Resume Logic

**Files:**
- Modify: `.claude/commands/setup.md` (lines 1-12)

**Step 1: Replace the file header and usage block**

Replace lines 1-12 of `setup.md` with:

```markdown
# Setup Command

Configure a new project through a discovery interview. Understands your project before recommending a tech stack or generating files.

## Usage

` ` `bash
/setup                    # Run discovery interview + configure project
/setup update             # Pull framework updates into existing project
` ` `

## `/setup` — Discovery Interview + Configuration

### Pre-flight: Check for Existing Discovery

Before starting, check if `.claude/artifacts/discovery/discovery.md` exists.

**If it does NOT exist**: Proceed to Step 1 (Interview).

**If it exists and Status is NOT `complete`**:

Read the file, note the current Phase, and present:

` ` `
I found an existing discovery session (started {date}, currently in
Phase {N} — {phase_name}).
` ` `

` ` `javascript
{
  question: "How would you like to proceed with the existing discovery?",
  header: "Discovery",
  options: [
    { label: "Continue (Recommended)", description: "Pick up where we left off" },
    { label: "Review & update", description: "Show current summary, let you edit, then continue" },
    { label: "Start over", description: "Archive old discovery, begin fresh" }
  ],
  multiSelect: false
}
` ` `

- **Continue**: Skip to the Phase indicated in the file
- **Review & update**: Display current discovery.md content, let user correct, then continue from current Phase
- **Start over**: Move old file to `.claude/artifacts/discovery/discovery-{timestamp}.md.bak`, create fresh file

**If it exists and Status is `complete`** (setup already finished):

` ` `javascript
{
  question: "Setup was already completed. What would you like to do?",
  header: "Setup",
  options: [
    { label: "Update sections", description: "Re-enter specific sections, re-run stack/epic generation" },
    { label: "Start over", description: "Full redo of discovery and configuration" }
  ],
  multiSelect: false
}
` ` `

- **Update sections**: Ask which section to update, re-run from that point
- **Start over**: Archive and begin fresh
```

**Step 2: Verify the header reads correctly**

Read the file and confirm the pre-flight logic is clear and the AskUserQuestion blocks are valid.

**Step 3: Commit**

```bash
git add .claude/commands/setup.md
git commit -m "refactor(setup): add resume logic and update command description"
```

---

### Task 2: Rewrite setup.md — Interview Phases 1-2

**Files:**
- Modify: `.claude/commands/setup.md` (replace old Steps 1-2)

**Step 1: Write Interview Phase 1 (Vision & Purpose) and Phase 2 (Existing Artifacts)**

Append after the pre-flight section:

```markdown
### Step 1: Discovery Interview

Run a conversational interview in 5 phases. Ask **one question at a time**. After each answered question, update `.claude/artifacts/discovery/discovery.md` with the answer.

**Behavior guidelines:**
- Don't robotically ask every question — read the room
- If the user already answered something in an earlier response, skip it
- If a question isn't relevant (e.g., compliance for a personal side project), skip it
- The phases are a guide, not a script
- Create `.claude/artifacts/discovery/` directory if it doesn't exist

**Initialize discovery.md** with:

` ` `markdown
# Project Discovery

**Started**: {today's date}
**Status**: interviewing
**Phase**: 1-vision
` ` `

#### Phase 1 — Vision & Purpose

Ask about (one at a time, conversationally):
- **Project name**: What should we call this project?
- **Elevator pitch**: In one sentence, what is this project?
- **Target users**: Who is this for?
- **Problem**: What problem does it solve for them?
- **Success criteria**: What does success look like? (metrics, milestones, or feelings)

After gathering answers, update discovery.md:

` ` `markdown
## Vision & Purpose

- **Name**: {answer}
- **Pitch**: {answer}
- **Users**: {answer}
- **Problem**: {answer}
- **Success**: {answer}
` ` `

Update Phase to `2-artifacts`.

#### Phase 2 — Existing Context & Artifacts

Ask what materials already exist. Go through each type conversationally — don't list them all at once. Lead with the most common:

1. "Do you have any visual design materials — color palettes, brand guidelines, logos?"
2. "Any wireframes or mockups? (Figma, pencil.dev, sketches, screenshots)"
3. "Any written requirements — user stories, PRDs, process maps?"
4. "Any technical specs — API docs, database schemas, architecture diagrams?"
5. "Any competitor references or inspiration sites you'd like to match?"

For each artifact provided:
- If it's a local file path: Record the path, attempt to read it for context
- If it's a URL: Record the URL, attempt to fetch it for context
- If it's a description: Record the description

Update discovery.md:

` ` `markdown
## Existing Materials

| Type | Reference | Notes |
|------|-----------|-------|
| {type} | {path_or_url} | {brief notes on what Claude learned} |
` ` `

Update Phase to `3-constraints`.
```

**Step 2: Verify Phase 1-2 instructions are clear and conversational**

Read the new content and confirm the question flow is natural, not robotic.

**Step 3: Commit**

```bash
git add .claude/commands/setup.md
git commit -m "refactor(setup): add interview phases 1-2 (vision, artifacts)"
```

---

### Task 3: Rewrite setup.md — Interview Phases 3-5

**Files:**
- Modify: `.claude/commands/setup.md`

**Step 1: Write Interview Phases 3, 4, and 5**

Append after Phase 2:

```markdown
#### Phase 3 — Constraints & Context

Ask about (one at a time, skip what's not relevant):
- **Timeline**: Any deadlines or target dates?
- **Team size**: Solo developer, small team, or larger?
- **Hosting preferences**: Any requirements or preferences? (cloud provider, self-hosted, low-ops)
- **Compliance**: Any regulatory or compliance needs? (HIPAA, GDPR, SOC2, etc.)
- **Budget**: Any budget constraints that affect tooling choices?
- **Skill level**: What's your experience level with the relevant technologies? Anything you specifically want to learn?

Update discovery.md:

` ` `markdown
## Constraints & Context

- **Timeline**: {answer}
- **Team**: {answer}
- **Hosting**: {answer}
- **Compliance**: {answer or "None"}
- **Budget**: {answer or "No constraints"}
- **Skill level**: {answer}
` ` `

Update Phase to `4-domain`.

#### Phase 4 — Domain Deep-Dive

Ask about (one at a time):
- **Key entities**: What are the main things the system manages? (users, products, orders, etc.)
- **Core user journeys**: Walk me through the main thing a user does, step by step
- **Additional journeys**: Any other important flows? (admin, onboarding, reporting, etc.)
- **Integrations**: Does this need to talk to any external services? (payment, email, auth providers, APIs)
- **Known risks**: Anything you're worried about technically? Any known hard problems?

Update discovery.md:

` ` `markdown
## Domain

- **Entities**: {answer}
- **Key journeys**: {answer}
- **Integrations**: {answer}
- **Risks**: {answer}
` ` `

Update Phase to `5-synthesis`.

#### Phase 5 — Synthesis & Confirmation

Present a structured summary of everything learned. Format it as a clear, scannable document:

` ` `
Here's what I understand about your project:

**{Project Name}**: {pitch}

**For**: {users}
**Problem**: {problem}
**Success**: {success criteria}

**Key entities**: {entities}
**Core journey**: {journey summary}
**Integrations**: {integrations}

**Constraints**: {team size}, {timeline}, {hosting pref}
**Your background**: {skill level summary}

**Existing materials**: {count} items catalogued
` ` `

Ask: "Does this capture your project accurately? Anything to add or correct?"

Incorporate any corrections, update discovery.md, set Status to `recommending-stack`.
```

**Step 2: Verify the full interview flow reads naturally end-to-end**

Read Phases 1-5 sequentially and confirm the progression makes sense.

**Step 3: Commit**

```bash
git add .claude/commands/setup.md
git commit -m "refactor(setup): add interview phases 3-5 (constraints, domain, synthesis)"
```

---

### Task 4: Rewrite setup.md — Tech Stack Recommendation

**Files:**
- Modify: `.claude/commands/setup.md`

**Step 1: Write the tech stack recommendation step**

Append after Phase 5:

```markdown
### Step 2: Tech Stack Recommendation

**Skip condition**: If the user already stated their preferred tech stack during the interview (e.g., "I'm building this in Django + HTMX"), confirm it and move to Step 3. Don't force a recommendation.

Analyze discovery findings across these dimensions:

| Signal | Influences |
|--------|-----------|
| Project complexity (simple site vs. complex app) | Framework weight, build tooling |
| User skill level & learning goals | Familiar vs. aspirational stack choices |
| Domain requirements (realtime, heavy data, media) | Backend language, database type |
| Integrations needed | API style, auth approach |
| Timeline pressure | Convention-over-config frameworks vs. flexible |
| Team size | Monolith vs. services, DX tooling needs |
| Existing artifacts (e.g., Figma with React components) | Frontend framework |

Present **one recommended stack** with rationale tied to interview findings, plus **one alternative** if there's a legitimate trade-off:

` ` `
Based on what we discussed, here's what I'd recommend:

**Backend**: {choice}
  - {rationale tied to interview finding}

**Frontend**: {choice}
  - {rationale tied to interview finding}

**Database**: {choice}
  - {rationale tied to interview finding}

**Infrastructure**: {choice}
  - {rationale tied to interview finding}

**Alternative worth considering**:
  - {alternative approach}
    Pro: {advantage}
    Con: {disadvantage}
` ` `

Wait for user to approve, adjust, or explore a different direction.

Once confirmed, update discovery.md:

` ` `markdown
## Tech Stack

**Status**: confirmed

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Backend | {choice} | {rationale} |
| Frontend | {choice} | {rationale} |
| Database | {choice} | {rationale} |
| Infrastructure | {choice} | {rationale} |
` ` `

Set Status to `generating-epics`.
```

**Step 2: Verify the recommendation format is clear**

Read the section and confirm the skip condition, signal table, and output format work together.

**Step 3: Commit**

```bash
git add .claude/commands/setup.md
git commit -m "refactor(setup): add tech stack recommendation step"
```

---

### Task 5: Rewrite setup.md — Epic Generation

**Files:**
- Modify: `.claude/commands/setup.md`

**Step 1: Write the epic generation step**

Append after the tech stack recommendation:

```markdown
### Step 3: Generate Initial Epics

Derive 4-8 epic-level work items from the discovery findings:

**How to identify epics:**
- Each core user journey from Phase 4 becomes an epic
- Non-trivial infrastructure needs become an epic (CI/CD, deployment, monitoring)
- Substantial integration points each become an epic
- A **project scaffolding** epic is always first (repo setup, boilerplate, dev environment)

**Scope guardrails:**
- Target 4-8 epics. Fewer than 4 = under-explored. More than 8 = consolidate.
- Stay high-level — detailed requirements come during `/work refine`
- Do NOT generate sub-tasks or implementation plans

**Epic format:**

Each item lands in **Shaping** stage with pre-populated content from the interview:

` ` `markdown
# W-{NNN}: {Title}

**Status**: shaping
**Category**: {category from default set}
**Project**: {project name}
**Added**: {today's date}
**Type**: feature

## One-Liner

{Brief description}

## Problem Statement

{Why this epic exists, derived from interview findings}

## Proposed Solution

{High-level approach, informed by tech stack decision}

## Suggested Experts

- {expert} ({why})

## Open Questions

{Any unresolved questions from the interview relevant to this epic}
` ` `

**Present the epic list for approval:**

` ` `
Here's your initial project roadmap ({N} epics):

  W-001: {Title}    [{category}]
  W-002: {Title}    [{category}]
  ...

All items will be in 'Shaping' stage. Use /work refine <id> to
flesh them out, or /work ready <id> when one looks good to go.
` ` `

` ` `javascript
{
  question: "Does this roadmap look right?",
  header: "Epics",
  options: [
    { label: "Approve (Recommended)", description: "Create these work items on the board" },
    { label: "Adjust", description: "Add, remove, merge, or reorder epics first" },
    { label: "Skip", description: "Don't create epics now — I'll add them manually" }
  ],
  multiSelect: false
}
` ` `

- **Approve**: Create all item files in `.claude/work/items/`, add rows to BOARD.md in the Shaping section
- **Adjust**: Discuss changes, update the list, ask again
- **Skip**: Move to Step 4 without creating items

Update discovery.md:

` ` `markdown
## Epics

**Status**: approved | skipped

| ID | Title | Category |
|----|-------|----------|
| W-001 | {title} | {category} |
` ` `

Set Status to `complete` after file generation (Step 4).
```

**Step 2: Verify epic generation connects properly to the work system**

Confirm: items use the same format as `work-system.md`, board rows match BOARD.md format, IDs start at W-001.

**Step 3: Commit**

```bash
git add .claude/commands/setup.md
git commit -m "refactor(setup): add epic generation step"
```

---

### Task 6: Rewrite setup.md — File Generation and Completion

**Files:**
- Modify: `.claude/commands/setup.md`

**Step 1: Write the file generation step and work categories step**

Replace old Steps 3-7 with new Steps 4-5 that consume discovery.md:

```markdown
### Step 4: Work Categories

Present default categories with option to customize:

` ` `javascript
{
  question: "Use default work categories or customize?",
  header: "Categories",
  options: [
    { label: "Defaults (Recommended)", description: "ui, backend, infrastructure, performance, security, docs" },
    { label: "Customize", description: "Add, remove, or rename categories" }
  ],
  multiSelect: false
}
` ` `

Default categories: `ui`, `backend`, `infrastructure`, `performance`, `security`, `docs`

### Step 5: Generate Project Files

**Prerequisite**: Steps 1-3 are complete. Discovery.md has Vision, Tech Stack, and Epics sections.

Read discovery.md and use the gathered information to fill templates.

#### 5a: Directory Structure

Verify the install script has already created the directory structure. If not (running /setup without install script), create:

` ` `
.claude/
├── settings.local.json
├── rules/              # Copy all framework rules
├── commands/           # Copy all framework commands
├── skills/             # Copy all framework skills
│   ├── REGISTRY.md     # Generated from template
│   └── CONTEXT.md      # Generated from template
├── work/
│   ├── BOARD.md        # With epic rows if approved
│   ├── items/          # With epic files if approved
│   └── archive/
├── artifacts/
│   └── discovery/      # Already created during interview
│       └── discovery.md
├── temp/
├── memory/
├── voice-inbox/
└── scripts/
    └── statusline.js
` ` `

#### 5b: Copy Framework Files

**Copy directly** (already portable):
- All files from `.claude/rules/`
- All files from `.claude/commands/`
- All skill directories from `.claude/skills/` (excluding REGISTRY.md and CONTEXT.md which are generated)
- `statusline.js` from `.claude/scripts/`

#### 5c: Generate Project-Specific Files

From templates, fill placeholders using discovery.md content:

1. **CLAUDE.md** — From `CLAUDE.md.template`
   - PROJECT_NAME: from Vision & Purpose → Name
   - PROJECT_DESCRIPTION: from Vision & Purpose → Pitch
   - TECH_STACK_SUMMARY: from Tech Stack table
   - SOURCE_DIR: ask user or infer from project structure
   - ADDITIONAL_SKILLS: empty unless user specified domain skills

2. **CONTEXT.md** — From `CONTEXT.md.template`
   - BACKEND_STACK, FRONTEND_STACK, INFRA_STACK: from Tech Stack table
   - KEY_PATTERNS: from Domain section
   - TEST_COMMANDS, VERIFY_STEPS: sensible defaults for chosen stack
   - DESIGN_SYSTEM: from Existing Materials if design assets provided
   - WORK_CATEGORIES: from Step 4
   - PROJECT_STATUS: "Project initialized via /setup discovery interview"

3. **REGISTRY.md** — From `REGISTRY.md.template`
   - PROJECT_NAME: from Vision & Purpose → Name
   - ADDITIONAL_SKILLS: empty unless specified

4. **settings.local.json** — From `settings.local.json.template`
   - PROJECT_PATH: current project directory

5. **BOARD.md** — Copy empty board, then add epic rows to Shaping section if epics were approved

#### 5d: Update .gitignore

Add entries if not present:

` ` `
# Claude Code framework
.claude/temp/
.claude/voice-inbox/*.txt
.claude/voice-inbox/*.md
!.claude/voice-inbox/.gitkeep
` ` `

#### 5e: Mark Complete

Update discovery.md Status to `complete`.

### Step 6: Summary

Display:

` ` `
Setup complete for {project name}!

Discovery:
  - .claude/artifacts/discovery/discovery.md (project origin document)

Framework:
  - CLAUDE.md (project instructions)
  - .claude/rules/ (8 behavioral rules)
  - .claude/commands/ (13 slash commands)
  - .claude/skills/ (13 expert skills + REGISTRY + CONTEXT)
  - .claude/scripts/statusline.js (context monitor)
  - .claude/settings.local.json (permissions)

Work board:
  - {N} epics in Shaping stage (or "Empty board — add items with /work add")

Recommended tech stack: {one-line summary}

Next steps:
  1. Review .claude/skills/CONTEXT.md and fill in any remaining placeholders
  2. Pick an epic to start: /work refine W-001
  3. Or capture a new idea: /work add "thought"
` ` `
```

**Step 2: Verify the file generation step properly consumes discovery.md**

Read the full Step 5 and confirm every template placeholder maps to a discovery.md section.

**Step 3: Commit**

```bash
git add .claude/commands/setup.md
git commit -m "refactor(setup): add file generation and completion steps"
```

---

### Task 7: Keep `/setup update` section unchanged

**Files:**
- Modify: `.claude/commands/setup.md`

**Step 1: Verify the `/setup update` section and Important section are preserved**

The `/setup update` section (old lines 122-163) must remain exactly as-is after the rewrite. Read the file and confirm these sections are intact at the end of the file.

**Step 2: If missing, restore them**

Copy the `/setup update` and `## Important` sections from the design doc or git history.

**Step 3: Commit (only if changes were needed)**

```bash
git add .claude/commands/setup.md
git commit -m "fix(setup): restore /setup update section"
```

---

### Task 8: Update work-system.md — Note about /setup epic seeding

**Files:**
- Modify: `.claude/rules/work-system.md` (add to Integration section at bottom)

**Step 1: Add setup integration note**

At the end of the "Integration with Other Rules" section in `work-system.md`, add:

```markdown
- **setup command** — `/setup` can seed the board with initial epics during project discovery. These arrive in Shaping stage with pre-populated content from the interview.
```

**Step 2: Verify the addition fits the existing format**

Read the Integration section and confirm the new bullet matches the style of existing bullets.

**Step 3: Commit**

```bash
git add .claude/rules/work-system.md
git commit -m "docs(work-system): note that /setup can seed board with epics"
```

---

### Task 9: Final verification

**Step 1: Read the complete setup.md end-to-end**

Read the entire file and verify:
- [ ] Pre-flight resume logic is present and correct
- [ ] Interview Phases 1-5 are complete and conversational
- [ ] Tech stack recommendation has skip condition
- [ ] Epic generation targets 4-8 items in Shaping stage
- [ ] Work categories step is present
- [ ] File generation consumes discovery.md content
- [ ] Summary shows discovery, framework, and work board info
- [ ] `/setup update` section is unchanged
- [ ] `## Important` section is unchanged

**Step 2: Read work-system.md and verify the new bullet**

Confirm the integration note is present and correctly worded.

**Step 3: Final commit if any fixups needed**

```bash
git add -A
git commit -m "fix(setup): address verification findings"
```
