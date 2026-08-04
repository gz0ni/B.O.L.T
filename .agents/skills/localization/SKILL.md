---
name: localization
description: Use when changing B.O.L.T UI text, updating ARB localization, or fixing generated locale output in this repository.
---

# Localization

## When To Use

Use this for localization work inside this repository, especially hardcoded UI text in `lib/`, ARB updates, missing translations, or generated `lib/l10n/` output that does not match source ARB values.

The project ships exactly two locales: English and Russian. Do not add other locale ARB files unless explicitly asked.

Do not use this for README translation sync or manual edits to generated localization Dart.

## Workflow

1. Confirm `pubspec.yaml` still uses `flutter_intl`, source ARBs under `arb/` (`arb/intl_en.arb`, `arb/intl_ru.arb`), and generated output under `lib/l10n/` (`lib/l10n/intl/` + `lib/l10n/l10n.dart`).
2. Scan user-facing Dart text before opening many files (no CJK strings exist in this codebase; look for plain English literals instead):

   ```bash
   rg -n '"[A-Za-z][A-Za-z ]{3,}"' lib -g '!lib/l10n/intl/**' -g '!lib/**/generated/**'
   ```

3. Inspect the smallest relevant call sites and nearby ARB keys.
4. Add or update every source ARB:
   - `arb/intl_en.arb`
   - `arb/intl_ru.arb`
5. Replace inline strings with existing project accessors:
   - Widgets with `BuildContext`: `context.appLocalizations.key` (extension in `lib/common/context.dart`).
   - Controllers/providers/non-widget code: `currentAppLocalizations.key` from `lib/l10n/l10n.dart`.
6. Regenerate:

   ```bash
   dart run intl_utils:generate
   ```

7. Verify changed Dart files with `flutter analyze` when practical.

## Pitfalls

- If ru still shows English, fix the ru source ARB values and regenerate. Do not edit generated Dart.
- Ignore `lib/l10n/intl/**` and `lib/**/generated/**` during text scans.
- If generator or analyzer hits local cache permission friction, rerun serially before treating it as a code issue.
- New keys must be added to both ARBs; missing keys fall back to English (or the nearest locale), which is only acceptable for placeholder values.