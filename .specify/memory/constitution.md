<!--
Sync Impact Report
Version change: unversioned template -> 1.0.0
Modified principles:
- template slot PRINCIPLE_1_NAME -> I. Feature-First Flutter Architecture
- template slot PRINCIPLE_2_NAME -> II. Managers Own State, Services Own I/O
- template slot PRINCIPLE_3_NAME -> III. Verification Before Merge (NON-NEGOTIABLE)
- template slot PRINCIPLE_4_NAME -> IV. Explicit Navigation, Auth, and Dependency Boundaries
- template slot PRINCIPLE_5_NAME -> V. Controlled Code Generation and Dependency Hygiene
Added sections:
- Implementation Standards
- Delivery Workflow
Removed sections:
- None
Templates requiring updates:
- ✅ .specify/templates/plan-template.md
- ✅ .specify/templates/spec-template.md
- ✅ .specify/templates/tasks-template.md
- ⚠ pending: .specify/templates/commands/*.md (directory not present in this repo; no validation performed)
- ✅ README.md
Follow-up TODOs:
- None
-->

# PF2E App Constitution

## Core Principles

### I. Feature-First Flutter Architecture
Production code MUST be organized by feature under `lib/features/<feature>/` and use
feature-local `manager/`, `services/`, `widgets/`, and page files as the default shape.
Code MUST move into a shared location only after at least two features depend on it or a
cross-cutting boundary is already proven. Plans and tasks MUST identify the feature
directories being changed before implementation starts. Rationale: the repository already
uses feature boundaries for auth, adventures, profile, and home, and this boundary keeps
growth understandable.

### II. Managers Own State, Services Own I/O
Widgets MUST read and mutate application state through managers, commands, and reactive
listenables. Services MUST encapsulate external I/O such as Auth0, Supabase, storage, or
network access and MUST NOT become presentation-state containers. Dependency injection
registrations MUST remain centralized in `lib/locator.dart`, and new abstractions MUST fit
the existing `get_it`, `watch_it`, `command_it`, and `listen_it` stack unless a plan proves
that the current stack is insufficient. Rationale: this preserves a single state model and
keeps external boundaries mockable.

### III. Verification Before Merge (NON-NEGOTIABLE)
Every behavior change MUST define a verification strategy before code merges. New user
flows, regressions, and bug fixes MUST add or update automated tests at the appropriate
level unless technically impossible; if automation is not feasible, the plan and tasks MUST
record the reason and the manual verification steps. Tests under `test/` MUST use relative
imports for shared test utilities. Rationale: the repository already depends on `flutter_test`
and scoped test helpers, and unverified UI and auth changes are too easy to regress.

### IV. Explicit Navigation, Auth, and Dependency Boundaries
Routes MUST be declared in `lib/router.dart`, and route-affecting changes MUST regenerate
the corresponding generated artifacts in the same change. Auth and session-sensitive
behavior MUST be enforced in managers, guards, or scoped dependencies rather than copied
across widgets. Runtime overrides in tests or feature flows MUST use `get_it` scopes instead
of mutating singleton instances in place. Rationale: navigation and auth are central system
boundaries and must stay explicit, reviewable, and testable.

### V. Controlled Code Generation and Dependency Hygiene
Generated sources such as route outputs and Mockito mocks MUST only be modified through
their generators. Any change affecting annotations, routes, or generated APIs MUST include
the source change and regenerated outputs together. New packages MUST be justified in the
implementation plan with the affected feature, why the existing stack is insufficient, and any
platform, security, or maintenance implications. Rationale: this project already relies on
build-time generation and cross-platform dependencies, so dependency and codegen drift must
be deliberate.

## Implementation Standards

- Feature specifications and plans MUST identify affected feature modules, managers,
	services, routes, and generated outputs when those surfaces change.
- External integrations, including Auth0, Supabase, and dotenv-backed configuration, MUST
	remain behind service boundaries with test doubles available for automated verification.
- Async UI work MUST expose loading, success, and error states through commands or other
	reactive state holders rather than ad hoc widget-local side effects.
- Manual edits to generated files or transient build outputs under `build/` are prohibited.
	Generated Dart sources may be committed only when the source inputs changed in the same
	change set.

## Delivery Workflow

- Substantial feature work MUST flow through `spec.md`, `plan.md`, and `tasks.md` before
	implementation. Small isolated fixes may skip formal artifacts only when the scope is
	limited to one behavior and the change still satisfies this constitution.
- The plan's Constitution Check MUST confirm feature placement, manager/service boundaries,
	verification coverage, route or auth impact, dependency-scope impact, and code generation
	implications before design proceeds.
- Tasks MUST be grouped by user story, include the required verification work, and add
	explicit DI, routing, code generation, or integration tasks whenever those surfaces change.
- Code review MUST verify constitution compliance, generator freshness, and that changed
	behavior has matching automated coverage or documented manual validation.

## Governance

- This constitution supersedes conflicting guidance in local templates and working notes.
- Amendments MUST be made by updating this file, including a Sync Impact Report at the top,
	and propagating the change to affected templates or runtime guidance in the same change.
- Versioning policy for this constitution uses semantic versioning: MAJOR for incompatible
	principle or governance changes, MINOR for new principles or materially expanded required
	guidance, and PATCH for clarifications that do not change obligations.
- Compliance review is mandatory during implementation planning, task generation, and code
	review. Any exception MUST be documented in the implementation plan's Complexity Tracking
	section and approved before merge.

**Version**: 1.0.0 | **Ratified**: 2026-04-05 | **Last Amended**: 2026-04-05
