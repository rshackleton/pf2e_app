# Implementation Plan: Profile Section Expansion

**Branch**: `002-profile-section` | **Date**: 2026-04-05 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-profile-section/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Build a full profile experience where authenticated users can view and update first name,
last name, and avatar. Profile data is persisted in Supabase and linked to Auth0 identity
using Auth0 `sub` (`user_id`). Profile rows are provisioned during Auth0 registration
via an Auth0 Action, while the Flutter app reads and updates profile rows plus avatar assets
in Supabase Storage. The implementation preserves existing feature-first Flutter architecture,
manager/service boundaries, and route/auth guard behavior.

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable (adjust only if the feature requires a newer pinned version)
**Primary Dependencies**: Flutter, auto_route, get_it, watch_it, command_it, listen_it, plus feature-specific integrations such as Auth0 or Supabase
**Storage**: Supabase Postgres (`public.profiles`) + Supabase Storage (`avatars` bucket)
**Testing**: flutter_test, widget tests, integration-style flow tests, mockito
**Target Platform**: Flutter mobile app (iOS/Android), with shared Dart domain/service logic
**Project Type**: Flutter application
**Performance Goals**: Profile read and initial render within 2s p95 on normal mobile network; avatar upload completion feedback within 5s p95 for typical mobile-sized image
**Constraints**: Must preserve authenticated-only access, use Auth0 `sub` as immutable link key, enforce RLS for profile + storage access, and keep generated route/test artifacts in sync
**Scale/Scope**: Single profile screen enhancement + auth/profile services/managers + Supabase profile/storage integration + Auth0 registration Action contract

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Feature-first placement is defined: update `lib/features/profile/`, `lib/features/auth/`, `lib/locator.dart`, and only shared routing/DI surfaces.
- [x] Manager/service boundaries are explicit: profile manager handles UI/state; auth/profile services handle Auth0/Supabase I/O.
- [x] Verification is explicit: profile flow and auth flow tests updated for view/update/fallback/error/linkage behaviors.
- [x] Navigation, auth, and dependency-scope impact is identified: existing auth guards remain authoritative; profile remains authenticated-only.
- [x] Code generation and dependency impact is identified: `build_runner` rerun required if router/mocks/annotations change.

## Project Structure

### Documentation (this feature)

```text
specs/002-profile-section/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── app.dart
├── locator.dart
├── router.dart
├── router.gr.dart
├── env/
└── features/
    ├── auth/
    │   ├── manager/
    │   ├── services/
    │   └── widgets/
    ├── adventures/
    │   ├── manager/
    │   ├── services/
    │   ├── widgets/
    │   ├── adventures_page.dart
    │   ├── adventure_detail_root_page.dart
    │   ├── adventure_detail_home_page.dart
    │   └── new_adventure_page.dart
    └── profile/
        └── profile_page.dart

test/
├── profile_flow_test.dart
├── auth_flow_test.dart
├── test_helpers.dart
├── test_mocks.dart
└── test_mocks.mocks.dart
```

**Structure Decision**: Keep all profile UX and state in `lib/features/profile/`,
extend auth/profile services/managers under feature folders, and touch `lib/locator.dart`
for registrations. Keep router changes minimal unless new edit route is required.
Regenerate `router.gr.dart` and Mockito outputs only if route signatures or mocked interfaces change.

## Phase 0 Research Output

See [research.md](./research.md). All prior clarifications and integration decisions are resolved with no open ambiguity markers.

## Phase 1 Design Output

- Data model: [data-model.md](./data-model.md)
- Contracts: [contracts/supabase-profile-contract.md](./contracts/supabase-profile-contract.md), [contracts/auth0-registration-action-contract.md](./contracts/auth0-registration-action-contract.md)
- Quickstart: [quickstart.md](./quickstart.md)

## Post-Design Constitution Check

- [x] Feature-first placement remains intact (`lib/features/profile`, `lib/features/auth`, DI/router touchpoints).
- [x] Manager/service boundaries remain explicit and testable.
- [x] Verification plan covers user stories and integration constraints.
- [x] Auth/routing/scope boundaries remain explicit and guarded.
- [x] Code generation impact is identified with rerun criteria.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |

