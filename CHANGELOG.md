# Changelog

All notable changes to this project are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); this project uses [SemVer](https://semver.org/).

## [0.3.0] — 2026-06-10

### Added
- **Portable Blindspot** (`portable/`): the mirror for any LLM, no Claude Code
  required. Two self-contained versions — `blindspot-prompt.md` (full, fits a
  Custom GPT instructions field) and `blindspot-compact.md` (~1.4k-char card for
  small custom-instruction fields). Memory becomes a user-kept log note: paste
  it in at check-in, copy the emitted fenced entry back out. Both versions
  preserve the evidence discipline, the strain tier, and the distress/self-harm
  hard stop, and stay dormant until the user asks for a check-in (the portable
  equivalent of `disable-model-invocation: true`).
- `docs/any-llm.md`: per-platform setup guide (ChatGPT Projects/Custom GPTs,
  Claude.ai Projects, Gemini Gems, Copilot, local models) and the log ritual.
- `scripts/validate.sh` now checks the portable files: presence, character
  budgets (8000 full / 1600 compact), and that the self-harm hard-stop
  invariant is present in both portable versions and the skill.
- `ARCHITECTURE.md`: the three-artifact model, the v0.3.0 design decisions and
  their rationale (setup-vs-request discriminator, user-carried log, date
  honesty, the no-log-entry rule on hard stop), and open items.

### Changed
- Skill output format gains an explicit "no clear pattern this time" path, so
  the format never pressures the model into inventing a pattern to fill slots.
- Hard stop now explicitly produces no log entry (skill and portable versions),
  closing a loophole where a self-harm disclosure could be folded into the
  persistent record by the unconditional end-of-check-in log block.

## [0.2.0] — 2026-06-08

### Added
- "Strain and sustainable pace" tier in the skill: a middle band between
  everyday friction and the distress hard-stop. Grounded in a real staged
  burnout progression (the "one more prompt" pull → cognitive degradation →
  tone drift → heavier accumulation), it watches for gradual buildup and offers
  light, optional nudges that **carry their reason** — context-backed ("you've
  rephrased this three times and it's circling"), never a bare "take a break."
  Treats clear long sessions as flow (don't interrupt), backs the user when they
  say they want to stop, and stays strictly evidence-gated: says nothing when no
  cue is present.

### Changed
- Skill description now names strain/fatigue alongside friction, progress, and
  heavier mental-health signals.
- Distress section reframed as the top of a ladder above the strain band.

## [0.1.0] — 2026-06-08

### Added
- `blindspot` skill (`/blindspot`): reflective mirror that surfaces patterns in
  the user's own thinking, decisions, and work, with EVIDENCE/READS separation
  and explicit distress and self-harm hard-stops.
- Marketplace plugin packaging (`.claude-plugin/plugin.json`, `marketplace.json`).
- Optional, gated, reminder-only `SessionStart` nudge (`hooks/session-start.sh`),
  configurable via `BLINDSPOT_INTERVAL_HOURS` and `BLINDSPOT_NUDGE`.
- `scripts/link-skill.sh` (local dev install) and `scripts/validate.sh`
  (dependency-free plugin validator).
- Docs: getting-started and privacy/data-locality notes.
- `examples/sessions-example.md` sample log.
