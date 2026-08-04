---
name: ui-work
description: Use when changing B.O.L.T Flutter UI, widgets, screens, Material You styling, navigation surfaces, or user-facing interactions.
---

# UI Work

## When To Use

Use this for user-facing Flutter UI changes in `lib/`, including widgets, screens, navigation surfaces, settings rows, dialogs, and interaction behavior.

## Workflow

1. Locate existing nearby widgets and reuse their patterns before adding new abstractions. B.O.L.T has its own design system in `lib/theme/` (`app_tokens.dart`, `app_theme.dart`) and shared widgets in `lib/widgets/` (e.g. `bolt_surfaces.dart`); prefer them over ad-hoc styling.
2. Follow current Material You and Surfboard-like visual conventions.
3. Use existing providers, notifiers, and helpers where possible.
4. Keep `child:` last in widget constructors.
5. Prefer `const` constructors and final locals.
6. Localize user-facing text through ARB; use `localization` when text changes are non-trivial.
7. Add focused tests when behavior changes, especially for rendering states, taps, scrolling, and empty/error states. There is no `test/widgets/` suite; put logic-heavy coverage under `test/models/`, `test/providers/`, or `test/common/` as appropriate.
8. Run targeted verification:

   ```bash
   flutter analyze
   flutter test test/models/
   flutter test test/providers/
   ```

## Pitfalls

- Do not introduce a new visual system for one screen.
- Do not manually edit generated localization or provider files.
- Avoid broad layout rewrites unless the requested change requires them.
