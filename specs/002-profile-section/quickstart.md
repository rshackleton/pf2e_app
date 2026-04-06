# Quickstart: Implementing Profile Section Expansion

## Prerequisites
- Flutter environment configured for this repo.
- Auth0 tenant configured for application login.
- Supabase project configured with third-party Auth0 integration.
- Access to Supabase SQL and Storage policy management.

## 1. Prepare Supabase data + storage surfaces
1. Create/verify `public.profiles` schema with `user_id` primary key.
2. Enable RLS on `public.profiles` and add owner-only select/update policies.
3. Create/verify `avatars` bucket.
4. Add storage policies that support user-scoped upload/read/update; include `INSERT`, `SELECT`, `UPDATE` for upsert behavior.

## 2. Implement Auth0 provisioning Action
1. Create or update Auth0 Action in registration flow.
2. Ensure Action writes/upserts profile row keyed by Auth0 `sub`.
3. Confirm idempotent behavior for repeated invocations.

## 3. Implement Flutter feature updates
1. Extend `lib/features/profile/profile_page.dart` for view/edit workflow.
2. Add/extend profile manager for load/save/validation/error state transitions.
3. Add/extend profile/auth services for Supabase profile read/update + storage upload.
4. Register new/updated dependencies in `lib/locator.dart`.
5. Update routing only if navigation surface changes (`lib/router.dart` + generated outputs).

## 4. Run code generation and static checks
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## 5. Validate behavior
```bash
flutter test test/profile_flow_test.dart
flutter test test/auth_flow_test.dart
```

Manual validation checklist:
1. Login and open profile: first/last/avatar load from Supabase-linked record.
2. Update first/last name and save: persisted values reload correctly.
3. Upload avatar: stored in Supabase Storage and reflected in profile row reference.
4. Missing data and invalid input paths show graceful fallback/validation.
5. Sign out removes access to profile details.

## 6. Done criteria
- All functional requirements FR-001..FR-017 satisfied.
- Automated tests pass and cover primary user stories.
- RLS and storage policies verified against owner-only access.
- No unresolved constitution gate failures.

## 7. Rollout Notes
1. Deploy Supabase migrations for `profiles` schema and `avatars` storage policies before app rollout.
2. Configure Auth0 Action secrets (`SUPABASE_URL`, `SUPABASE_SECRET_KEY`) in each environment.
3. Validate profile edit flow in staging with a newly registered Auth0 user and an existing user.
4. Monitor Action logs and Supabase API logs for provisioning failures during first rollout window.

## 8. Verification Outcomes (2026-04-05)
- `flutter analyze` completed with no issues.
- `flutter test test/profile_flow_test.dart` passed.
- `flutter test test/auth_flow_test.dart test/adventure_flow_test.dart` passed.
