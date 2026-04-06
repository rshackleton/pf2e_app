# Data Model: Profile Section Expansion

## Entity: ProfileRecord
- Purpose: Canonical editable profile data persisted in Supabase and linked to Auth0 identity.
- Fields:
  - `user_id` (text, primary key): immutable Auth0 `sub`.
  - `first_name` (text, nullable): user-editable first name.
  - `last_name` (text, nullable): user-editable last name.
  - `avatar_path` (text, nullable): path/key for avatar object in Supabase Storage.
  - `created_at` (timestamp with time zone, not null, default now).
  - `updated_at` (timestamp with time zone, not null, default now).
- Validation rules:
  - `user_id` MUST be non-empty and unique.
  - At least one of `first_name` / `last_name` MAY be null, but UI fallback text is required.
  - `avatar_path` MUST reference an object in the `avatars` bucket when present.
  - Any runtime `avatar_url` MUST be derived from `avatar_path` and is not persisted as a canonical data column.
- Relationships:
  - One-to-one with authenticated principal identity (`Auth0 sub`).

## Entity: ProfileUpdateRequest
- Purpose: Client-side editable payload submitted from profile form.
- Fields:
  - `first_name` (string, optional)
  - `last_name` (string, optional)
  - `avatar_upload` (optional media payload before storage write)
- Validation rules:
  - Reject invalid field formats before submission.
  - Partial update must not clear untouched fields.

## Entity: AvatarAsset
- Purpose: Binary media object stored in Supabase Storage.
- Fields:
  - `bucket_id` = `avatars`
  - `object_path` (string): convention `<user_id>/<timestamp>.<ext>`
  - `owner_id` (storage owner identity)
  - `content_type` (image mime type)
- Validation rules:
  - Allowed file types restricted to image formats.
  - Upload/update access constrained to owner-linked path via RLS policy.

## Entity: ProfileViewState
- Purpose: Manager-level reactive state for profile page UX.
- Fields:
  - `load_state`: `idle | loading | loaded | error`
  - `save_state`: `idle | validating | saving | saved | error`
  - `error_message` (nullable)
  - `profile` (nullable `ProfileRecord` projection)
- State transitions:
  - `idle -> loading -> loaded`
  - `loading -> error -> loading` (retry)
  - `loaded -> validating -> saving -> saved -> loaded`
  - `saving -> error -> validating` (retry after correction)
