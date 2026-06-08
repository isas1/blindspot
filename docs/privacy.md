# Privacy & data locality

Blindspot writes a record of how you work and, sometimes, how you seem to be doing. Treat that file the way you'd treat a journal.

## What is stored, and where

- A single file: `~/.claude/blindspot/sessions.md` on your own machine.
- A timestamp file used only to rate-limit the reminder: `~/.claude/blindspot/.last-nudge`.

That's it. The skill reads the current session's conversation plus that one file, and appends to that one file. It does not maintain a database, send telemetry, or call any network service.

## What is NOT stored or sent

- Nothing is uploaded anywhere. There is no sync, no server, no analytics.
- The plugin never writes inside its own install directory (that directory is replaced on every update).
- Raw transcripts of past sessions are not copied into the file — only the evidence and reads you can see in `sessions.md`.

## The file contains personal signals

`sessions.md` is split into **EVIDENCE** (quotes of what you actually said) and **READS** (interpretations). Over time it can accumulate sensitive observations — including, by design, mental-health signals. Anyone with read access to your home directory can read it. If you sync `~/.claude/` to a backup or another machine, this file goes with it. Decide deliberately whether you want that.

## Deleting your data

```bash
rm -f ~/.claude/blindspot/sessions.md ~/.claude/blindspot/.last-nudge
# or remove everything:
rm -rf ~/.claude/blindspot
```

The skill recreates an empty file on next use.

## On the mental-health dimension

Blindspot is a mirror, not a clinician. It is built to *stop* analyzing and respond plainly when it detects distress, and to set the tool down entirely at any sign of self-harm (see the skill's "Hard stop: distress" section). It is not a substitute for professional support, a crisis line, or a person you trust. If you are struggling, reach out to one of those.
