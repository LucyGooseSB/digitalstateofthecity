# Changelog

All notable changes to the WorkSpaceFramework will be documented in this file.

## [Unreleased]

## [1.0.0] - 2026-03-19

### Added
- Git guidance rule (W-035): `git-guidance.md` with two comfort levels (guided/terse), git error translation table, and next-step workflow prompts
- Plan mode integration (W-034): `/work start` enters plan mode with work item context, shaping completeness check, and design artifact seeding
- Two-stage quiz system (W-033): split `/work review` into author verification quiz and `/work done` acceptance quiz with scope drift detection
- Interaction analytics (W-022): `/patterns` command with two-layer telemetry — JSONL session capture and derived insight analysis for command usage, skill effectiveness, and decision patterns
- Documentation routing (W-019): `/doc` command with 6 subcommands (generate, publish, list, sync, review, import) routing to ADO Wiki, GitHub docs, or local `docs/` via provider abstraction
- Artifact tracking registry (W-021): `/artifacts` command with list/view/index/stats/tag subcommands, `.meta.json` sidecar schema, and integration contract for all artifact producers
- Review quiz (W-020): LLM-generated comprehension quiz in `/work review` flow with opt-out, scoring, artifact storage, and standalone `/work review-quiz` subcommand
- `/cronitor` verification (W-018): `status`, `verify`, and `list` subcommands for monitoring lifecycle verification and coverage audit
- Skill responsibility boundaries (W-016): documented 6 overlap zones (frontend/ux, backend/security, code-review/security, devops/monitoring) with clear handoff points
- Domain skill extensions (W-017): Optional Domain Extensions section in REGISTRY.md for 5 domains (data, mobile, compliance, AI, i18n) with `extension-skill.md.template` scaffolding
- `/setup remove` (W-015): manifest-based framework uninstallation preserving project-specific content (work items, artifacts, memory)
- CONTEXT.md staleness detection (W-013): Last Updated tracking, staleness warnings at 30/90 day thresholds, `/setup context refresh` and `/setup context check` subcommands
- Support skill matrix (W-012): expanded collaboration matrix from 6x6 to 12x12 covering all 13 skills with handoff patterns for utility skills
- `/release` command (W-011): automated changelog generation from archived work items, version bump suggestions, and git tag creation
- Blocked/dependency mechanism (W-010): `**Blocked By**:` field on items, `/work block` and `/work unblock` subcommands, auto-unblock on completion
- Backward movement protocol (W-009): documented backward lifecycle transitions (e.g., In Review → In Progress) with Stage History tracking and 2+ move nudge
- Error recovery rule (W-008): `error-recovery.md` with error classification (Blocking/Degraded/Transient/Recoverable), multi-step failure protocol, and recovery boundaries
- Project-rule template wiring (W-007): `tech-stack.md` and `domain-patterns.md` templates integrated into `/setup` generation flow
- Skipped/Deferred lifecycle stage (W-006): Skipped as terminal state with resolution categories (wont-fix, superseded, duplicate, obsolete, deferred), `/work skip` and `/work revive` subcommands
- Work provider abstraction (W-003): `/work` commands route to Azure DevOps Boards, GitHub Issues, or local file storage via configurable providers in `.claude/providers/`

### Fixed
- README and install script updated for accurate rule count (12) and extension template copying
- Framework version tracking (W-004): added VERSION file and framework-version stamping for `/setup update` version comparison
- `/work focus` broken reference (W-005): replaced with existing `/work refine` subcommand in setup instructions

## [0.1.0] - 2026-02-24

### Added
- Initial framework release
- 10 behavioral rules (governance, consultation-first, artifact-first, user-interaction, file-organization, visual-workflow, voice-memo, work-system, documentation-standards, monitoring-observability)
- 14 slash commands (work, commit, pr, review, simplify, verify, test, research, prototype, design-review, voice, sketch, cronitor, setup)
- 13 expert skills (8 expert-*, code-review, research, ideate, prototype, verify-app)
- 6 project templates for `/setup` installation
- Unified work system with kanban board
- pencil.dev integration via `/sketch`
- Cronitor telemetry via `/cronitor`
- Voice memo workflow via `/voice`
