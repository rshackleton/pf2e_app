# Contract: Auth0 Registration Provisioning Action

## Scope
Defines the behavior of the Auth0 Action responsible for ensuring a linked Supabase profile row exists at registration time.

## Trigger
- Auth0 post-registration or post-login event in the registration path (per tenant configuration).

## Input Contract
- Required identity fields from Auth0 event:
  - `user.sub` (canonical identity key)
  - Optional metadata candidates for bootstrap values (first/last name, avatar hints)

## Deployment Inputs
- Runtime: Auth0 Action Node.js runtime (supported LTS)
- Secrets:
  - `SUPABASE_URL`
  - `SUPABASE_SECRET_KEY`
- Trigger: `post-user-registration`

## Deployment Outputs
- Success telemetry log entry indicates profile upsert path executed.
- For failed upsert, Action log includes Supabase status and response payload snippet.

## Output Contract
- On success:
  - Supabase `public.profiles` contains row keyed by `user_id = user.sub`.
  - Existing row is preserved or idempotently updated according to provisioning policy.
- On failure:
  - Action emits failure telemetry/logging.
  - App may surface integration error state when profile is later accessed.

## Idempotency Contract
- Repeated invocations for same `user.sub` must not create duplicate rows.
- Upsert semantics are required on provisioning write path.

## Security Contract
- Action uses server-side credential path only (never client-exposed service role secret).
- No trust in user-editable metadata for authorization decisions.
