# Architecture

## Core Integration

The Go proxy core in `core/` operates in two modes.

Android lib mode:

- Go core is compiled as a C shared library, `libclash.so`, through `go build -buildmode=c-shared` with CGO.
- Flutter calls it via FFI through the `service` plugin.
- Dart-side implementation: `lib/core/lib.dart` (`CoreLib`).

Desktop core mode:

- Go core runs as a separate process with `CGO_ENABLED=0`. The Windows binary is `libclash/windows/BOLTCore.exe` (linked with `-H=windowsgui` so no console window appears).
- Flutter communicates via JSON over socket, using a Unix socket on macOS/Linux and TCP on Windows.
- Dart-side implementation: `lib/core/service.dart` (`CoreService`).

`lib/core/controller.dart` (`CoreController`) selects the implementation based on platform. `lib/core/interface.dart` defines the shared `CoreHandlerInterface`.

Key Go core files:

- `core/hub.go`: handler functions.
- `core/action.go`: dispatch.
- `core/lib.go`: CGO exports.
- `core/server.go`: socket server.

## State Management

Provider files in `lib/providers/`:

- `app.dart`: runtime/UI state, logs, traffic, delays, loading, navigation.
- `config.dart`: persistent config providers, app settings, theme, VPN, proxy style.
- `state.dart`: derived/computed providers, navigation, proxy, tray, color scheme.
- `action.dart`: business logic notifiers, setup, backup, core lifecycle, proxy selection.
- `database.dart`: Drift database provider wrappers.

`globalState` in `lib/state.dart` is a singleton holding app lifecycle, timers, theme, and start/stop state. Providers are generated into `lib/providers/generated/`.

## Database

The app uses Drift/SQLite in `lib/database/`. Current schema version is 3 (`lib/database/database.dart`).

Tables (one file per table under `lib/database/`):

- `Profiles` (`profiles.dart`)
- `Scripts` (`scripts.dart`)
- `Rules` (`rules.dart`)
- `ProfileRuleLinks` (`links.dart`, `profile_rule_mapping`)
- `ProfileKeys` (`profile_keys.dart`)
- `ProxyGroups` (`groups.dart`)
- `IconRecords` (`icons.dart`, `icon_records`)

Rule scenes distinguish global added rules, profile added rules, profile custom rules, and disabled links. Rule and proxy-group ordering use fractional indexing.

Generated Drift output lives in `lib/database/generated/database.g.dart`. After schema changes, run code generation and add or update focused database tests under `test/database/` when converter or migration behavior changes.

## Manager Stack

Managers are nested `InheritedWidget`/`StatefulWidget` components in `lib/manager/`, assembled in `lib/application.dart`:

```text
AppEnvManager
  > StatusManager > ThemeManager
  > [Desktop: WindowManager > TrayManager > HotKeyManager > ProxyManager]
  > [Android: AndroidManager > TileManager]
  > AppStateManager > CoreManager > ConnectivityManager
  > [Windows: (none) | Desktop macOS/Linux: WindowHeaderContainer | Android: VpnManager]
```

`AppEnvManager` and `AppStateManager` both live in `lib/manager/app_manager.dart`. Desktop-only managers are conditionally inserted.

## Core Controller and Actions

`lib/core/controller.dart` (`CoreController`) is a singleton facade over `CoreHandlerInterface`. Public methods delegate to the platform-specific interface, either Android FFI or desktop socket. It has an `@visibleForTesting` constructor and `resetInstance()` for test injection.

Business logic lives in Riverpod notifier classes in `lib/providers/action.dart`:

- `CommonAction`: update check and common UI operations.
- `SetupAction`: config setup and TUN management.
- `BackupAction`: backup/restore with WebDAV sync.
- `CoreAction`: core lifecycle, init, connect, restart, shutdown.
- `SystemAction`: system integration, tray, exit, brightness.
- `StoreAction`: profile storage operations.
- `ThemeAction`: theme state updates.
- `ProxiesAction`: group management and proxy selection.
- `ProfilesAction`: profile CRUD, auto-update, import.

## Platform Managers

Desktop:

- `WindowManager` (`window_manager.dart`)
- `TrayManager` (`tray_manager.dart`)
- `HotKeyManager` (`hotkey_manager.dart`)
- `ProxyManager` (`proxy_manager.dart`)

Mobile:

- `AndroidManager` (`android_manager.dart`)
- `TileManager` (`tile_manager.dart`)
- `VpnManager` (`vpn_manager.dart`)

Shared:

- `ConnectivityManager` (`connectivity_manager.dart`)
- `CoreManager` (`core_manager.dart`)
- `AppStateManager` / `AppEnvManager` (`app_manager.dart`)
- `StatusManager` (`status_manager.dart`)
- `ThemeManager` (`theme_manager.dart`)

## Build System

`setup.dart` is the release build orchestrator:

1. On Windows, pre-builds the Go core via `dart run build_tool windows --root-dir .` (run from `plugins/setup/buildkit/build_tool/`) and reads `core_sha256.json`.
2. Writes `env.json` (`APP_ENV`, and `CORE_SHA256` on Windows).
3. Passes the file via `--dart-define-from-file=env.json`, embedding the SHA at compile time for Windows.
4. Activates the `flutter_distributor` fork for packaging:

   ```bash
   dart pub global activate -s git https://github.com/chen08209/flutter_distributor.git --git-ref FlClash --git-path packages/flutter_distributor
   ```

Go core building is handled by `build_tool`, a standalone Dart CLI in `plugins/setup/buildkit/build_tool/`. Build configuration defaults live in `build_tool/lib/src/options.dart` and can be overridden via `build_config.yaml`.

Platform build hooks inside `flutter build` trigger `build_tool` automatically:

- macOS: podspec script phase, `build_pod.sh`, `build_tool macos`.
- Linux: CMake include, `buildkit/cmake/buildkit.cmake`, `build_tool linux`.
- Windows: CMake include, `buildkit/cmake/buildkit.cmake`, `build_tool windows`.
- Android: Gradle include, `buildkit/gradle/plugin.gradle`, `build_tool android`.

The CMake hook passes the build configuration to the tool through the `BUILDKIT_CONFIGURATION` environment variable (set from `$<CONFIG>`), not a `--dev` flag. The Go linker adds `-H=windowsgui` on Windows targets (no console window), and the Windows desktop minimum window size is 640×540.

Windows helper auth:

- Release: Core SHA256 is embedded in both the Flutter app and the Rust helper (`services/helper/`, built through `RustBuilder` in the build tool). The app pings the helper and verifies the token matches.
- Debug: the Rust helper is built without `--release` and skips token verification, so `flutter run` works without the SHA256 flow.

Windows packaging notes:

- Artifact names gain arch suffixes via the `--description` flag passed to `flutter_distributor`, e.g. `B.O.L.T-0.0.1-windows-amd64-setup.exe` and `B.O.L.T-0.0.1-macos-arm64.dmg`.
- Inno config lives in `windows/packaging/exe/make_config.yaml`; AppId is `99C0DBC8-79A6-425E-ACAC-15DACB6D60D8` (must stay unique; the upstream FlClash AppId `728B3532-C74B-4870-9068-BE70FE12A3E6` must never be reused).

## Local Plugins

- `setup`: build harness FFI plugin, no Dart API — only platform build hooks that trigger Go compilation (`plugins/setup/buildkit/`).
- `proxy`: system proxy configuration.
- `rust_api`: Flutter Rust Bridge FFI plugin.
- `wifi_ssid`: Wi-Fi SSID detection.
- `window_ext`: window extensions.

`tray_manager` is a Git fork dependency in `pubspec.yaml` (not a local plugin); `flutter_distributor` is activated globally at build time and is not a pubspec dependency.

## Rust Helper Service

`services/helper/` is a Windows-only privileged helper for starting the core as admin and managing TUN. It is built by the build tool with:

```bash
cargo build --features windows-service [--release]
```

It uses token-based auth with the Flutter app (SHA256-based in release, skipped in debug). The built binary is `libclash/windows/BOLT_HelperService.exe`.