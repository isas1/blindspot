# Blindspot

A reflective mirror for [Claude Code](https://code.claude.com).

Blindspot surfaces patterns in your own thinking, decisions, and work that are hard to see from the inside — where you're making progress, where you're stuck, and any signal that the work is starting to cost you. Every observation is tied to evidence from your own words. It is **not** a therapist, coach, or diagnostician: it observes and names patterns; you decide what they mean.

You run it with `/blindspot`, ideally at the end of a work session. An optional, gentle nudge can remind you so you don't have to remember.

```
/blindspot
```

> **A mirror, not a clinician.** Blindspot is designed to stop analyzing and respond plainly the moment it detects distress, and to set the tool down entirely at any sign of self-harm. It is not a substitute for professional support. See [docs/privacy.md](docs/privacy.md).

---

## How it works

Two pieces, deliberately separate:

| Piece | What it is | When it runs |
| --- | --- | --- |
| **The skill** | `/blindspot` — interactive, visible, you read the output | Only when **you** type it |
| **The nudge** *(optional)* | A `SessionStart` hook that reminds you to run `/blindspot` | At most once every 72h |

The skill is **manual by design** (`disable-model-invocation: true` in its frontmatter), so it never fires on its own and never reacts to every message. The nudge only ever *reminds* you — it does not run the analysis for you. That keeps you in control of when the mirror happens, which for a self-awareness tool is the point.

Each run reads the current session's conversation plus your running log at `~/.claude/blindspot/sessions.md`, and appends to it. The log keeps **EVIDENCE** (your actual words, timestamped — treated as fact) separate from **READS** (interpretations, re-derived from scratch each time). A pattern only becomes a trend when evidence across multiple dates supports it. See [examples/sessions-example.md](examples/sessions-example.md) for what a populated log looks like.

## Install

### Marketplace (recommended)

```
/plugin marketplace add <your-github-username>/blindspot
/plugin install blindspot@blindspot
```

Then restart Claude Code or run `/reload-plugins`. This installs the skill and the optional nudge.

### Local (development)

```bash
git clone https://github.com/<your-github-username>/blindspot
cd blindspot
bash scripts/link-skill.sh   # symlinks the skill into ~/.claude/skills (no hook)
```

Full walkthrough — including the recommended "test by hand before automating" ritual — is in [docs/getting-started.md](docs/getting-started.md).

## The nudge (optional, semi-automatic)

Installed automatically with the marketplace plugin. It is conservative on purpose: a single one-line reminder, at most once every 72 hours, surfaced through Claude's first reply.

Configure it with environment variables:

```bash
export BLINDSPOT_INTERVAL_HOURS=48   # minimum hours between nudges (default 72)
export BLINDSPOT_NUDGE=off           # disable the nudge entirely
```

Force it while testing:

```bash
rm -f ~/.claude/blindspot/.last-nudge   # clear the gate, then start a new session
```

### Want it fully hands-free instead?

By default the skill is manual and the hook only reminds you. If you'd rather Claude run the check-in itself once per interval, two small edits:

1. In `skills/blindspot/SKILL.md`, remove the `disable-model-invocation: true` line.
2. In `hooks/session-start.sh`, change the reminder message to instruct Claude to *run* `/blindspot` rather than mention it.

This trades control for convenience. Test the manual version first; the trap of automation is producing reflections you never actually read.

## Privacy

Everything stays on your machine in `~/.claude/blindspot/`. Nothing is uploaded, synced, or sent anywhere. The file accumulates personal — sometimes sensitive — signals, so treat it like a journal. Details and deletion instructions: [docs/privacy.md](docs/privacy.md).

## Repository layout

```
blindspot/
├── .claude-plugin/
│   ├── plugin.json          # plugin manifest (skills + auto-discovered hooks)
│   └── marketplace.json     # lets users add this repo as a marketplace
├── skills/
│   └── blindspot/
│       └── SKILL.md         # the skill itself
├── hooks/
│   ├── hooks.json           # wires the SessionStart nudge
│   └── session-start.sh     # gated, reminder-only nudge script
├── scripts/
│   ├── link-skill.sh        # local dev: symlink the skill into ~/.claude/skills
│   └── validate.sh          # dependency-free sanity check of the plugin
├── examples/
│   └── sessions-example.md  # what a populated log looks like
├── docs/
│   ├── getting-started.md
│   └── privacy.md
├── README.md
├── CHANGELOG.md
├── CLAUDE.md                # notes for working on this repo
└── LICENSE
```

## Validate your changes

```bash
bash scripts/validate.sh
```

Checks skill frontmatter, name/directory match, description length, JSON validity, and hook executability.

## License

MIT — see [LICENSE](LICENSE).
