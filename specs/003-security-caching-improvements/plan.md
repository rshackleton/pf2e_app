# Implementation Plan: Security Hardening and Caching Improvements

**Branch**: `003-security-caching-improvements` | **Date**: 2026-04-06 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-security-caching-improvements/spec.md`

## Summary

Five targeted improvements: (1) add `cached_network_image` for disk+memory avatar caching,
(2) move signed URL resolution into `ProfileService` with an in-memory TTL cache shared
across all widgets, (3) add `_hasLoaded` flags to `AdventureManager` and `ProfileManager`
to eliminate redundant backend reads within a session, (4) clear all caches on logout by
having managers observe `AuthManager.credentials`, (5) add a 200-character max-length
validation to the adventure name form field and a file-type guard before avatar upload.

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable
**Primary Dependencies**: Flutter, auto_route, get_it, watch_it, command_it, listen_it,
  supabase_flutter, image_picker, **cached_network_image ^3.4.1 (new)**
**Storage**: Supabase (remote); device local storage via `flutter_cache_manager` (disk image cache)
**Testing**: flutter_test, widget tests, integration-style flow tests, mockito; `build_runner`
  regeneration required after `ProfileService` interface change
**Target Platform**: Flutter mobile (primary); `cached_network_image` supports web and
  desktop with no additional configuration
**Performance Goals**: Avatar display without network round-trip on revisit (< 100 ms);
  adventure list display from cache on navigation back (< 50 ms)
**Constraints**: Authenticated flows; signed URL expiry 3600 s; caches are in-session only
  (except disk image cache which persists across sessions with 24 h TTL); no new routes
**Scale/Scope**: 3 features touched (`adventures`, `profile`, `auth`); 6 files changed in
  production code; 3 test files updated; 1 new production file (`image_cache_manager.dart`)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Feature-first placement**: All production changes are in `lib/features/adventures/`,
  `lib/features/profile/`, `lib/locator.dart`. The new `ImageCacheManager` config lives in
  `lib/features/profile/services/` (only the profile feature uses it; shared placement is
  not yet warranted). No cross-feature shared module is created.
- [x] **Manager/service boundaries**: `AdventureManager` and `ProfileManager` own session
  cache state (flags + `clearSession()`). `ProfileService` owns signed URL I/O and its cache.
  `ImageCacheManager` owns disk cache configuration. DI registrations stay in `locator.dart`.
- [x] **Verification**: Unit tests named in this plan for each cache layer (hit, miss,
  invalidation, logout clear). Widget test for `ProfileAvatarView` signed-URL call count.
  Validator unit tests for adventure name length and avatar file type. Manual validation
  steps noted in the spec for offline scenarios.
- [x] **Navigation/auth impact**: No new routes. Logout cache clearing implemented via
  `AuthManager.credentials` observation in both managers — no guard changes.
- [x] **Code generation**: `ProfileService` abstract interface gains two methods →
  `build_runner` regeneration of `test_mocks.mocks.dart` is required. No route regeneration.
  `cached_network_image ^3.4.1` added to `pubspec.yaml`; security advisory check passed
  (no known vulnerabilities). `flutter_cache_manager` pulled in transitively.

**Post-design re-check**: All checks remain green. No constitution violations.

## Project Structure

### Documentation (this feature)

```text
specs/003-security-caching-improvements/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   ├── profile-service.md
│   └── adventure-manager.md
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
lib/
├── locator.dart                          # Register ImageCacheManager singleton
└── features/
    ├── adventures/
    │   ├── manager/
    │   │   └── adventure_manager.dart    # Add _hasLoaded flag + clearSession(); inject AuthManager
    │   └── new_adventure_page.dart       # Add 200-char max-length validator
    └── profile/
        ├── manager/
        │   └── profile_manager.dart      # Add profile cache skip; clearSession(); call service.clearCache()
        ├── services/
        │   ├── profile_service.dart      # Add getSignedAvatarUrl + clearCache to interface + impl
        │   └── image_cache_manager.dart  # New: custom CacheManager config (24 h TTL)
        ├── profile_page.dart             # Add avatar file-type validation before setState
        └── widgets/
            └── profile_avatar_view.dart  # Replace NetworkImage with CachedNetworkImage; remove signing logic

pubspec.yaml                              # Add cached_network_image ^3.4.1

test/
├── adventure_flow_test.dart              # Add cache hit / clearSession tests
├── profile_flow_test.dart                # Add signed URL cache + profile cache hit tests
├── test_mocks.dart                       # Add stubs for new ProfileService methods
└── test_mocks.mocks.dart                 # Regenerated via build_runner
```

**Structure Decision**: All changes are feature-local. `ImageCacheManager` is placed in
`lib/features/profile/services/` because it is exclusively consumed by the profile feature.
If a second feature ever displays user-generated images, it should be moved to a shared
location at that time (constitution Principle I).

## Complexity Tracking

> **No constitution violations.** This section is intentionally empty.
