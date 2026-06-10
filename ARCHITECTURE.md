# Architecture

How Blindspot is structured, what changed in v0.3.0 (the "any LLM" release), and why each decision went the way it did. The product idea is unchanged throughout: a mirror that reflects the user's own patterns back to them, backed only by their own words, with a strain tier for sustainable pace and a hard stop for distress.

## The three-artifact model

One mirror, three deliveries:

| Artifact | Runs where | Trigger | Memory |
| --- | --- | --- | --- |
| `skills/blindspot/SKILL.md` | Claude Code (marketplace plugin) | `/blindspot`, manual-only | Skill reads/writes `~/.claude/blindspot/sessions.md` itself |
| `portable/blindspot-prompt.md` | Any LLM — paste-in, ChatGPT Project/Custom GPT, Claude.ai Project, Gemini Gem, local system prompt | "blindspot check-in", or the paste itself when it lands after visible work | User-carried log note: paste in, copy entry out |
| `portable/blindspot-compact.md` | Small custom-instruction fields | Same as full prompt | Same as full prompt |

They must stay behaviorally in sync — same evidence rules, same strain tier, same hard stop. `CLAUDE.md` states the rule; `scripts/validate.sh` enforces the mechanical part (presence, size budgets, hard-stop invariant grep). The grep is a tripwire, not a guarantee: a human (or agent) must re-read the distress sections after any edit.

**Why duplication instead of a single shared core file?** A skill that has to `Read` a sibling file to know its own rules adds a failure mode (file missing, path wrong, partial load) to a document that handles self-harm signals. A paste-able prompt by definition must be one self-contained block. So each artifact is complete on its own, and sync is enforced socially (CLAUDE.md) plus mechanically (validate.sh).

## Decisions and why (v0.3.0)

### 1. Memory becomes a user-carried log

Outside Claude Code there is no filesystem, so the portable versions invert ownership: the **user** keeps a note, pastes it at check-in, and copies a fenced log entry back out. The entry format unifies EVIDENCE (fact), READ (interpretation + confidence), and REJECTED (calibration) per dated entry — append-only, because asking users to merge edits into two separate sections (the plugin's layout) fails in a copy-paste workflow. The plugin's `sessions.md` format is unchanged to avoid breaking existing logs.

### 2. Dormancy = the portable `disable-model-invocation: true`

The plugin is manual-only by frontmatter. The portable prompts can't be, so they encode it as behavior: stay dormant, be a normal assistant, never analyze mid-work. This preserves the core design stance — a mirror you didn't ask for is easy to dismiss.

### 3. The setup-vs-request discriminator

A paste-able prompt needs the paste itself to trigger the check-in (nobody pastes 8k chars and then types a second message), but the same file installed as standing instructions must NOT self-fire. The review panel flagged that "pasted at the end of a session" is too implicit for mid-tier models — many platforms inject system instructions as a leading user message. Resolution: a mechanical rule in both portable files — *present from the start = setup, stay dormant; arrives after work you can see above it = run now; empty chat = say you're ready*. The compact card initially had no paste semantics at all (three reviewers caught the docs promising behavior the card didn't have); it now carries the same one-line rule.

### 4. Date honesty

Dates are load-bearing: "a pattern is only a trend with EVIDENCE across multiple dates." Local models (an explicitly supported target) don't know today's date and will hallucinate one, silently corrupting trend detection. Both portable versions now instruct: don't guess the date — ask, or leave the placeholder. Same reasoning behind removing elapsed-time examples ("3x in 30 min" → "3x"): chat models can't see timestamps, and an example that models unknowable evidence trains the exact fabrication the prompt forbids.

### 5. An explicit "no clear pattern" exit

The prose said "no clear pattern is a valid output," but the output format mandated filled slots — format pressure beats prose rules in small models, producing confabulated patterns. The output section now gives a mechanical escape: write "no clear pattern this time", skip Read/Worth-considering, still log EVIDENCE. Mirrored into SKILL.md (same gap existed there).

### 6. The hard stop cancels the log entry

Compression in the compact card had dropped "do not fold it into a pattern" while separately mandating a log block after *every* check-in — a model could read that as "respond with care, then still record the self-harm words under EVIDENCE." All three artifacts now make it explicit: a check-in that ends in the hard stop produces no log entry. This was the single most important review finding; the compact card is the easiest place to weaken the hard stop while trimming for length, which is why CLAUDE.md now calls that out.

### 7. Size budgets

Full prompt ≤ 8,000 chars (the commonly documented Custom GPT instructions limit — the binding external constraint); compact ≤ 1,600 chars (conservative fit for small custom-instruction fields). Enforced by validate.sh as errors, not warnings, so a "small wording improvement" that silently breaks platform fit fails the build. Current: full 7,959 / compact ~1,594. The full prompt is near its ceiling — future edits must trade words, not add them.

### 8. Validator as sync tripwire

`scripts/validate.sh` gained a "Portable:" section: file presence, the two budgets, and a grep that all three artifacts contain the self-harm invariant ("overrides everything" + "crisis line"). Deliberately crude — it catches deletion and truncation, not semantic weakening; that's what the re-read rule in CLAUDE.md is for.

## Review process (how v0.3.0 was checked)

A 5-lens adversarial agent panel reviewed the portable files and docs: **safety fidelity** (hard-stop intent preserved, nothing scored/pattern-matched), **skill parity** (nothing load-bearing lost vs SKILL.md), **portability** (works stateless, no Claude-Code-isms), **prompt quality for weaker models** (mechanical followability), and **docs accuracy** (links, counts, claims). It returned 20 findings (8 medium, 12 low); all were applied except where reviewers conflicted — the compact paste-trigger disagreement was resolved with the discriminator in §3, which satisfies both sides (self-triggers on paste-after-work, inert as standing instructions).

## Open items

- **Second review round not run** — fixes were applied after one panel round; a re-run of the same panel (script saved in the session's workflow dir; recreatable from the lens descriptions above) would confirm no fix introduced a regression. The validator passes and the hard-stop sections were re-read by hand.
- **Platform limits unverified** — a research agent for current (2026) ChatGPT/Gemini/Copilot instruction-field limits died on a session limit. `docs/any-llm.md` hedges all numbers ("as of mid-2026, change without notice") and only hard-commits to the 8,000-char Custom GPT figure. Worth a quick re-verify before publishing.
- **Live smoke test pending** — paste `portable/blindspot-prompt.md` at the end of a real session in ChatGPT/Gemini and confirm: check-in runs on paste, log block is fenced, no date guessed, dormancy holds when installed as standing instructions.
