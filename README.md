# pf2e_app

Flutter application for Pathfinder 2nd Edition tooling.

## Stack

- Flutter and Dart 3.11
- `auto_route` for navigation
- `get_it`, `watch_it`, `command_it`, and `listen_it` for dependency injection,
	reactive state, and command orchestration
- `auth0_flutter` and `supabase_flutter` for external integrations

## Architecture

- Production code is organized by feature under `lib/features/`
- Widgets consume managers and reactive listenables; services own external I/O
- Dependency registration is centralized in `lib/locator.dart`
- Navigation is declared in `lib/router.dart` and generated into `lib/router.gr.dart`

## Common Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

## Testing Notes

- Keep shared test utilities under `test/`
- Import test utilities relatively from other files in `test/`
- Add or update automated coverage for behavior changes unless the work is truly
	not automatable; document manual validation when that happens

## Governance

Project engineering rules live in `.specify/memory/constitution.md`. Speckit plans,
specifications, and task lists are expected to satisfy that constitution before work
is considered ready for implementation.
