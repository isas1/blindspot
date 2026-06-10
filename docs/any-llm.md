# Using Blindspot with any LLM

The `/blindspot` skill is built for Claude Code, but the mirror itself is just a prompt and a log. The [portable/](../portable/) folder contains two self-contained versions that work in any chat interface — ChatGPT, Claude.ai, Gemini, Copilot, a local model — with no plugin system and no filesystem access.

| File | Size | Use it when |
| --- | --- | --- |
| [portable/blindspot-prompt.md](../portable/blindspot-prompt.md) | ~8k chars | The full mirror. Paste into a chat at the end of a session, or install as standing instructions wherever the field allows it. |
| [portable/blindspot-compact.md](../portable/blindspot-compact.md) | ~1.6k chars | Condensed card for small custom-instruction fields. Same rules, same hard stop, less nuance. |

Both preserve the things that make Blindspot what it is: evidence-backed observations only, friction *and* progress, reason-carrying nudges instead of nags, and the distress/self-harm hard stop.

## The log ritual (this replaces the plugin's memory)

In Claude Code, Blindspot writes to `~/.claude/blindspot/sessions.md` itself. A chat interface can't do that, so **you** carry the memory:

1. Create a note anywhere you trust — `blindspot-log.md` in your notes app, a text file, a private doc. This is a journal; treat it like one (see [privacy.md](privacy.md)).
2. When you want a check-in, paste your log into the chat (or just start without one — the first run works fine empty).
3. Every check-in ends with a fenced `### <date> — <label>` block. Copy it to the bottom of your note.

That's the whole protocol: paste log in, copy entry out. EVIDENCE lines stay fact; READ lines get re-tested each time; a trend requires evidence across multiple dates — exactly as in the plugin.

## Two ways to run it

**A — Paste-in (works everywhere, best evidence).** At the end of a work conversation, paste the full prompt into the same chat. The paste itself is the trigger; the model runs the check-in on the conversation above it. This gives the mirror the richest evidence because it saw the actual work.

**B — Standing setup.** Install the prompt as persistent instructions (options below), do your work in that space, and say "blindspot check-in" when you want the mirror. The prompt stays dormant until asked — the portable equivalent of the plugin's manual-only design.

## Per-platform setup

Character limits below are as of mid-2026 and change without notice; if a paste fails, use the compact card or method A.

### ChatGPT

- **Projects** — create a project, put the full prompt in the project's instructions, work inside the project, say "blindspot check-in" at session end.
- **Custom GPT** — paste the full prompt into the GPT builder's Instructions field (limit ~8,000 chars; the full prompt fits) and keep your log as the first message of each conversation.
- **Custom instructions / personalization** — the fields are small; use the compact card.

### Claude.ai

- **Projects** — paste the full prompt into the project's custom instructions. Project knowledge can also hold your log file if you prefer uploading to pasting.
- **Paste-in** — works in any conversation, including on mobile.

### Google Gemini

- **Gems** — create a Gem with the full prompt as its instructions, paste your log at the start of a check-in.
- **Saved info** — too small for the full prompt; use the compact card if you want it always-on.

### Microsoft Copilot

No reliable long custom-instruction slot — use method A (paste the full prompt at the end of a session), or keep the compact card pinned somewhere convenient to paste.

### Local models (Ollama, LM Studio, Open WebUI, …)

Set the full prompt as the system prompt — `SYSTEM` block in an Ollama Modelfile, the system-prompt field in LM Studio or Open WebUI. No length concerns. One honest caveat: small local models follow the evidence discipline less reliably than frontier models — watch the first few check-ins for invented patterns, and prefer the full prompt over the compact one (it has more guardrails, not fewer).

## What changes vs. the Claude Code plugin

| | Plugin (`/blindspot`) | Portable |
| --- | --- | --- |
| Trigger | `/blindspot` slash command | "blindspot check-in", or the paste itself |
| Memory | Skill reads/writes `sessions.md` itself | You paste the log in, copy the entry out |
| Nudge | Optional gated SessionStart hook | None — use your own reminder if you want one |
| Evidence source | The Claude Code session | The current chat conversation |

The mirror's rules — evidence or it didn't happen, both directions, strain nudges that carry their reason, the hard stop — are identical by design. If you edit one version, mirror the change in the other (see [CLAUDE.md](../CLAUDE.md)).

## A note on the hard stop

Every version of Blindspot, portable ones included, is built to stop analyzing the moment real distress shows and to set the tool down entirely at any sign of self-harm. No LLM is a substitute for professional support, a crisis line, or a person you trust. If you are struggling, reach out to one of those.
