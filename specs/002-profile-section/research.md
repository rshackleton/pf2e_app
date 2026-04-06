# Research: Profile Section Expansion

## Decision 1: Persist editable profile data in Supabase `public.profiles`
- Decision: Use a dedicated `public.profiles` table as the source of truth for editable first name, last name, and avatar reference.
- Rationale: Supabase guidance for user-managed profile data recommends a project-managed user table with RLS and a stable identity key relationship.
- Alternatives considered:
  - Store only in Auth0 metadata: rejected because profile must be fully expandable and managed in app-controlled domain data.
  - Local-only profile persistence: rejected because cross-device consistency and durable identity data are required.

## Decision 2: Link profile ownership with Auth0 `sub`
- Decision: Use Auth0 `sub` as immutable linkage key in `profiles.user_id`.
- Rationale: `sub` is stable per identity and avoids ambiguity from mutable identifiers such as email.
- Alternatives considered:
  - Email linkage: rejected due to mutability and potential identity collisions.
  - Dual-key linkage strategy: rejected due to unnecessary complexity and conflict risk.

## Decision 3: Provision profile row during Auth0 registration via Action
- Decision: Auth0 Action in registration flow provisions/ensures a Supabase profile row before first profile access.
- Rationale: Eliminates in-app first-open provisioning race conditions and aligns with explicit integration ownership.
- Alternatives considered:
  - Lazy create on first app profile view: rejected by explicit user clarification.
  - Create on every login: rejected due to redundant write path and unnecessary coupling to sign-in flow.

## Decision 4: Store avatar binary in Supabase Storage, keep reference in profile row
- Decision: Persist avatar files in Storage bucket (`avatars`) and store only stable URL/path reference in profile row.
- Rationale: Matches Supabase storage model, keeps DB rows lightweight, and supports future media policies.
- Alternatives considered:
  - Store avatar as binary/blob in profile row: rejected for performance and schema bloat concerns.
  - External URL-only strategy: rejected because app-managed avatar lifecycle and access policy are required.

## Decision 5: Enforce RLS for both profile rows and storage objects
- Decision: Apply row-level policies so users can read/update only their own profile and avatar objects.
- Rationale: Supabase docs and security guidance require explicit policies for exposed schemas and storage; upsert/update semantics require correct policy set.
- Alternatives considered:
  - Broad authenticated access: rejected due to data leakage risk.
  - Service role from client: rejected due to security boundary violation.

## Decision 6: Keep Flutter architecture boundaries (manager owns state, services own I/O)
  - Widget-direct Supabase/Auth0 calls: rejected as it violates manager/service separation and testability.
  - Introduce a new state framework: rejected as unnecessary for this feature scope.

## Decision 7: Verification strategy includes flow + integration-path testing
  - Manual-only verification: rejected due to regression risk and non-compliance with constitution.

## Security Sanity Pass (2026-04-05)
- Confirmed `public.profiles` uses owner-scoped RLS policies for `SELECT`, `INSERT`, and `UPDATE` keyed by JWT `sub`.
- Confirmed `storage.objects` policies for `avatars` include `SELECT`, `INSERT`, and `UPDATE`, which is required for upload upsert behavior.
- Confirmed Auth0 Action uses server-side service role secret and does not rely on user-editable metadata for authorization decisions.
- Confirmed client-side profile service uses publishable key auth path and never injects service role credentials.
