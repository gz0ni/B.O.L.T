# Commands

## Building

Update submodules first. The ClashMeta Go core lives in `core/Clash.Meta/`.

```bash
git submodule update --init --recursive
```

Full package build, including Go core, Flutter, and packaging, runs through `setup.dart`:

```bash
dart setup.dart macos
dart setup.dart linux
dart setup.dart windows
dart setup.dart android
```

Build only the Go core and skip Flutter packaging (`make` wraps `plugins/setup/buildkit/run_build_tool.sh`):

```bash
make core-macos
make core-linux
make core-windows
make core-android
```

Pass `ARCH` or `TARGET_PLATFORM` through `make` when needed, for example:

```bash
make core-macos ARCH=arm64
make core-android TARGET_PLATFORM=android-arm64
```

IMPORTANT: Windows release builds MUST go through `dart setup.dart windows` (or pass
`--dart-define-from-file=env.json` to `flutter build windows`). `setup.dart` writes `env.json`
with `APP_ENV` and (on Windows) `CORE_SHA256` read from `core_sha256.json`; the app compares
the embedded SHA against the helper's `/ping` response. A plain `flutter build windows`
embeds empty values and silently breaks the elevated core/TUN flow.

Windows packaging activates a fork of `flutter_distributor` globally at build time and runs
Inno Setup to produce `dist/B.O.L.T-<version>-windows-<arch>-setup.exe` plus a `.zip`:

```bash
dart pub global activate -s git https://github.com/chen08209/flutter_distributor.git --git-ref FlClash --git-path packages/flutter_distributor
```

## Flutter Development

The project is not pinned with FVM; use the system Flutter SDK.

```bash
flutter pub get
flutter run
flutter test
```

Use `flutter test`, not `dart test`, because models pull in Flutter types.

## Code Generation

Run code generation after modifying models, providers, or database schema:

```bash
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch
```

Code generation covers:

- Riverpod providers through `riverpod_generator`.
- Models through `freezed` and `json_serializable`.
- Database tables through `drift_dev`.

Generated output paths, configured in `build.yaml`:

- `lib/models/generated/*.g.dart`, `*.freezed.dart`.
- `lib/providers/generated/*.g.dart`.
- `lib/database/generated/*.g.dart`.

Localization: source ARBs are `arb/intl_en.arb` and `arb/intl_ru.arb`; regenerate `lib/l10n/` with:

```bash
dart run intl_utils:generate
```

## Testing

Tests use `package:test/test.dart` for pure Dart logic and `flutter_test` for provider and widget tests. `mocktail` is the mocking framework. There is no `test/widgets/` suite. Test paths:

```bash
flutter test test/models/
flutter test test/core/
flutter test test/providers/
flutter test test/common/
flutter test test/database/
flutter test test/enum/
flutter test test/setup_test.dart
flutter test plugins/proxy/test/proxy_test.dart
```

Root `flutter test` only discovers the root package's `test/` directory by default. Include bundled plugin Dart tests by passing paths explicitly, or run `flutter test` from that plugin package directory. Native plugin tests under platform folders are not run by `flutter test`.

Expected baseline: a few `test/common/format_test.dart` tests fail until `AppLocalizations` is initialized (assertion `_current != null`), plus 3 analyzer infos in that file. These pre-date any feature work.

## Verify

CI runs these in order:

```bash
flutter pub get
flutter analyze --no-fatal-infos
flutter test --reporter expanded
```

Run `flutter analyze` locally before committing when practical.