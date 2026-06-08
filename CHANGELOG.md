# Changelog

All notable changes to this project are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); this project uses [SemVer](https://semver.org/).

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
