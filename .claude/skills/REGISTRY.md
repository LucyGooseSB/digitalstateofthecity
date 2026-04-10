# Skill Registry

Central directory for all Claude Code skills in the WorkSpaceFramework.

**Purpose**: Enable skills to understand each other and delegate efficiently.

## Quick Reference

| Skill | Domain | Invoke |
|-------|--------|--------|
| `expert-architect` | System design, tech decisions | `/expert-architect` |
| `expert-backend` | API design, data layer | `/expert-backend` |
| `expert-frontend` | UI architecture, components | `/expert-frontend` |
| `expert-ux` | Usability, accessibility, visual design | `/expert-ux` |
| `expert-security` | Auth, OWASP, permissions | `/expert-security` |
| `expert-testing` | Test strategy, QA | `/expert-testing` |
| `expert-devops` | Deployment, CI/CD | `/expert-devops` |
| `expert-docs` | API docs, user guides | `/expert-docs` |
| `code-review` | Code quality review | `/review` |
| `research` | Fast codebase search (Haiku) | `/research` |
| `ideate` | Work item refinement | `/work refine` |
| `prototype` | Rapid UI prototyping | `/prototype` |
| `verify-app` | Full verification loop | `/verify` |

## Skill Categories

### Core Development
- **expert-backend**: API routes, middleware, database queries
- **expert-frontend**: Components, state management, styling
- **expert-architect**: System design, tech decisions, conflict resolution

### Quality & Security
- **expert-security**: Authentication, authorization, OWASP
- **expert-testing**: Test strategies, coverage, test design
- **code-review**: Code quality, correctness, security review

### Infrastructure & Operations
- **expert-devops**: Docker, deployment, CI/CD pipelines
- **verify-app**: Pre-commit/PR verification

### User Experience
- **expert-ux**: Usability analysis, accessibility, visual consistency

### Support
- **expert-docs**: Documentation, API specs, guides
- **research**: Fast codebase lookups (Haiku model)
- **ideate**: Work item refinement and shaping
- **prototype**: Rapid UI prototyping

## Skill Philosophy

**All skills teach pure methodology — zero tech stack baked in.**

Skills reference principles:
- **expert-architect**: SOLID, 12-Factor App, CAP theorem
- **expert-security**: OWASP Top 10, defense in depth
- **expert-ux**: Nielsen's heuristics, WCAG 2.1 AA
- **expert-testing**: Testing pyramid, AAA pattern, boundary analysis
- **expert-frontend**: Component composition, unidirectional data flow
- **expert-backend**: RESTful design, defense in depth, idempotency

Project-specific knowledge comes from `CONTEXT.md` at runtime.

## Collaboration Matrix

```
                  Back  Front  Sec  Test  UX  Arch  Docs  Rev  Idea  Proto  Ver  Res
expert-backend      -     .     *    *    .    *     .     .    .     .      .    .
expert-frontend     .     -     .    .    *    .     .     .    .     *      .    .
expert-security     *     .     -    *    .    *     .     .    .     .      .    .
expert-testing      *     .     *    -    .    .     .     .    .     .      *    .
expert-ux           .     *     .    .    -    .     .     .    .     *      .    .
expert-architect    *     .     *    .    .    -     .     .    *     .      .    .
expert-docs         .     .     .    .    .    .     -     .    .     .      .    .
code-review         *     *     *    *    .    .     .     -    .     .      .    .
ideate              .     .     .    .    .    *     .     .    -     .      .    *
prototype           .     *     .    .    *    .     .     .    .     -      .    .
verify-app          .     .     .    *    .    .     .     .    .     .      -    .
research            .     .     .    .    .    .     .     .    *     .      .    -

Legend: * = frequently collaborates, . = occasionally collaborates
```

## Common Handoff Patterns

### API Endpoint with Auth
1. `expert-backend` → Route design and implementation
2. `expert-security` → Auth middleware and validation
3. `expert-testing` → Test coverage for endpoint
4. `code-review` → Final quality check

### UI Feature
1. `expert-ux` → Usability requirements and mockup review
2. `expert-frontend` → Component implementation
3. `expert-testing` → Component test coverage
4. `code-review` → Final quality check

### Architecture Decision
1. `expert-architect` → Design options and trade-offs
2. Relevant domain experts → Feasibility input
3. `expert-docs` → Document the decision

### Full Stack Feature
1. `expert-architect` → Overall design
2. `expert-backend` → API layer
3. `expert-frontend` → UI layer
4. `expert-testing` → Test strategy
5. `expert-security` → Security review
6. `code-review` → Final review

### Code Review Pipeline
1. `code-review` → Scans all categories (quality, correctness, surface-level security)
2. Security findings flagged as critical → delegate to `expert-security` for deep analysis
3. Architecture concerns → delegate to `expert-architect` if structural

### Item Shaping (Ideate)
1. `ideate` → Refines problem statement and proposed solution
2. Complex architecture → delegate to `expert-architect` for design options
3. UI-heavy items → suggest `expert-ux` for design review
4. Unknown domain or codebase → use `research` for exploration

### Prototype Workflow
1. `prototype` → Builds the visual artifact
2. `expert-ux` → Reviews usability and accessibility
3. `expert-frontend` → Reviews component structure and patterns

### Verification Pipeline
1. `verify-app` → Runs lint, test, build, health checks
2. Test failures → `expert-testing` for diagnosis and strategy
3. Build failures → relevant domain expert based on error type

## Delegation Guidelines

### When to Delegate
1. Cross-domain question → `expert-architect`
2. Security implications → `expert-security`
3. Database changes → `expert-backend` (or project's DB expert)
4. UI/UX concerns → `expert-ux`
5. Test strategy → `expert-testing`
6. Documentation needs → `expert-docs`
7. Codebase exploration → `research`

### When Utility Skills Should Escalate

| Skill | Escalate When | Escalate To |
|-------|---------------|-------------|
| `code-review` | Critical security finding | `expert-security` |
| `code-review` | Structural architecture concern | `expert-architect` |
| `ideate` | Complex system design surfaces during shaping | `expert-architect` |
| `ideate` | UI/UX-heavy item needs design input | `expert-ux` |
| `ideate` | Unfamiliar codebase area | `research` |
| `prototype` | Accessibility questions during build | `expert-ux` |
| `prototype` | Component pattern questions | `expert-frontend` |
| `verify-app` | Repeated test failures need strategy | `expert-testing` |
| `verify-app` | Build config issues | `expert-devops` |

### How to Delegate
1. Complete your part of the analysis
2. State what requires another expert's input
3. Suggest the specific skill
4. Provide context for the handoff

### Conflict Resolution
When experts disagree, invoke `expert-architect` for the final recommendation.

## Responsibility Boundaries

Several skill pairs share territory. This table documents ownership divisions to prevent duplicated or contradictory advice.

| Overlap Zone | Skill A Owns | Skill B Owns | Handoff Point |
|-------------|-------------|-------------|---------------|
| **Accessibility** | `expert-ux`: Usability analysis, heuristic evaluation, WCAG compliance requirements, design-level accessibility | `expert-frontend`: Implementation of accessible components, ARIA attributes, keyboard navigation code | UX defines requirements → Frontend implements |
| **Auth patterns** | `expert-security`: Threat modeling, auth architecture, token strategy, OWASP auth guidance | `expert-backend`: Implementation of auth middleware, route protection, session management | Security defines approach → Backend implements |
| **Security in review** | `code-review`: Surface-level security scan (hardcoded secrets, obvious injection, credential leaks) | `expert-security`: Deep OWASP analysis, threat modeling, pen test guidance, security architecture | Review flags obvious issues → Security investigates if critical |
| **Monitoring** | `expert-devops`: Monitoring architecture, tooling selection, alerting strategy | `monitoring-observability.md` rule + `/cronitor`: Standards enforcement and telemetry implementation | DevOps designs → Rule enforces standards → Cronitor implements telemetry |
| **Component design** | `expert-frontend`: Component architecture, state management, code structure | `expert-ux`: Visual consistency, usability patterns, design system adherence | UX reviews design → Frontend owns implementation |
| **Input validation** | `expert-backend`: Server-side validation logic, sanitization, database constraints | `expert-security`: Validation as security control, injection prevention strategy | Security defines what to validate → Backend implements how |

### Key Principles

- **Flag and escalate, don't duplicate**: When `code-review` finds a security issue, it flags severity and suggests `expert-security` for deep analysis — it does not attempt a full OWASP audit.
- **Requirements vs implementation**: UX and Security define *what* needs to happen. Frontend and Backend define *how* it gets built.
- **One authoritative source per topic**: When skills overlap, one skill owns the methodology and the other implements it.

## Optional Domain Extensions

These skills are not included in the core framework but can be added to projects that need them. The core framework is intentionally general-purpose — these extensions cover common domains that require specialized methodology.

| Extension | Add When | Key Methodology |
|-----------|----------|-----------------|
| `expert-data` | Project has ETL pipelines, analytics, or data warehousing | Data modeling, pipeline design, query optimization, data quality |
| `expert-mobile` | Native iOS/Android or React Native development | Offline-first patterns, push notifications, app lifecycle, platform guidelines |
| `expert-compliance` | HIPAA, GDPR, SOC2, or other regulatory requirements | Regulatory checklists, audit trails, data handling, consent management |
| `expert-ai` | LLM integration, RAG, embeddings, or ML pipelines | Prompt engineering, retrieval patterns, evaluation, model selection |
| `expert-i18n` | Multi-language support needed | Locale handling, translation workflows, RTL layout, pluralization, date/number formatting |

### Adding an Extension

Use `/setup extend <domain>` to scaffold a new extension skill, or create one manually:

1. Create `.claude/skills/<skill-name>/SKILL.md` using the extension template
2. Add entry to project's REGISTRY.md Quick Reference table
3. Update collaboration matrix with the new skill's relationships
4. Include `References` section pointing to CONTEXT.md

Extensions that prove universally useful across projects may be promoted to the core framework via a regular work item.

## Adding Project-Specific Skills

Projects can add domain-specific skills alongside these core skills:

1. Create folder: `.claude/skills/<skill-name>/SKILL.md`
2. Add entry to project's REGISTRY.md
3. Update collaboration matrix
4. Include `References` section pointing to CONTEXT.md

## Shared Context

All skills should read:
- **CONTEXT.md** — Project-specific tech stack, patterns, and conventions
- **REGISTRY.md** — This file, for understanding available collaborators
