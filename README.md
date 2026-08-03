<div>

[**Русский**](README_ru.md)

</div>

# B.O.L.T

[![Last Version](https://img.shields.io/github/release/gz0ni/B.O.L.T/all.svg?style=flat-square)](https://github.com/gz0ni/B.O.L.T/releases)[![License](https://img.shields.io/github/license/gz0ni/B.O.L.T?style=flat-square)](LICENSE)

> A trenchant look at your traffic. VPN / proxy client for Windows, macOS, Android and Linux, built on the
> [Clash.Meta (mihomo)](https://github.com/MetaCubeX/mihomo) core. Simple, open-source, ad-free and free to use.

B.O.L.T (short for **Borderless Online Tunnel**) is a fork of
[FlClash](https://github.com/chen08209/FlClash) that keeps a clean, honest core: the Clash.Meta (mihomo) engine does the
heavy lifting while the app stays lightweight and fast.

## Features

- **Multi-platform** — Windows, macOS, Linux, Android (Windows is the primary, most-tested target)
- **Clean UI** — Material You design language, light and dark themes, native look
- **Subscription support** — add a subscription link, raw key, URL or `.yaml`/`.yml`/`.json` config directly
- **Traffic usage** — live traffic stats, subscription quota and expiry tracking
- **Core tools** — latency testing across servers, favorites, config editor, core logs
- **Localization** — English and Russian (system locale, or pick a language in Settings)

## Roadmap

- **iOS** — planned. Android/desktop targets first; iOS requires sideloading/signing (there is **no** App Store release).
- **WebDAV sync** — in progress (carried over from FlClash).

## Download

Grab the latest release for your platform from [Releases](https://github.com/gz0ni/B.O.L.T/releases).

## Build

1. Install the [Flutter](https://flutter.dev) and [Go](https://go.dev) toolchains.
2. Update the mihomo core submodule:
   ```bash
   git submodule update --init --recursive
   ```
3. Build a target:

   - **Windows**: install GCC and Inno Setup, then
     ```bash
     dart setup.dart windows
     ```
     or directly:
     ```bash
     flutter build windows --release --dart-define-from-file=env.json --no-pub
     ```

   - **Linux**: `dart setup.dart linux` (or install `libayatana-appindicator3-dev` and `libkeybinder-3.0-dev` yourself).

   - **macOS**: `dart setup.dart macos` (requires macOS).

   - **Android**: install Android SDK/NDK, export `ANDROID_NDK`, then `dart setup.dart android`.

## Honest notes

- The proxy core used here is **Clash.Meta (mihomo)** — it is the engine behind this client.
- This is a fork of FlClash (GNU GPLv3). All changes on top of the original are also GPLv3.
- There is no App Store version of this app.

## License

[GPL-3.0](LICENSE) — the whole project, including the original FlClash code that this fork is based on.

## Thanks

- [FlClash](https://github.com/chen08209/FlClash) — original client this project forked from.
- [Clash.Meta](https://github.com/MetaCubeX/mihomo) — the proxy core used by both.