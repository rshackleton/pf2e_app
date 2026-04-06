# Interface Contract: `AdventureManager` – Session Cache

**Feature**: `003-security-caching-improvements`
**File**: `lib/features/adventures/manager/adventure_manager.dart`
**Change type**: Behavioural change (in-session cache) + new `clearSession()` method.

---

## New Public Method

```dart
/// Clears the in-session adventure list cache and resets loaded state.
///
/// Called automatically when [AuthManager.credentials] becomes null (logout).
/// After this call, the next invocation of [getAdventuresCommand] will fetch
/// from the backend as if the session were fresh (FR-008).
void clearSession();
```

## Behavioural Contract

| Scenario | Before change | After change |
|---|---|---|
| `getAdventuresCommand` called for the first time | Fetches from backend | Fetches from backend (unchanged) |
| `getAdventuresCommand` called again within same session | Fetches from backend again | Returns immediately; `_adventures.value` unchanged (cache hit) |
| `createAdventureCommand` completes successfully | Prepends to list | Same; `_hasLoaded` remains `true` |
| `deleteAdventureCommand` completes successfully | Removes from list | Same; `_hasLoaded` remains `true` |
| `clearSession()` called | N/A | `_adventures.value = []`; `_hasLoaded = false` |
| User logs out (credentials → null) | No action in manager | `clearSession()` called automatically |

## New Dependency

`AdventureManager` will inject `AuthManager` (via `di<AuthManager>()`) to observe the
`credentials` `ValueListenable`. No circular dependency is introduced.
`AuthManager` does not reference `AdventureManager`.

---
