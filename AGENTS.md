# Repository Guidelines

## Project Structure & Module Organization
- `lib/` contains the Flutter app. Key areas: `lib/screens/` for UI screens, `lib/services/` for state and persistence logic, `lib/models/` for data models, and entry points like `lib/main.dart` and `lib/onboarding_screen.dart`.
- `test/` holds automated tests (Flutter test) named `*_test.dart`.
- `android/` and `ios/` contain platform-specific wrappers.
- `assets/sounds/` is the expected location for audio assets (listed in `pubspec.yaml`).
- Project notes and plans live in `PROJECT_SUMMARY.md` and `PHASE*_IMPLEMENTATION.md`, with a manual checklist in `PHASE6_TESTING_GUIDE.md`.

## Build, Test, and Development Commands
- `flutter pub get` fetches dependencies.
- `flutter run` launches the app on a connected device/emulator.
- `flutter test` runs all unit/widget tests in `test/`.
- `flutter analyze` runs static analysis for Dart/Flutter issues.
- `flutter build apk` or `flutter build ios` creates release builds.

## Coding Style & Naming Conventions
- Use Dart/Flutter defaults; format with `dart format .` before committing.
- Indentation is 2 spaces with trailing commas for Flutter widget trees.
- File names use `lower_snake_case.dart`; classes use `UpperCamelCase`.
- Keep UI in `lib/screens/` and domain logic in `lib/services/` and `lib/models/`.

## Testing Guidelines
- Tests use `flutter_test` and live in `test/` with `*_test.dart` naming.
- Add or update tests for service changes (e.g., achievements, themes, daily challenges).
- For broader regression coverage, follow the manual checklist in `PHASE6_TESTING_GUIDE.md`.

## Commit & Pull Request Guidelines
- Commit messages in history use concise, descriptive subjects (e.g., `Phase 4: Implement complete daily challenge gameplay system`). Follow that pattern when relevant.
- PRs should include a short summary, testing notes (`flutter test`, manual checks), and screenshots or screen recordings for UI changes. Link issues when available.
