# Getting started

Blindspot is best earned, not assumed. Install just the skill, run it by hand for a few days, and decide whether the output is worth reading **before** you turn on any automation. If the reads are bland, no nudge will save them; if they're sharp, then automate.

## 1. Install the skill

### Option A — Marketplace (recommended)

From inside Claude Code:

```
/plugin marketplace add <your-github-username>/blindspot
/plugin install blindspot@blindspot
```

Restart Claude Code (or run `/reload-plugins`). This installs the `/blindspot` skill **and** the optional SessionStart nudge.

### Option B — Local symlink (for development)

```bash
git clone https://github.com/<your-github-username>/blindspot
cd blindspot
bash scripts/link-skill.sh
```

This installs **only** the skill (no hook). Start a new session and type `/` — `blindspot` should appear in the menu.

## 2. Smoke test it (today)

Do a real work session first — write some code, change your mind once or twice, the normal mess. Then run:

```
/blindspot
```

The first run asks permission to read/write `~/.claude/blindspot/sessions.md` — allow it. Read what it gives you, then open the file:

```bash
cat ~/.claude/blindspot/sessions.md
```

Check two things:

1. Did it split **EVIDENCE** (facts, quotes) from **READ** (its interpretation)?
2. Is the read specific to what you actually did, or generic filler?

That's the whole test in miniature.

## 3. Run it manually for ~3–4 days

End each work session with `/blindspot`. You're answering one question: **does this tell me something I didn't already see?** If yes, move on to automation. If it's bland, fix the skill prompt in `skills/blindspot/SKILL.md` — not the trigger.

## 4. (Optional) Let the nudge remind you

If you installed via the marketplace, the SessionStart hook is already wired. By default it surfaces a one-line reminder to run `/blindspot` at most once every 72 hours. It never runs the analysis for you — `/blindspot` stays manual.

Tune or disable it (see [the README](../README.md#the-nudge-optional-semi-automatic)):

```bash
export BLINDSPOT_INTERVAL_HOURS=48   # nudge at most every 2 days
export BLINDSPOT_NUDGE=off           # turn the nudge off entirely
```

To force the nudge while testing, clear its timestamp and start a new session:

```bash
rm -f ~/.claude/blindspot/.last-nudge
```

If nothing appears, run `claude --debug` to see which hooks matched and their exit codes.

## Where your data lives

Everything stays on your machine, in `~/.claude/blindspot/`. Nothing is uploaded. See [privacy.md](privacy.md).
