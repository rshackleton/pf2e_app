# Quickstart: Security Hardening and Caching Improvements

**Feature**: `003-security-caching-improvements`
**Date**: 2026-04-06

---

## What is being built

Five targeted improvements to the PF2e app:

1. **Disk + memory avatar caching** – profile avatar images are cached to device storage so
   they appear instantly on revisit, even after a cold start.
2. **Signed URL caching** – the Supabase signing endpoint is called at most once per session
   per avatar path, not on every widget build.
3. **In-session adventure list cache** – navigating away from and back to the adventures list
   does not trigger a new backend read.
4. **In-session profile cache** – any part of the app that needs profile data in the same
   session reads from the cached copy rather than re-fetching.
5. **Input validation** – adventure name limited to 200 characters; avatar file type validated
   before upload.

All caches are cleared on logout.

---

## New dependency

`cached_network_image: ^3.4.1` (production dependency).
Add to `pubspec.yaml`, then run:

```bash
flutter pub get
```

---

## Key design decisions

| Decision | Rationale |
|---|---|
| Image cache key = storage *path*, not signed URL | Signed URLs rotate on expiry; using the path keeps the disk cache valid across URL refreshes |
| `ProfileService` owns signed URL cache | Services own I/O; caching a network response is part of the service's responsibility |
| `_hasLoaded` flag in `AdventureManager` | Adventures list is already in `_adventures.value`; a boolean flag is the minimal change needed |
| Profile cache skip when `loadState == loaded` | Profile state already contains the profile record; skipping re-fetch is a one-line guard |
| Logout clear via `AuthManager.credentials` listener | Avoids `AuthManager` coupling to downstream managers; managers self-clear when they observe credentials going null |

---

## Running tests

```bash
# Regenerate mocks after ProfileService interface change
dart run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test
```

---

## Manual validation checklist

- [ ] Load adventures list → disconnect network → navigate away and back → list still displays
- [ ] Load profile page → note avatar → navigate away and back → avatar appears without loading spinner
- [ ] Submit new adventure with a name > 200 characters → form rejects with inline error
- [ ] Submit new adventure with exactly 200 characters → succeeds
- [ ] Attempt to set avatar with a non-image extension (e.g. `.pdf`) → app shows error, no upload
- [ ] Log out → log in as a different user → no data from previous session visible

### FR-001 offline avatar verification (US1)

After one successful profile page load with avatar visible:
1. Enable airplane mode / set network to offline
2. Restart (or re-launch) the app — do **not** clear app data
3. Navigate to the profile page
4. The avatar MUST display immediately from disk cache, with **no** network request visible in the device proxy log

**Image cache key note**: The disk cache key is the avatar *storage path* (e.g. `users_abc123/1234567890.png`), NOT the signed URL. This means:
- The disk cache remains valid when the signed URL rotates on expiry (FR-005/FR-007)
- Invalidation on upload (`updateProfile`) removes the entry by storage path via `ImageCacheManager.removeFile(path)` (FR-003)

