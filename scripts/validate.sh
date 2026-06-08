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
