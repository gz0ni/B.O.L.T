# Project Context

B.O.L.T is a multi-platform proxy client based on ClashMeta (mihomo), built with Flutter. It supports Android, Windows, macOS, and Linux, using a Material You design with Surfboard-like UI. It is a fork/rebrand of the FlClash project: package name `bolt`, display name `B.O.L.T`, publisher `gz0ni` (`https://github.com/gz0ni/B.O.L.T`).

## Version Notes

- No FVM: the repo has no `.fvmrc` and no `.fvm/`; use the system Flutter SDK.
- CI (`.github/workflows/build.yaml`) pins Flutter 3.44.4 (stable channel) on tag `v*` builds; trust CI as the source of truth for release builds.
- Dart SDK constraint: `>=3.8.0 <4.0.0`.

## Core Submodule

`core/Clash.Meta` is a Git submodule (`.gitmodules`) pointing at `https://github.com/chen08209/Clash.Meta.git`, branch `FlClash`. Run `git submodule update --init --recursive` after cloning.

## Build Dependencies

Linux:

```bash
sudo apt-get install libayatana-appindicator3-dev libkeybinder-3.0-dev
```

Windows:

- GCC, Rust, and Inno Setup.
- `ANDROID_NDK` env var for Android builds.

macOS:

```bash
npm install -g appdmg
```

## Packaging

- Windows: Inno Setup produces `dist/B.O.L.T-<version>-windows-<arch>-setup.exe` plus a `.zip`; AppId `99C0DBC8-79A6-425E-ACAC-15DACB6D60D8` (must not collide with the upstream FlClash AppId).
- Android: three split APKs.