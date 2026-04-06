# Data Model: Security Hardening and Caching Improvements

**Feature**: `003-security-caching-improvements`
**Phase**: 1 – Design
**Date**: 2026-04-06

---

## 1. `_SignedUrlEntry` (private, `SupabaseProfileService`)

An in-memory value object representing a cached signed URL.

| Field | Type | Description |
|---|---|---|
| `url` | `String` | The signed Supabase storage URL returned by `createSignedUrl` |
| `expiresAt` | `DateTime` | UTC timestamp at which the URL expires (`DateTime.now().add(const Duration(seconds: 3600))`) |

**Behaviour**:
- `isStale`: `true` when `expiresAt.isBefore(DateTime.now().add(const Duration(minutes: 5)))` – triggers proactive background refresh (FR-007)
- Entries are keyed by `storagePath` (the relative path stored in `profiles.avatar_path`)
- The full cache is cleared on `clearCache()` (logout path)

**Not persisted**: lives only in the `SupabaseProfileService` singleton instance.

---

## 2. `ProfileViewState` (extended)

Existing class in `lib/features/profile/model/profile_record.dart`. Extended with one additional optional field:

| Field | Type | Description |
|---|---|---|
| `signedAvatarUrl` | `String?` | The resolved and cached signed URL for the current user's avatar, or `null` if no avatar or not yet resolved |

**Transitions**:
- Set to the resolved URL when profile is successfully loaded (`ProfileLoadState.loaded`)
- Cleared to `null` when `clearSession()` is called
- Cleared to `null` when avatar path changes (new avatar upload begins)
- Set to new URL when avatar upload completes successfully

---

## 3. `AdventureManager` – session cache state

No new model; flag added to existing manager:

| Field | Type | Description |
|---|---|---|
| `_hasLoaded` | `bool` | `true` once `_getAdventures` has completed at least once in this session |

**Rules**:
- `_getAdventures` is a no-op (returns immediately) when `_hasLoaded == true`
- `_hasLoaded` is reset to `false` in `clearSession()`
- Create and delete operations do NOT reset `_hasLoaded`; they mutate `_adventures.value` directly (already implemented for delete; create already prepends)

---

## 4. `ImageCacheManager` (new singleton, `lib/features/profile/services/`)

A custom `CacheManager` configuration that overrides the default TTL and cache key logic.

| Property | Value |
|---|---|
| Cache key prefix | `pf2e_avatar_` |
| Staleness TTL | 24 hours (FR-002) |
| Max cache objects | 100 (reasonable upper bound for user avatars) |
| Underlying library | `flutter_cache_manager` (transitive via `cached_network_image`) |

**Usage**: `CachedNetworkImage` widget accepts a `cacheManager` argument. The
`ImageCacheManager` singleton is registered in `locator.dart` and injected via `di<ImageCacheManager>()`.

**Cache key**: The storage *path* (not the signed URL) is used as the cache key so that
the disk-cached image survives signed URL rotation (FR-003 invalidation by path).

**Invalidation on upload**: After a successful avatar upload, `ProfileService.updateProfile`
calls `ImageCacheManager.removeFile(oldAvatarPath)` before returning (FR-003).

---

## 5. Validation Rules (no new model)

The following validation rules are implemented as inline `validator` functions or guard
conditions. No new model classes are required.

| Rule | Location | Condition | Error message |
|---|---|---|---|
| Adventure name max length | `NewAdventurePage` `TextFormField.validator` | `value.length > 200` | `'Adventure name must be 200 characters or fewer.'` |
| Avatar file type | `ProfilePage` image picker callback | `extension` not in `{jpeg, jpg, png, webp, gif}` | `'Unsupported file type. Please select a JPEG, PNG, WebP, or GIF image.'` |

---

## 6. Entity Relationships

```
AuthManager.credentials (ValueNotifier<Credentials?>)
  └─ [null on logout] → AdventureManager.clearSession()
                      → ProfileManager.clearSession()
                            └─ ProfileService.clearCache()
                                  └─ clears _signedUrlCache (Map<String, _SignedUrlEntry>)
                            └─ ImageCacheManager (not cleared on logout; disk cache is not
                               user-specific data — it's publicly-accessible signed URLs)

ProfileService.getSignedAvatarUrl(storagePath)
  ├─ cache hit (not stale) → returns cached url immediately
  ├─ cache hit (stale) → fetches new URL, updates cache, returns new url
  └─ cache miss → fetches URL, stores in cache, returns url

ProfileManager._loadProfile()
  ├─ _state.loadState == loaded && profile != null → skip backend call (cache hit)
  └─ otherwise → calls profileService.getProfile() + getSignedAvatarUrl()

AdventureManager._getAdventures()
  ├─ _hasLoaded == true → no-op (cache hit)
  └─ _hasLoaded == false → fetches from backend, sets _hasLoaded = true
```
