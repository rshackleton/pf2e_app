# Research: Security Hardening and Caching Improvements

**Feature**: `003-security-caching-improvements`
**Phase**: 0 – Research
**Date**: 2026-04-06

---

## 1. Image Caching Package

### Decision
Add `cached_network_image: ^3.4.1` as a production dependency.

### Rationale
The app currently uses bare `NetworkImage` (a Flutter built-in) inside `CircleAvatar` in
`ProfileAvatarView`. `NetworkImage` has no disk-persistence layer; every cold start re-fetches
the image. `cached_network_image` wraps `flutter_cache_manager` to provide:
- **Memory cache** – image is reused across widget rebuilds in the same process
- **Disk cache** – image is persisted to the device's local storage across app sessions
- **Configurable TTL** – stale entries are evicted automatically (default 30 days; capped to
  24 h via a custom `CacheManager` config to satisfy FR-002)
- **Cache key control** – the key used for disk storage is the storage *path*, not the
  signed URL (which changes on every signing call), so invalidation on upload (FR-003) works
  correctly by calling `CacheManager.removeFile(key)` with the path
- **Shared cache** – all widgets with the same key share one cached copy (FR-004)

### Alternatives Considered
| Alternative | Why Rejected |
|---|---|
| `flutter_cache_manager` (direct) | Lower-level; `cached_network_image` is the standard Flutter widget that wraps it and is better maintained for display use cases |
| Custom `HttpClient` + file I/O | High implementation effort; reinvents the wheel |
| No new dependency – memory-only via `ResizeImage`/`MemoryImage` | Does not satisfy FR-001 (disk persistence across sessions) |

### Security Check
`cached_network_image 3.4.1` – no known vulnerabilities in the GitHub Advisory Database.

---

## 2. Signed URL Caching Architecture

### Decision
Move signed URL resolution from the widget into `ProfileService`. Add a
`getSignedAvatarUrl(String storagePath)` method backed by an in-memory
`Map<String, _SignedUrlEntry>` cache inside `SupabaseProfileService`.

### Rationale
- The widget (`ProfileAvatarView`) currently calls `createSignedUrl` inside `_resolveAvatarUrl`,
  which is tied to `initState`. Although the existing `didUpdateWidget` guard prevents redundant
  calls *within one widget instance*, it does not prevent duplicate calls when multiple instances
  of `ProfileAvatarView` are on screen simultaneously (violates FR-006).
- Placing the cache in the service keeps the widget dumb (it passes a path; it gets a URL back)
  and lets the cache be shared across all callers, including future widgets.
- `ProfileService` already owns all Supabase storage I/O (upload, delete), so ownership of
  the signing call is natural and consistent with the constitution's "Services Own I/O" principle.
- `ProfileManager` calls `profileService.getSignedAvatarUrl(path)` as part of profile state
  assembly; the result is stored in `ProfileViewState` alongside the profile record.

### Cache Entry Structure
```
_SignedUrlEntry {
  url: String           // the signed URL
  expiresAt: DateTime   // now + 3600 s at creation
}
```

Expiry check: `expiresAt.isBefore(DateTime.now().add(const Duration(minutes: 5)))` → stale
(proactive 5-minute pre-expiry refresh satisfies FR-007).

### Cache Invalidation on Upload
`SupabaseProfileService.updateProfile` already has the `oldAvatarPath` and `newAvatarPath`
values at the time of a successful avatar update. The signed URL cache entry for the old path
is evicted immediately after upload succeeds. The new path gets a fresh entry on the next call.

### Cache Clear on Logout
`ProfileService` exposes a `clearCache()` method. `ProfileManager` calls it when the
`AuthManager.credentials` value becomes `null` (logout event).

---

## 3. In-Session Adventure List Cache

### Decision
Add a `_hasLoaded` boolean flag to `AdventureManager`. The `_getAdventures` body skips the
backend call when `_hasLoaded == true` and returns the current `_adventures.value` immediately.

### Rationale
`AdventureManager` already holds the authoritative list in `_adventures` (a `ValueNotifier`).
Optimistic delete already mutates the list without a re-fetch. Adding a simple loaded flag
gives the cache semantics required by FR-008 at minimal complexity.

### Cache Invalidation
- `_createAdventure`: prepends the new adventure optimistically (already implemented); sets
  `_hasLoaded = true` if it was already true.
- `_deleteAdventure`: removes the adventure optimistically (already implemented).
- `clearSession()`: resets `_hasLoaded = false` and clears `_adventures.value`. Called when
  `AuthManager.credentials` becomes null (logout).

### Alternative Considered
Full reactive cache with a `StreamController` / Supabase realtime subscription. Rejected as
out of scope per spec; in-session cache is sufficient for the current scale.

---

## 4. In-Session Profile Cache

### Decision
`ProfileManager` already stores the loaded profile in `_state.value.profile`. The only change
needed is to skip the `_loadProfile` backend call when `_state.value.loadState == ProfileLoadState.loaded`
AND `_state.value.profile != null`. A `force` parameter or explicit `refresh()` method allows
callers to bypass the cache when a fresh fetch is needed (e.g. on explicit user pull-to-refresh).

### Rationale
The profile is already in state; the manager just needs to honour it rather than always
re-fetching. The existing `refresh()` method can map to a force-reload path.

### Cache Invalidation
- `_updateProfile` already updates `_state.value.profile` with the returned profile (no change needed).
- `clearSession()`: resets state to `ProfileViewState.initial()` and calls
  `profileService.clearCache()`. Called on logout.

---

## 5. Cache Clear on Logout

### Decision
Both `AdventureManager` and `ProfileManager` add a `clearSession()` method. Both managers
subscribe to `AuthManager.credentials` in their initializer and call `clearSession()` when
credentials become `null`.

### Rationale
- No circular dependency is created: both managers already inject `AuthManager` (or can,
  since `ProfileManager` already does).
- The `AdventureManager` currently does not inject `AuthManager`; it will be added.
- This fulfils the spec's constraint: "On logout, all in-session caches MUST be cleared".
- Avoids having `AuthManager` explicitly reference downstream managers.

---

## 6. Adventure Name Length Validation

### Decision
Add a second `validator` branch in `NewAdventurePage`'s `TextFormField` that rejects names
longer than 200 characters.

### Rationale
Profile names already enforce an 80-character limit in `ProfileManager._updateProfile`.
The adventure name limit is enforced at the UI layer (inline `Form` validator) consistent
with the profile name pattern, blocking submission before any network call (FR-011).

---

## 7. Avatar File Type Validation

### Decision
After `ImagePicker.pickImage()` returns, validate the extracted extension against the
allowed set `{jpeg, jpg, png, webp, gif}`. If the extension is not in the allowed set,
set an error state in the widget and return early without updating the selected avatar
bytes (FR-012).

### Rationale
`ImagePicker.pickImage()` restricts the picker UI to images on most platforms, but
the extension can still come back as an unexpected value (e.g. an image-labelled PDF on
some Android devices). Client-side guard before any upload is consistent with the spec's
"rejected with a user-facing error message" requirement. Checking file extension (extracted
from the picker filename) is sufficient for the client-side guard described in the spec.

---

## 8. No New Routes, No Code Generation Changes

No new routes are introduced. `auto_route` regeneration is not required.
`test_mocks.dart` will need `MockProfileService` to expose the new `getSignedAvatarUrl`
method; the mock file is regenerated via `build_runner` after the interface change.
`AdventureService` interface is unchanged.

---

## 9. Platform Scope

`cached_network_image` is supported on all platforms (mobile, web, desktop).
No platform-specific exceptions are needed.
