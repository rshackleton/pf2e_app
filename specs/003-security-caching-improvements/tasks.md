# Tasks: Security Hardening and Caching Improvements

**Input**: Design documents from `/specs/003-security-caching-improvements/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Tests**: Verification tasks are REQUIRED for every behavior-changing story (spec.md explicitly requests automated coverage).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Exact file paths are included in each description

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the new dependency, create foundational new files as stubs, and extend the
`ProfileService` abstract interface. All three tasks are independent and can be done in parallel.

- [x] T001 [P] Add `cached_network_image: ^3.4.1` under `dependencies` in `pubspec.yaml`, then run `flutter pub get` in the project root to fetch the package (including the transitive `flutter_cache_manager` dependency)
- [x] T002 [P] Create `lib/features/profile/services/image_cache_manager.dart` as a stub file: define `class ImageCacheManager extends CacheManager` with a static `const key = 'pf2e_avatar'` and a constructor that calls `super(Config(key))` — full implementation comes in Phase 3
- [x] T003 [P] Add `Future<String?> getSignedAvatarUrl(String? storagePath)` and `void clearCache()` as abstract methods to the `ProfileService` abstract class in `lib/features/profile/services/profile_service.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Restore compilation after the interface change, regenerate test mocks, and
register the new `ImageCacheManager` singleton. **No user story work can begin until this
phase is complete.**

- [x] T004 Add no-op stub implementations of `getSignedAvatarUrl` (returns `null`) and `clearCache` (empty body) to `SupabaseProfileService` in `lib/features/profile/services/profile_service.dart` so the project compiles after T003
- [x] T005 Regenerate `test/test_mocks.mocks.dart` by running `dart run build_runner build --delete-conflicting-outputs` in the project root (required because `ProfileService` gained two new abstract methods in T003; `MockProfileService` must expose them)
- [x] T006 [P] Register `ImageCacheManager` as a singleton in `lib/locator.dart`: `di.registerSingleton(ImageCacheManager())` — place it alongside the other singleton service registrations

**Checkpoint**: Project compiles cleanly, `flutter test` runs without analyzer errors, and `ImageCacheManager` is available in the DI container.

---

## Phase 3: User Story 1 — Fast, Cached Profile Avatar (Priority: P1) 🎯 MVP

**Goal**: Avatar images are served from a local disk cache on subsequent sessions; the old image is evicted immediately when a new avatar is uploaded. Uses `CachedNetworkImage` with a custom 24-hour `ImageCacheManager`.

**Independent Test**: Throttle the device/emulator to "offline" after one successful profile page load. Close and reopen the app. The avatar must appear without any network request.

### Verification for User Story 1

- [x] T007 [P] [US1] Add test cases to `test/profile_flow_test.dart`:
  - `'US1: CachedNetworkImage is rendered when signedAvatarUrl is provided'` — pump `ProfileAvatarView` with a non-null `signedAvatarUrl` and assert that a `CachedNetworkImage` widget is present in the tree
  - `'US1: initials are shown when signedAvatarUrl is null'` — pump `ProfileAvatarView` with `signedAvatarUrl: null`, `firstName: 'Alice'`, `lastName: 'Wonder'`, assert the `Text('AW')` fallback is displayed
- [x] T008 [P] [US1] Document manual validation in `specs/003-security-caching-improvements/quickstart.md` under the existing manual checklist: confirm the "offline after first load" scenario maps to FR-001 and note that the image cache key is the avatar storage path (not the signed URL)

### Implementation for User Story 1

- [x] T009 [US1] Implement `ImageCacheManager` in `lib/features/profile/services/image_cache_manager.dart`: configure `Config(key, stalePeriod: const Duration(hours: 24), maxNrOfCacheObjects: 100)` — replaces the stub from T002
- [x] T010 [US1] Update `SupabaseProfileService.updateProfile` in `lib/features/profile/services/profile_service.dart`: after a successful avatar upload and before returning, call `di<ImageCacheManager>().removeFile(oldAvatarPath)` when `oldAvatarPath != null` (FR-003 cache invalidation); import `ImageCacheManager` and `locator.dart`
- [x] T011 [US1] Convert `ProfileAvatarView` in `lib/features/profile/widgets/profile_avatar_view.dart` from `StatefulWidget` to `StatelessWidget`; replace the `FutureBuilder<String?>`/`NetworkImage` pair with `CachedNetworkImage(imageUrl: signedAvatarUrl!, cacheManager: di<ImageCacheManager>(), cacheKey: avatarPath)` for the image branch; add a required `String? signedAvatarUrl` parameter; keep the `avatarPath`, `firstName`, `lastName`, and `radius` parameters; keep the initials/icon fallback for when `signedAvatarUrl` is null
- [x] T012 [US1] Update all call sites of `ProfileAvatarView` in `lib/features/profile/profile_page.dart` to pass `signedAvatarUrl` — for now pass the raw `avatarPath` value from the profile state as `signedAvatarUrl` (signed URL resolution from the service is wired in US3; this temporary pass-through keeps the feature shippable at P1 without the full signed URL cache)

**Checkpoint**: User Story 1 is independently functional. Avatar shows from disk on revisit. Upload clears the cached image. `flutter test` passes.

---

## Phase 4: User Story 2 — Deduplicated and Cached Data Reads (Priority: P2)

**Goal**: Adventures list and profile data are served from in-session caches after the first load. Navigating away and back produces no new backend reads. All caches are cleared on logout.

**Independent Test**: Load the adventures list, disable network, navigate away and back — the list must display immediately with no loading indicator.

### Verification for User Story 2

- [x] T013 [P] [US2] Add test cases to `test/adventure_flow_test.dart` for `AdventureManager`:
  - `'US2: second getAdventuresCommand invocation skips backend when already loaded'` — call `getAdventuresCommand` twice; verify the mock `AdventureService.getAdventures` was called exactly once
  - `'US2: clearSession resets _hasLoaded and empties the adventures list'` — call `getAdventuresCommand`, then `clearSession()`; verify `adventures.value` is empty and the next `getAdventuresCommand` call fetches from the backend again
  - `'US2: createAdventure prepends to list without resetting hasLoaded'` — seed adventures, call `createAdventureCommand`, then `getAdventuresCommand`; verify backend was only called once total
- [x] T014 [P] [US2] Add test cases to `test/profile_flow_test.dart` for `ProfileManager`:
  - `'US2: second loadProfileCommand skips backend when profile already loaded'` — call `loadProfileCommand` twice; verify `MockProfileService.getProfile` was called exactly once
  - `'US2: clearSession resets state to initial and calls profileService.clearCache'` — call `loadProfileCommand`, then `clearSession()`; verify state returns to `ProfileLoadState.idle` and `clearCache` was invoked on the mock

### Implementation for User Story 2

- [x] T015 [US2] Update `AdventureManager` in `lib/features/adventures/manager/adventure_manager.dart`:
  - Add `bool _hasLoaded = false` field
  - In `_getAdventures`: add early return `if (_hasLoaded) return;` at the top; set `_hasLoaded = true` after successfully populating `_adventures.value`
  - Add `void clearSession()` method: sets `_adventures.value = []` and `_hasLoaded = false`
  - Inject `final _authManager = di<AuthManager>();` and add a listener in the constructor that calls `clearSession()` when `_authManager.credentials.value` becomes `null`; remove the listener in `dispose()`
  - Add `AuthManager` import
- [x] T016 [US2] Update `ProfileManager` in `lib/features/profile/manager/profile_manager.dart`:
  - In `_loadProfile`: add guard `if (_state.value.loadState == ProfileLoadState.loaded && _state.value.profile != null) return;` before the userId check
  - Add `void clearSession()` method: sets `_state.value = const ProfileViewState.initial()` and calls `_profileService.clearCache()`
  - Add a listener on `_authManager.credentials` (already injected) that calls `clearSession()` when credentials become `null`; remove the listener in `dispose()`
  - Update `refresh()` to bypass the cache guard — it must force a fresh fetch (change it to a dedicated private `_forceLoad()` or add a `force` boolean to `_loadProfile`)

**Checkpoint**: User Stories 1 AND 2 are independently functional. `flutter test` passes.

---

## Phase 5: User Story 3 — Reliable Signed URL Reuse (Priority: P2)

**Goal**: The Supabase signing endpoint is called at most once per session per avatar storage path. The resolved URL is cached in `ProfileService`, stored in `ProfileViewState`, and passed directly to `ProfileAvatarView` so no widget makes a second signing call.

**Independent Test**: Monitor Supabase network traffic during a session with multiple avatar widget rebuilds — `createSignedUrl` must appear at most once in the log.

### Verification for User Story 3

- [x] T017 [P] [US3] Add test cases to `test/profile_flow_test.dart` for `SupabaseProfileService` signed URL cache (use a test double or subclass to intercept `createSignedUrl` calls):
  - `'US3: getSignedAvatarUrl returns null for null or empty path'`
  - `'US3: getSignedAvatarUrl returns cached URL on second call without re-signing'` — call twice, assert signing called once
  - `'US3: getSignedAvatarUrl proactively refreshes a stale entry (within 5 min of expiry)'` — seed the cache with an entry whose `expiresAt` is 4 minutes from now; call `getSignedAvatarUrl`; assert signing was called again
  - `'US3: clearCache empties the signed URL cache'` — prime the cache, call `clearCache()`, then call `getSignedAvatarUrl`; assert signing was called twice total

### Implementation for User Story 3

- [x] T018 [US3] Add the `_SignedUrlEntry` private class to `lib/features/profile/services/profile_service.dart` (fields: `final String url`, `final DateTime expiresAt`; getter `bool get isStale => expiresAt.isBefore(DateTime.now().add(const Duration(minutes: 5)))`)
- [x] T019 [US3] Implement `getSignedAvatarUrl` in `SupabaseProfileService` in `lib/features/profile/services/profile_service.dart`: if `storagePath` is null or empty return `null`; normalize the path (strip leading `/`); check `_signedUrlCache[path]`; if present and not stale return `entry.url`; otherwise call `createSignedUrl(path, 3600)`, create a new `_SignedUrlEntry`, store in map, return the URL; catch and return `null` on error
- [x] T020 [US3] Implement `clearCache()` in `SupabaseProfileService` in `lib/features/profile/services/profile_service.dart`: call `_signedUrlCache.clear()` (replacing the no-op stub from T004)
- [x] T021 [US3] Add `signedAvatarUrl` field to `ProfileViewState` in `lib/features/profile/model/profile_record.dart`: `final String? signedAvatarUrl;`; update the constructor, `copyWith`, and `ProfileViewState.initial()` (sets `signedAvatarUrl: null`)
- [x] T022 [US3] Update `ProfileManager._loadProfile` and `_updateProfile` in `lib/features/profile/manager/profile_manager.dart`: after loading the profile record, call `final url = await _profileService.getSignedAvatarUrl(profile.avatarPath)` and include `signedAvatarUrl: url` in the `copyWith` call that sets `loadState: ProfileLoadState.loaded`; repeat for the `_updateProfile` success path
- [x] T023 [US3] Update `ProfilePage` in `lib/features/profile/profile_page.dart` to read `signedAvatarUrl` from `ProfileViewState` and pass it to `ProfileAvatarView` — replacing the temporary pass-through from T012

**Checkpoint**: User Stories 1, 2, AND 3 are independently functional. `ProfileAvatarView` no longer calls any Supabase API directly. `flutter test` passes.

---

## Phase 6: User Story 4 — Adventure Name Length Validation (Priority: P3)

**Goal**: The new adventure form rejects names longer than 200 characters with an inline error, consistent with profile name validation elsewhere in the app.

**Independent Test**: Enter a 201-character name on the new adventure form and tap Create — the form must show an error and not submit.

### Verification for User Story 4

- [x] T024 [P] [US4] Add test cases to `test/adventure_flow_test.dart`:
  - `'US4: name exceeding 200 characters fails form validation'` — build `NewAdventurePage`, enter a 201-char string, tap Create, assert error text `'Adventure name must be 200 characters or fewer.'` is visible
  - `'US4: name at exactly 200 characters passes validation'` — enter a 200-char string, tap Create, assert no length error text is shown
  - `'US4: empty name still triggers the existing non-empty validator'` — leave field empty, tap Create, assert `'Please enter the adventure name.'` is visible

### Implementation for User Story 4

- [x] T025 [US4] Add a second condition branch to the `validator` function of the `TextFormField` in `lib/features/adventures/new_adventure_page.dart`: after the empty check, add `if (value.length > 200) return 'Adventure name must be 200 characters or fewer.';`

**Checkpoint**: Adventure name validation is complete. `flutter test` passes.

---

## Phase 7: User Story 5 — Avatar File Type Validation (Priority: P3)

**Goal**: Selecting a non-image file as an avatar shows a clear error message and prevents any upload from starting.

**Independent Test**: Attempt to set an avatar with a `.pdf` extension — the app must display an error and `ProfileService.updateProfile` must not be called.

### Verification for User Story 5

- [x] T026 [P] [US5] Add test cases to `test/profile_flow_test.dart`:
  - `'US5: unsupported file extension shows error and does not set selected bytes'` — simulate picker returning a file named `doc.pdf`; assert error state or SnackBar is shown and `_selectedAvatarBytes` remains null
  - `'US5: supported extensions (jpeg, jpg, png, webp, gif) proceed without error'` — simulate picker returning `photo.png`; assert no error and bytes are set

### Implementation for User Story 5

- [x] T027 [US5] Add a file-type guard to the image picker callback in `lib/features/profile/profile_page.dart`: after extracting the `extension` from `picked.name`, check `const _allowedExtensions = {'jpeg', 'jpg', 'png', 'webp', 'gif'}; if (!_allowedExtensions.contains(extension))` then show a `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unsupported file type. Please select a JPEG, PNG, WebP, or GIF image.')))` and `return` without calling `setState`

**Checkpoint**: All 5 user stories are independently functional. `flutter test` passes.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [ ] T028 [P] Run the full test suite with `flutter test` and fix any regressions introduced across all phases
- [ ] T029 [P] Run `flutter analyze` and resolve any new warnings or hints in the changed files
- [ ] T030 Run the manual validation checklist from `specs/003-security-caching-improvements/quickstart.md` (offline avatar, offline adventures list, name length rejection, file-type rejection, logout data isolation)
- [ ] T031 Confirm `test/test_mocks.mocks.dart` is up to date: run `dart run build_runner build --delete-conflicting-outputs` one final time and commit the output if it differs

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately; all three tasks are parallel
- **Foundational (Phase 2)**: Depends on Phase 1 completion — **BLOCKS all user stories**
- **User Stories (Phases 3–7)**: All depend on Phase 2 completion; can proceed in priority order or in parallel if staffed
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

| Story | Depends On | Notes |
|---|---|---|
| US1 (P1) | Phase 2 complete | No story dependencies |
| US2 (P2) | Phase 2 complete | No story dependencies; independent of US1 |
| US3 (P2) | US1 complete (T011) | US3 finalises `ProfileAvatarView`; builds on T009/T011; T012 is a known temporary bridge |
| US4 (P3) | Phase 2 complete | Fully independent — touches only `new_adventure_page.dart` |
| US5 (P3) | Phase 2 complete | Fully independent — touches only `profile_page.dart` |

### Within Each User Story

- Verification tasks (marked [P]) are defined alongside implementation, not after
- State/model changes before service wiring before widget changes
- Story sign-off requires: code complete + tests green + manual notes updated

---

## Parallel Opportunities

### Phase 1 (all parallel)
```
Task T001: pubspec.yaml + flutter pub get
Task T002: image_cache_manager.dart stub
Task T003: ProfileService interface update
```

### Phase 2 (T004 → T005 sequential; T006 parallel after T002)
```
T004: SupabaseProfileService stubs (needs T003)
  └─ T005: build_runner mocks regeneration (needs T004)
T006: locator.dart registration (needs T002, parallel with T004/T005)
```

### After Phase 2: User Stories in parallel
```
Developer A: US1 (T007–T012) → US3 (T017–T023) [sequential: US3 builds on US1]
Developer B: US2 (T013–T016)
Developer C: US4 (T024–T025) + US5 (T026–T027) [both tiny; same developer]
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (**CRITICAL** — blocks all stories)
3. Complete Phase 3: User Story 1 (T007–T012)
4. **STOP and VALIDATE**: disk cache hit after offline restart; upload clears cache
5. Demo / ship US1 independently

### Incremental Delivery

1. Setup + Foundational → foundation ready
2. + US1 (P1) → avatar disk cache live → **MVP demo**
3. + US2 (P2) → no redundant data reads within session
4. + US3 (P2) → signed URL deduplication; `ProfileAvatarView` fully simplified
5. + US4 + US5 (P3) → input validation hardening
6. Polish → final test run + manual checklist

---

## Summary

| Phase | Stories | Tasks | Parallel |
|---|---|---|---|
| Phase 1: Setup | — | T001–T003 | All 3 |
| Phase 2: Foundational | — | T004–T006 | T006 only |
| Phase 3: US1 (P1) | FR-001–004 | T007–T012 | T007, T008 |
| Phase 4: US2 (P2) | FR-008–010 | T013–T016 | T013, T014 |
| Phase 5: US3 (P2) | FR-005–007 | T017–T023 | T017 |
| Phase 6: US4 (P3) | FR-011 | T024–T025 | T024 |
| Phase 7: US5 (P3) | FR-012 | T026–T027 | T026 |
| Phase 8: Polish | — | T028–T031 | T028, T029 |
| **Total** | **5 stories** | **31 tasks** | **12 parallel** |
