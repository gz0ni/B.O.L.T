<div>

[**English**](README.md)

</div>

# B.O.L.T

[![Последняя версия](https://img.shields.io/github/release/gz0ni/B.O.L.T/all.svg?style=flat-square)](https://github.com/gz0ni/B.O.L.T/releases)[![Лицензия](https://img.shields.io/github/license/gz0ni/B.O.L.T?style=flat-square)](LICENSE)

> Резкий взгляд на ваш трафик. VPN / прокси-клиент для Windows, macOS, Android и Linux на основе ядра
> [Clash.Meta (mihomo)](https://github.com/MetaCubeX/mihomo). Простой, открытый, без рекламы и бесплатный.

B.O.L.T (название — от *bolt*, крепёжного элемента) — форк [FlClash](https://github.com/chen08209/FlClash), который
сохраняет чистое честное ядро: вся работа ложится на движок Clash.Meta (mihomo), а само приложение остаётся лёгким
и быстрым.

## Возможности

- **Кроссплатформенность** — Windows, macOS, Linux, Android (Windows — основная и наиболее протестированная цель)
- **Чистый интерфейс** — Material You, светлая и тёмная темы, нативный вид
- **Поддержка подписок** — добавление по ссылке, сырому ключу, из буфера обмена или через `.yaml`/`.yml`/`.json`
- **Статистика трафика** — живая скорость, лимит и срок действия подписки
- **Инструменты ядра** — проверка задержки серверов, избранное, редактор конфига, логи ядра
- **Локализация** — английский и русский (системная локаль или выбор языка в настройках)

## Планы

- **iOS** — запланирован. Сначала Android/десктоп; для iOS потребуется sideload/подпись (в App Store приложения **нет**).
- **WebDAV-синхронизация** — в работе (переходит из FlClash).

## Скачать

Последние версии — на странице [Releases](https://github.com/gz0ni/B.O.L.T/releases).

## Сборка

1. Установите [Flutter](https://flutter.dev) и [Go](https://go.dev).
2. Обновите сабмодуль ядра mihomo:
   ```bash
   git submodule update --init --recursive
   ```
3. Соберите нужную платформу:

   - **Windows**: установите GCC и Inno Setup, затем
     ```bash
     dart setup.dart windows
     ```
     или напрямую:
     ```bash
     flutter build windows --release --dart-define-from-file=env.json --no-pub
     ```

   - **Linux**: `dart setup.dart linux` (или поставьте `libayatana-appindicator3-dev` и `libkeybinder-3.0-dev` вручную).

   - **macOS**: `dart setup.dart macos` (нужен macOS).

   - **Android**: установите Android SDK/NDK, задайте `ANDROID_NDK`, затем `dart setup.dart android`.

## Честные замечания

- Ядро здесь — **Clash.Meta (mihomo)**, именно оно выполняет всю прокси-работу.
- Проект — форк FlClash (GNU GPLv3); все изменения поверх оригинала тоже под GPLv3.
- Версии в App Store нет и не планируется.

## Лицензия

[GPL-3.0](LICENSE) — весь проект, включая исходный код FlClash, от которого этот форк произведён.

## Благодарности

- [FlClash](https://github.com/chen08209/FlClash) — оригинальный клиент, от которого форкнут проект.
- [Clash.Meta](https://github.com/MetaCubeX/mihomo) — ядро, используемое обоими.