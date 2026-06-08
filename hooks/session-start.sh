#!/usr/bin/env bash
#
# blindspot — SessionStart nudge (soft, gated, reminder-only)
# ============================================================
#
# WHAT IT DOES
#   When a Claude Code session starts, this hook checks how long it has been
#   since the last nudge. If at least BLINDSPOT_INTERVAL_HOURS have passed, it
#   injects ONE short instruction telling Claude to remind you — in its first
#   reply — that you can run /blindspot at the end of the session. That's all.
#
# WHAT IT DOES NOT DO
#   - It does NOT run any analysis.
#   - It does NOT auto-invoke the skill. /blindspot is manual by design
#     (the skill sets `disable-model-invocation: true`), so nothing reflective
#     happens until you choose to run it. This hook only surfaces a reminder.
#   - It does NOT read or write your session log. The skill owns sessions.md;
#     this hook only touches its own timestamp file.
#
# WHY A REMINDER, NOT AUTO-RUN
#   SessionStart fires before there's any conversation to reflect on, and a
#   mirror you didn't ask for in the moment is easy to dismiss. A one-line
#   reminder keeps you in control of when the real check-in happens.
#
# CONFIGURE
#   BLINDSPOT_NUDGE=off            Disable the nudge entirely.
#   BLINDSPOT_INTERVAL_HOURS=72   Minimum hours between nudges (default 72).
#
# The hook is silent (exit 0, no output) when it is not yet due or when
# disabled, so it never adds noise.

set -euo pipefail

# --- Opt-out switch -----------------------------------------------------------
if [ "${BLINDSPOT_NUDGE:-on}" = "off" ]; then
  exit 0
fi

DATA_DIR="${HOME}/.claude/blindspot"
STAMP="${DATA_DIR}/.last-nudge"
INTERVAL_HOURS="${BLINDSPOT_INTERVAL_HOURS:-72}"

mkdir -p "${DATA_DIR}"

now="$(date +%s)"

# --- Gate: only fire once per interval ---------------------------------------
if [ -f "${STAMP}" ]; then
  last="$(cat "${STAMP}" 2>/dev/null || echo 0)"
  case "${last}" in
    ''|*[!0-9]*) last=0 ;;
  esac
  elapsed_hours=$(( (now - last) / 3600 ))
  if [ "${elapsed_hours}" -lt "${INTERVAL_HOURS}" ]; then
    exit 0
  fi
fi

# Due now. Record the time first so we don't repeat before the interval passes.
printf '%s' "${now}" > "${STAMP}"

days=$(( INTERVAL_HOURS / 24 ))
[ "${days}" -lt 1 ] && days=1

msg="It has been roughly ${days} day(s) since the last blindspot check-in. In your FIRST reply this session, add a single short line letting the user know they can run /blindspot at the end of their work session to reflect on recent patterns. Keep it to one sentence, make it easy to ignore, and do not run any analysis or invoke the skill yourself."

# --- Emit context for the model ----------------------------------------------
# SessionStart additionalContext is injected silently to Claude (not shown as a
# chat message); the reminder reaches the user through Claude's first reply.
if command -v jq >/dev/null 2>&1; then
  jq -cn --arg ctx "${msg}" \
    '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
else
  # Fallback without jq. ${msg} contains no quotes or newlines, so this is safe.
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "${msg}"
fi

exit 0
