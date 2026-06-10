#!/usr/bin/env bash
set -uo pipefail
#
# Lightweight, dependency-free validator for the blindspot plugin.
# Checks the things that silently break a plugin: skill frontmatter, name/dir
# match, description length, JSON validity, and hook executability.
# Exit 0 = all clear, 1 = one or more errors.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
errors=0
warns=0

err()  { printf '  \033[31m✗\033[0m %s\n' "$1"; errors=$((errors + 1)); }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; warns=$((warns + 1)); }

echo "Validating blindspot plugin at ${REPO}"
echo

# --- Skills ------------------------------------------------------------------
echo "Skills:"
found_skill=0
while IFS= read -r -d '' skill_md; do
  found_skill=1
  dir="$(dirname "${skill_md}")"
  dirname_base="$(basename "${dir}")"

  # Extract YAML frontmatter (between the first two '---' lines).
  fm="$(awk 'NR==1 && $0=="---"{f=1; next} f && $0=="---"{exit} f{print}' "${skill_md}")"

  name="$(printf '%s\n' "${fm}" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
  desc="$(printf '%s\n' "${fm}" | sed -n 's/^description:[[:space:]]*//p' | head -1)"

  if [ -z "${name}" ]; then
    err "${dirname_base}: missing 'name' in frontmatter"
  elif [ "${name}" != "${dirname_base}" ]; then
    err "${dirname_base}: frontmatter name '${name}' != directory name"
  else
    ok "${dirname_base}: name matches directory"
  fi

  if [ -z "${desc}" ]; then
    err "${dirname_base}: missing 'description' in frontmatter"
  else
    len="${#desc}"
    if [ "${len}" -gt 1024 ]; then
      err "${dirname_base}: description is ${len} chars (max 1024)"
    else
      ok "${dirname_base}: description ok (${len} chars)"
    fi
  fi
done < <(find "${REPO}/skills" -name SKILL.md -print0 2>/dev/null)
[ "${found_skill}" -eq 0 ] && err "no SKILL.md found under skills/"
echo

# --- JSON --------------------------------------------------------------------
echo "JSON:"
for j in ".claude-plugin/plugin.json" ".claude-plugin/marketplace.json" "hooks/hooks.json"; do
  path="${REPO}/${j}"
  if [ ! -f "${path}" ]; then
    err "${j}: missing"
  elif command -v jq >/dev/null 2>&1; then
    if jq empty "${path}" >/dev/null 2>&1; then
      ok "${j}: valid JSON"
    else
      err "${j}: invalid JSON"
    fi
  else
    warn "${j}: present (install jq to validate syntax)"
  fi
done
echo

# --- Portable prompts ----------------------------------------------------------
# The portable versions must exist, fit their platform budgets, and preserve the
# self-harm hard-stop invariant ("overrides everything" + pointing to a crisis
# line). The budgets: full prompt <= 8000 chars (Custom GPT instructions field),
# compact card <= 1600 chars (small custom-instruction fields).
# Budgets are measured in BYTES (wc -c) on purpose: bytes are a strict upper
# bound on characters, so the check can fail early but never pass a file that
# is too big — and unlike `wc -m`, the result doesn't change with locale
# (under LC_ALL=C, wc -m silently counts bytes anyway).
echo "Portable:"
check_invariants() {
  f="$1"; label="$2"
  if grep -qi 'overrides everything' "${f}" && grep -qi 'crisis line' "${f}"; then
    ok "${label}: self-harm hard-stop invariant present"
  else
    err "${label}: missing self-harm hard-stop invariant ('overrides everything' + 'crisis line')"
  fi
}

full="${REPO}/portable/blindspot-prompt.md"
compact="${REPO}/portable/blindspot-compact.md"

if [ ! -f "${full}" ]; then
  err "portable/blindspot-prompt.md: missing"
else
  size=$(wc -c < "${full}" | tr -d ' ')
  if [ "${size}" -gt 8000 ]; then
    err "portable/blindspot-prompt.md: ${size} chars (budget 8000 — Custom GPT limit)"
  else
    ok "portable/blindspot-prompt.md: ${size} chars (budget 8000)"
  fi
  check_invariants "${full}" "portable/blindspot-prompt.md"
fi

if [ ! -f "${compact}" ]; then
  err "portable/blindspot-compact.md: missing"
else
  size=$(wc -c < "${compact}" | tr -d ' ')
  if [ "${size}" -gt 1600 ]; then
    err "portable/blindspot-compact.md: ${size} chars (budget 1600)"
  else
    ok "portable/blindspot-compact.md: ${size} chars (budget 1600)"
  fi
  check_invariants "${compact}" "portable/blindspot-compact.md"
fi

skill_md="${REPO}/skills/blindspot/SKILL.md"
[ -f "${skill_md}" ] && check_invariants "${skill_md}" "skills/blindspot/SKILL.md"
echo

# --- Hook --------------------------------------------------------------------
echo "Hook:"
hook="${REPO}/hooks/session-start.sh"
if [ ! -f "${hook}" ]; then
  err "hooks/session-start.sh: missing"
else
  ok "hooks/session-start.sh: present"
  if [ -x "${hook}" ]; then
    ok "hooks/session-start.sh: executable"
  else
    warn "hooks/session-start.sh: not executable (run: chmod +x hooks/session-start.sh)"
  fi
fi
echo

# --- Summary -----------------------------------------------------------------
echo "----------------------------------------"
if [ "${errors}" -eq 0 ]; then
  printf '\033[32mPASS\033[0m — %d warning(s)\n' "${warns}"
  exit 0
else
  printf '\033[31mFAIL\033[0m — %d error(s), %d warning(s)\n' "${errors}" "${warns}"
  exit 1
fi
