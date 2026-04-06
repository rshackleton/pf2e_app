---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Verification tasks are REQUIRED for every behavior-changing story. If no new automated
test is added, the task list MUST include the reason and the manual validation steps.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **App code**: `lib/features/`, `lib/app.dart`, `lib/locator.dart`, `lib/router.dart`
- **Generated code**: `lib/router.gr.dart`, `test/test_mocks.mocks.dart`, other generator outputs
- **Tests**: `test/` with relative imports for shared test utilities
- Paths shown below assume this Flutter repository structure - adjust to the exact feature paths in `plan.md`

<!--
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.

  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/

  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment

  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create or confirm the feature-local structure in `lib/features/[feature]/`
- [ ] T002 Identify any updates needed in `lib/locator.dart`, `lib/router.dart`, or `lib/env/`
- [ ] T003 [P] Prepare test scaffolding or mocks in `test/` for the changed feature

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T004 Establish manager and service responsibilities for the feature
- [ ] T005 [P] Register new dependencies or scoped overrides in `lib/locator.dart`
- [ ] T006 [P] Define route, guard, or navigation changes in `lib/router.dart`
- [ ] T007 Create or update shared models/entities used by multiple stories
- [ ] T008 Configure loading/error handling surfaces for async commands
- [ ] T009 Note any code generation or environment configuration work required

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 ⚠️

> **NOTE: Define verification before implementation and ensure it exercises the user-facing behavior**

- [ ] T010 [P] [US1] Add or update widget/unit/flow test coverage in `test/[name]_test.dart`
- [ ] T011 [P] [US1] Add manual validation notes only if automation cannot fully cover the change

### Implementation for User Story 1

- [ ] T012 [P] [US1] Create or update feature models/state holders in `lib/features/[feature]/`
- [ ] T013 [P] [US1] Implement service-layer changes in `lib/features/[feature]/services/`
- [ ] T014 [US1] Implement manager or command logic in `lib/features/[feature]/manager/`
- [ ] T015 [US1] Implement UI, page, or widget changes in `lib/features/[feature]/`
- [ ] T016 [US1] Update routing, guards, or dependency registration if required
- [ ] T017 [US1] Regenerate code if annotations, routes, or mocks changed

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 ⚠️

- [ ] T018 [P] [US2] Add or update widget/unit/flow test coverage in `test/[name]_test.dart`
- [ ] T019 [P] [US2] Add manual validation notes only if automation cannot fully cover the change

### Implementation for User Story 2

- [ ] T020 [P] [US2] Create or update feature models/state holders in `lib/features/[feature]/`
- [ ] T021 [US2] Implement service or integration updates in `lib/features/[feature]/services/`
- [ ] T022 [US2] Implement manager and UI behavior in `lib/features/[feature]/`
- [ ] T023 [US2] Update routing, DI, or generated code if this story changes those boundaries

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 ⚠️

- [ ] T024 [P] [US3] Add or update widget/unit/flow test coverage in `test/[name]_test.dart`
- [ ] T025 [P] [US3] Add manual validation notes only if automation cannot fully cover the change

### Implementation for User Story 3

- [ ] T026 [P] [US3] Create or update feature models/state holders in `lib/features/[feature]/`
- [ ] T027 [US3] Implement service or integration updates in `lib/features/[feature]/services/`
- [ ] T028 [US3] Implement manager and UI behavior in `lib/features/[feature]/`

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Additional regression coverage in `test/`
- [ ] TXXX Security hardening
- [ ] TXXX Regenerate code and verify generated diffs if applicable
- [ ] TXXX Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Verification tasks MUST be defined before implementation tasks begin
- State holders before service wiring when both are changing
- Services and managers before dependent widgets or pages
- Route, DI, and codegen updates before story sign-off
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All verification tasks for a user story marked [P] can run in parallel
- Models or service changes within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all verification tasks for User Story 1 together:
Task: "Add widget/unit/flow test coverage in test/[name]_test.dart"
Task: "Document manual validation only if automation is incomplete"

# Launch independent implementation tasks for User Story 1 together:
Task: "Update feature models/state holders in lib/features/[feature]/..."
Task: "Update service-layer changes in lib/features/[feature]/services/..."
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and verifiable
- Include route, DI, and codegen tasks whenever those surfaces change
- Stop at each checkpoint to validate the story independently
- Avoid vague tasks, same-file conflicts, and cross-story dependencies that break independence
