# Contract: Supabase Profile + Storage

## Scope
Defines the data contract between Flutter profile services and Supabase resources.

## Table Contract: `public.profiles`
- Primary key: `user_id` (text)
- Required columns:
  - `user_id text primary key`
  - `first_name text null`
  - `last_name text null`
  - `avatar_path text null`
  - `avatar_url text null`
  - `created_at timestamptz not null default now()`
  - `updated_at timestamptz not null default now()`

## Access Contract
- Read profile:
  - Input: authenticated JWT containing Auth0 `sub`.
  - Lookup: `profiles.user_id = jwt.sub`.
  - Output: one profile row or integration error state.
- Update profile:
  - Input: partial profile payload + optional avatar reference.
  - Behavior: update only provided fields; preserve non-updated fields.
  - Output: updated profile row projection.

## Storage Contract: `avatars` bucket
- Object path convention: `<user_id>/<timestamp>.<extension>`.
- Profile row must store a stable `avatar_path` and optionally resolved `avatar_url`.
- For overwrite/upsert behavior, policies must permit `INSERT`, `SELECT`, and `UPDATE` on `storage.objects`.

## Security / RLS Contract
- `public.profiles` RLS enabled.
- Policies guarantee users can select/update only rows where `user_id = jwt.sub`.
- `storage.objects` policies scoped to bucket `avatars` and folder prefix matching user identity.

## Error Contract
- Missing linked profile after successful auth: return integration error state with actionable retry/support guidance.
- Invalid update payload: return field-level validation errors without mutating persisted profile.
