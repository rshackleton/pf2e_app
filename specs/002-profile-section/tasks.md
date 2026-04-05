# Tasks: Profile Section Expansion

**Input**: Design documents from `/specs/002-profile-section/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Verification tasks are REQUIRED for every behavior-changing story. If no new automated test is added, the task list MUST include the reason and the manual validation steps.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **App code**: `lib/features/`, `lib/app.dart`, `lib/locator.dart`, `lib/router.dart`
- **Generated code**: `lib/router.gr.dart`, `test/test_mocks.mocks.dart`, other generator outputs
- **Tests**: `test/` with relative imports for shared test utilities
- **Infra docs/scripts**: `specs/002-profile-section/`, optional `supabase/migrations/`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and feature scaffolding

- [ ] T001 Create Supabase migration scaffold for profile schema and RLS in supabase/migrations/20260405_profile_schema_and_rls.sql
- [ ] T002 Document Auth0 Action deployment inputs/outputs in specs/002-profile-section/contracts/auth0-registration-action-contract.md
- [ ] T003 [P] Add profile test fixtures for complete and incomplete profile payloads in test/test_helpers.dart

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Apply profile table + RLS migration using SQL from supabase/migrations/20260405_profile_schema_and_rls.sql
- [ ] T005 [P] Add avatar storage bucket and storage policies script in supabase/migrations/20260405_avatar_storage_policies.sql
- [ ] T006 [P] Implement Auth0 registration Action script for profile provisioning in specs/002-profile-section/contracts/auth0-registration-action.js
- [ ] T007 Create profile domain model and state types in lib/features/profile/model/profile_record.dart
- [ ] T008 [P] Add profile service interface and Supabase-backed implementation in lib/features/profile/services/profile_service.dart
- [ ] T009 Implement profile manager command/state orchestration in lib/features/profile/manager/profile_manager.dart
- [ ] T010 Register profile service and manager in lib/locator.dart

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - View Expanded Profile Details (Priority: P1) 🎯 MVP

**Goal**: Signed-in users can view first name, last name, and avatar loaded from their linked Supabase profile

**Independent Test**: Sign in with a user that has a linked profile row and verify first name, last name, and avatar render correctly in profile view

### Tests for User Story 1

- [ ] T011 [P] [US1] Add manager-level profile load tests in test/profile_flow_test.dart
- [ ] T012 [P] [US1] Add authenticated-only profile visibility test in test/auth_flow_test.dart

### Implementation for User Story 1

- [ ] T013 [US1] Implement profile load command and loaded/error states in lib/features/profile/manager/profile_manager.dart
- [ ] T014 [US1] Implement profile fetch mapping (`user_id`, names, avatar reference) in lib/features/profile/services/profile_service.dart
- [ ] T015 [US1] Update profile UI to render first name, last name, and avatar in lib/features/profile/profile_page.dart
- [ ] T016 [US1] Wire profile page to manager state listeners and loading UI in lib/features/profile/profile_page.dart
- [ ] T017 [US1] Ensure auth-guarded access and redirect behavior remains correct in lib/router.dart

**Checkpoint**: User Story 1 is independently functional and testable

---

## Phase 4: User Story 2 - Update Basic Profile Details (Priority: P1)

**Goal**: Signed-in users can update first name, last name, and avatar with persistence to Supabase and Storage

**Independent Test**: Submit valid profile edits and avatar update, then reload profile and verify persisted values are displayed

### Tests for User Story 2

- [ ] T018 [P] [US2] Add profile update success path test in test/profile_flow_test.dart
- [ ] T019 [P] [US2] Add avatar upload reference persistence test in test/profile_flow_test.dart

### Implementation for User Story 2

- [ ] T020 [US2] Implement profile update command with field validation flow in lib/features/profile/manager/profile_manager.dart
- [ ] T021 [US2] Implement partial profile update API call in lib/features/profile/services/profile_service.dart
- [ ] T022 [US2] Implement avatar upload + storage path reference write in lib/features/profile/services/profile_service.dart
- [ ] T023 [US2] Add editable profile form UI and submit handling in lib/features/profile/profile_page.dart
- [ ] T024 [US2] Add save progress and success feedback states in lib/features/profile/profile_page.dart

**Checkpoint**: User Stories 1 and 2 work independently

---

## Phase 5: User Story 3 - Handle Missing Profile Fields Gracefully (Priority: P2)

**Goal**: Profile UI remains usable with missing names/avatar and supports recoverable loading errors

**Independent Test**: Load profile with missing fields and with transient fetch errors to verify fallback UI and retry behavior

### Tests for User Story 3

- [ ] T025 [P] [US3] Add missing-name fallback rendering test in test/profile_flow_test.dart
- [ ] T026 [P] [US3] Add missing-avatar fallback rendering test in test/profile_flow_test.dart
- [ ] T027 [P] [US3] Add recoverable load error and retry test in test/profile_flow_test.dart

### Implementation for User Story 3

- [ ] T028 [US3] Implement fallback value derivation and error messaging in lib/features/profile/manager/profile_manager.dart
- [ ] T029 [US3] Implement profile fallback UI states for missing fields/avatar in lib/features/profile/profile_page.dart
- [ ] T030 [US3] Implement retry action wiring for load failures in lib/features/profile/profile_page.dart

**Checkpoint**: User Stories 1-3 are independently functional

---

## Phase 6: User Story 4 - Keep Profile Data Current After Account Changes (Priority: P3)

**Goal**: Profile reflects latest persisted values across revisit/restart and surfaces integration error when linked profile is unexpectedly missing

**Independent Test**: Change profile externally, revisit profile page, and verify latest values are shown; verify missing-linked-profile path surfaces recoverable guidance

### Tests for User Story 4

- [ ] T031 [P] [US4] Add refresh-on-revisit profile consistency test in test/profile_flow_test.dart
- [ ] T032 [P] [US4] Add missing linked profile integration-error guidance test in test/profile_flow_test.dart

### Implementation for User Story 4

- [ ] T033 [US4] Implement explicit refresh-on-open behavior in lib/features/profile/manager/profile_manager.dart
- [ ] T034 [US4] Implement missing-linked-profile integration error mapping in lib/features/profile/services/profile_service.dart
- [ ] T035 [US4] Add integration error guidance UI in lib/features/profile/profile_page.dart

**Checkpoint**: All user stories are independently functional

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T036 [P] Update profile feature documentation and rollout notes in specs/002-profile-section/quickstart.md
- [ ] T037 Run code generation for router/mocks if needed and commit updated artifacts in lib/router.gr.dart
- [ ] T038 Run full profile/auth verification suite and record outcomes in specs/002-profile-section/checklists/requirements.md
- [ ] T039 Security sanity pass for profile/storage RLS + Auth0 Action assumptions in specs/002-profile-section/research.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 7)**: Depends on all desired user stories being complete

### User Story Dependencies

- **US1 (P1)**: Starts after Foundational
- **US2 (P1)**: Starts after Foundational; depends on shared manager/service foundations only
- **US3 (P2)**: Starts after Foundational; builds on US1 UI/service behaviors
- **US4 (P3)**: Starts after Foundational; builds on refresh and error behaviors from earlier stories

### Within Each User Story

- Verification tasks precede implementation tasks
- Manager/service logic before dependent UI wiring
- Route/DI/codegen updates before story sign-off

### Parallel Opportunities

- Setup tasks marked [P] can run in parallel
- Foundational tasks T005, T006, T008 can run in parallel after T004 starts
- Story test tasks marked [P] can run in parallel
- Different user stories can be worked concurrently after foundational completion if team capacity allows

---

## Parallel Example: User Story 2

```bash
# Parallel verification tasks
Task: "Add profile update success path test in test/profile_flow_test.dart"
Task: "Add avatar upload reference persistence test in test/profile_flow_test.dart"

# Parallelizable implementation tasks on different concerns
Task: "Implement partial profile update API call in lib/features/profile/services/profile_service.dart"
Task: "Implement avatar upload + storage path reference write in lib/features/profile/services/profile_service.dart"
```

---

## Implementation Strategy

### MVP First (US1)

1. Complete Phase 1 and Phase 2
2. Complete Phase 3 (US1)
3. Validate authenticated profile read + rendering behavior
4. Demo MVP

### Incremental Delivery

1. Add US2 for profile editing and avatar updates
2. Add US3 for fallback and recoverable errors
3. Add US4 for refresh consistency and integration-error guidance
4. Finish with Phase 7 hardening and verification

### Parallel Team Strategy

1. One developer on migrations/Auth0 Action (T004-T006)
2. One developer on profile manager/service core (T007-T010)
3. After foundation, split by story track with shared test ownership

---

## Notes

- [P] tasks target distinct files or independent execution surfaces
- Story labels map every story task to explicit user value
- Tasks are specific and immediately actionable for implementation
- Prefer small commits by task or logical task bundle
