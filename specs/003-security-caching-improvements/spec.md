# Feature Specification: Security Hardening and Caching Improvements

**Feature Branch**: `003-security-caching-improvements`
**Created**: 2026-04-06
**Status**: Draft
**Input**: Code review with recommendations around security and caching; reduce direct backend data calls and add image caching.

## Background

A code review of the Flutter PF2e app identified two improvement areas:

1. **Security gaps** – minor input validation inconsistencies and missing file-type guards that should be addressed before the user base grows.
2. **Performance / caching** – every screen navigation triggers fresh network requests; profile avatars are loaded fresh on every render with no local disk or memory caching; signed URLs are regenerated on every widget build.

Addressing these areas will make the app more responsive for users on slow or intermittent connections and reduce unnecessary load on the backend data service.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Fast, Cached Profile Avatar (Priority: P1)

A user opens the app, navigates to their profile, and their avatar appears immediately—even before the network responds—because it was cached from the previous session. Subsequent views of the avatar within the same session reuse the cached version without any additional network activity.

**Why this priority**: Avatar loading is visible on the very first screen a logged-in user sees. Eliminating the visible loading flicker is the highest-impact perceived-performance improvement available.

**Independent Test**: Can be tested independently by opening the profile page with network throttled to "offline" after one prior successful load. The avatar must still display correctly.

**Acceptance Scenarios**:

1. **Given** a user has previously loaded their profile avatar, **When** they navigate to the profile page on a subsequent app session, **Then** the avatar is shown without a network request (served from local cache).
2. **Given** a user views their avatar multiple times in a single session, **When** the widget is rebuilt (e.g., screen rotation, navigation back), **Then** no additional network requests are made for the same image URL.
3. **Given** a user uploads a new avatar, **When** the upload succeeds, **Then** the cache is invalidated and the new avatar is shown immediately.
4. **Given** the cached image is stale (older than the configured TTL), **When** the user opens the profile page, **Then** the app re-fetches the image in the background and updates the display once available.

---

### User Story 2 - Deduplicated and Cached Data Reads (Priority: P2)

A user navigates between screens repeatedly within a session (e.g., adventures list → adventure detail → back → adventures list). Data that has not changed since the last fetch is served from an in-session cache rather than re-fetched from the backend, making transitions feel instant.

**Why this priority**: Repeated navigation is the most common usage pattern in the app. Reducing redundant data fetches directly improves perceived speed and lowers backend load.

**Independent Test**: Can be tested by navigating away from and back to the adventures list page with network disabled. The previously loaded list must still display.

**Acceptance Scenarios**:

1. **Given** the adventures list has been loaded once, **When** the user navigates away and returns within the same session, **Then** the list is displayed immediately from the in-session cache without a visible loading indicator.
2. **Given** the profile data has been loaded once, **When** any feature in the app needs to read the current user's profile, **Then** the cached value is used rather than triggering a new backend read.
3. **Given** the user creates or deletes an adventure, **When** the operation completes successfully, **Then** the in-session cache is updated so the changes are reflected without a full re-fetch.
4. **Given** the app is freshly launched (cold start), **When** the adventures list is opened for the first time, **Then** data is fetched from the backend as normal.

---

### User Story 3 - Reliable Signed URL Reuse (Priority: P2)

A user's avatar signed URL is resolved once per session (or until close to expiry) and reused across all parts of the app that display the avatar. The URL is not regenerated on every widget rebuild.

**Why this priority**: The profile avatar widget currently calls the storage signing endpoint on every build, creating unnecessary backend API calls and slowing down UI updates.

**Independent Test**: Can be tested by monitoring network traffic while navigating in the app—the signing endpoint should be called at most once per session per avatar, not on every widget render.

**Acceptance Scenarios**:

1. **Given** a user has a profile avatar, **When** the profile avatar widget is built or rebuilt multiple times in a session, **Then** the signed URL is fetched from the backend at most once per session (or once before expiry).
2. **Given** a signed URL is cached and the user stays in the app past its expiry window, **When** the avatar widget renders after expiry, **Then** a new signed URL is fetched and cached transparently.
3. **Given** a user has no avatar set, **When** the avatar widget renders, **Then** no signing request is made.

---

### User Story 4 - Adventure Name Length Validation (Priority: P3)

A user creating a new adventure is prevented from submitting a name that is unreasonably long, receiving a clear error message explaining the limit, consistent with how profile name fields are validated elsewhere in the app.

**Why this priority**: This is a minor security hardening item—other fields already enforce length limits; adventures do not. It is low-risk and low-effort but important for consistency.

**Independent Test**: Can be tested by entering a name longer than 200 characters on the new adventure form and submitting it. The form must reject the input with an error message.

**Acceptance Scenarios**:

1. **Given** the new adventure form is open, **When** the user enters a name longer than 200 characters and attempts to save, **Then** the form displays an inline error and submission is blocked.
2. **Given** a name exactly at the limit (200 characters), **When** the user submits, **Then** the adventure is created successfully.
3. **Given** an empty adventure name, **When** the user attempts to save, **Then** the existing validation (non-empty check) still triggers as before.

---

### User Story 5 - Avatar File Type Validation (Priority: P3)

A user attempting to upload a non-image file as a profile avatar is shown a clear error message rather than having the file silently rejected or uploaded incorrectly.

**Why this priority**: The image picker currently does not enforce file type after selection. Although unlikely in normal use, an invalid file could reach the backend. This is a minor defensive hardening item.

**Independent Test**: Can be tested by attempting to upload a PDF or other non-image file as an avatar. The app must display an error before attempting the upload.

**Acceptance Scenarios**:

1. **Given** a user selects a file that is not a supported image type (JPEG, PNG, WebP, GIF), **When** the upload is initiated, **Then** an error message is shown and no upload request is sent.
2. **Given** a user selects a valid image file, **When** the upload is initiated, **Then** behaviour is unchanged from today.

---

### Edge Cases

- What happens when the local image cache is full? The oldest cached entries are evicted automatically; no user action required.
- What happens when a cached signed URL expires while the user has the app open? The system transparently fetches a new URL in the background; the user sees no error.
- What happens when the app is updated and cached data schemas change? In-session caches are reset on cold start; no persisted cache data is carried between app versions in this implementation.
- What happens if avatar upload succeeds but the profile record update fails? The existing rollback mechanism (deleting the uploaded avatar file) continues to work correctly alongside any new caching layer.
- What happens when the user is offline and no cache exists? The app displays an appropriate empty/error state, consistent with current behaviour.
- What happens when two instances of the avatar widget exist on screen simultaneously? Both must share the same cached signed URL rather than issuing duplicate requests.

---

## Requirements *(mandatory)*

### Functional Requirements

**Image Caching**

- **FR-001**: The app MUST cache profile avatar images on disk so that previously loaded avatars are available without a network request on subsequent sessions.
- **FR-002**: The image cache MUST support a configurable time-to-live (TTL), defaulting to 24 hours.
- **FR-003**: When a user uploads a new avatar, the system MUST invalidate the cached image for that user so the new avatar is displayed immediately.
- **FR-004**: The image cache MUST be shared across all widgets that display the same avatar URL within a session.

**Signed URL Management**

- **FR-005**: The app MUST cache the signed URL for a user's avatar in memory for the duration of its validity (up to the URL's expiry time).
- **FR-006**: The system MUST NOT call the URL-signing endpoint more than once per session per user unless the URL has expired or a new avatar has been uploaded.
- **FR-007**: When a signed URL is close to expiry (within 5 minutes), the system MUST proactively refresh it in the background before the current one expires.

**In-Session Data Caching**

- **FR-008**: The adventures list MUST be cached in memory after the first load within a session; navigating away from and back to the list MUST NOT trigger a new backend read unless data has changed.
- **FR-009**: The current user's profile data MUST be cached in memory after the first load; any feature requesting profile data within the same session MUST use the cached copy.
- **FR-010**: Any write operation (create adventure, delete adventure, update profile) MUST update the in-session cache to reflect the change without requiring a full re-fetch.

**Input Validation**

- **FR-011**: The new adventure name field MUST enforce a maximum length of 200 characters, with an inline validation error message when exceeded.
- **FR-012**: The avatar upload flow MUST validate that the selected file is a supported image type (JPEG, PNG, WebP, or GIF) before initiating any upload; unsupported file types MUST be rejected with a user-facing error message.

---

## Affected Areas & Constraints *(mandatory)*

- **Affected Feature Modules**: `lib/features/adventures`, `lib/features/profile`, `lib/features/auth`
- **Manager/Service Boundary Impact**: `AdventureManager` and `ProfileManager` will own in-session cache state; `ProfileService` and `AdventureService` remain as the I/O boundary to the backend; signed-URL resolution logic moves from the `ProfileAvatarView` widget into `ProfileService` or a dedicated media service.
- **Navigation/Auth Impact**: On logout, all in-session caches (adventures list, profile data, signed URLs) MUST be cleared so no data from the previous user session leaks to the next.
- **Code Generation Impact**: `auto_route` – no new routes; `mockito` – new mocks may be needed for cache-layer tests.
- **External Integration Impact**: Supabase storage (signed URL endpoint); image cache storage (device local storage); no changes to Auth0 integration.

### Key Entities

- **Image Cache Entry**: Represents a cached avatar image keyed by its storage path. Attributes: storage path (key), cached image data, cache timestamp, TTL.
- **Signed URL Cache Entry**: Represents a resolved and cached signed URL for an avatar. Attributes: storage path (key), signed URL, expiry timestamp.
- **In-Session Adventure List**: The authoritative in-memory copy of the user's adventure list for the current session. Updated optimistically on create/delete.
- **In-Session Profile Record**: The authoritative in-memory copy of the current user's profile for the session. Updated on successful profile save.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After the first successful profile page load, subsequent loads within the same session display the avatar in under 100 ms (no network round-trip for the image).
- **SC-002**: After the first successful adventures list load, navigating back to the list within the same session shows content instantly (under 50 ms), with no loading indicator visible.
- **SC-003**: The number of URL-signing requests to the backend during a typical 10-minute session is reduced by at least 90% compared to the current implementation (from one-per-render to at most one-per-session).
- **SC-004**: The number of profile data reads from the backend during a typical session is reduced by at least 80% compared to the current implementation.
- **SC-005**: 100% of adventure creation attempts with a name exceeding 200 characters are blocked client-side before any backend call is made.
- **SC-006**: 100% of avatar upload attempts with a non-image file type are rejected client-side before any upload request is made.
- **SC-007**: After a user logs out and a new user logs in, no data from the previous session is visible.

---

## Assumptions

- Users primarily access the app on mobile devices where local disk caching is available and appropriate.
- The existing Supabase Row Level Security (RLS) policies are correctly configured; this specification does not change backend access controls.
- The Auth0 authentication flow and token management remain unchanged.
- In-session caching is sufficient for the current app scale; persistent cross-session caching (beyond images) is out of scope for this iteration.
- The 200-character limit for adventure names aligns with reasonable database column constraints; the exact limit may be adjusted during planning if the schema specifies otherwise.
- Supported image types for avatar upload are JPEG, PNG, WebP, and GIF; additional formats are out of scope.
- Cache TTL defaults (24 hours for image cache, URL validity for signed URL cache) represent sensible starting values and may be tuned during implementation.
- The signed URL expiry of 3600 seconds (1 hour) currently configured in Supabase storage is retained; the proactive refresh threshold of 5 minutes before expiry is a safe default.

---

## Verification Strategy *(mandatory)*

- **Automated Coverage**:
  - Unit tests for in-session cache logic within `AdventureManager` and `ProfileManager` (cache hit, cache miss, invalidation on write, cache clear on logout).
  - Unit tests for signed URL cache logic (TTL expiry, proactive refresh, deduplication).
  - Unit tests for the new input validators (adventure name max length, avatar file type check).
  - Widget tests for `ProfileAvatarView` asserting that the signing endpoint is not called on repeated widget rebuilds within a session.
- **Manual Validation**:
  - Load adventures list, disconnect from network, navigate away and back — list must still display.
  - Load profile page, note avatar load time, rebuild widget (rotate device or navigate away/back) — avatar must appear instantly on second render.
  - Submit a new adventure with a 201-character name — form must reject it.
  - Attempt to upload a PDF as an avatar — app must display an error before any network activity.
  - Log out and log in as a different user — no data from the first user's session should be visible.
- **Testability Risks**: Verifying disk-cache hits in widget tests requires mock infrastructure for the image cache; this may be partially manual during initial validation.
