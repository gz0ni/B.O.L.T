# Agent Skills

Repo-scoped skills live under `.agents/skills/*/SKILL.md` and are discoverable by skill `name` and `description`; the full instructions load only when a task matches.

## Available Repo Skills

- `localization`: B.O.L.T UI text, ARB updates (en/ru), locale generation, and generated locale output fixes.
- `provider-tests`: Riverpod provider, notifier, and state-management tests.
- `ui-work`: Flutter UI, widgets, Material You styling, navigation surfaces, and user-facing interactions.
- `core-platform`: core integration, platform managers, Go core communication, desktop/mobile behavior, and Windows helper flow.
- `ui-ux-pro-max`: design intelligence database (84 styles, palettes, typography, UX guidelines, etc.). Repo copy of a global user-level skill, kept for portability; data lives under `data/` and `references/`.

## Authoring Notes

- Add new repeatable workflows as `.agents/skills/<skill-name>/SKILL.md`.
- Keep skill descriptions trigger-focused and start them with `Use when...`.
- Keep long reference material in `.agents/*.md`; skills should link to it instead of duplicating it.
- Do not add tool/agent-specific configuration (e.g. `.codex/`) — this repo does not use it.