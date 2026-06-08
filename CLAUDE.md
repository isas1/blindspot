# Working on the blindspot plugin

This repo packages a single Claude Code skill as a marketplace plugin.

## Layout that matters

- `skills/blindspot/SKILL.md` — the skill. Frontmatter `name` MUST equal the directory name (`blindspot`). `disable-model-invocation: true` keeps it manual-only; do not remove it unless you intend autonomous firing.
- `.claude-plugin/plugin.json` — manifest. `hooks/hooks.json` is auto-discovered; it does not need to be listed here.
- `hooks/session-start.sh` — the nudge. Reminder-only, gated, silent when not due. It must never run the analysis or invoke the skill.
- The skill's data lives in `~/.claude/blindspot/` (the user's home), never in the plugin install dir (`${CLAUDE_PLUGIN_ROOT}` is replaced on every update).

## Before committing

```bash
bash scripts/validate.sh
chmod +x hooks/session-start.sh scripts/*.sh   # keep shell scripts executable
```

## Editing the skill

The skill is a sensitive document — it handles distress and self-harm signals. Preserve the "Hard stop: distress" section's intent exactly: stop analyzing on distress, set the tool down on any self-harm signal. Do not turn those into scored or pattern-matched behaviors.

## Placeholders to fill before publishing

Search for `<your-github-username>` and `<your name>` across `README.md`, `docs/`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `LICENSE`, and replace them.
