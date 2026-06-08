#!/usr/bin/env bash
set -euo pipefail
#
# Local dev install: symlink this repo's skill into ~/.claude/skills so you can
# run /blindspot without going through the marketplace. Re-run after pulling.
#
# This installs ONLY the skill, not the SessionStart hook. To test the hook,
# install via the marketplace (see README) or wire it into settings.json by hand.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${HOME}/.claude/skills"

# Guard: if ~/.claude/skills is itself a symlink into this repo, bail out rather
# than writing per-skill links back into the working copy.
if [ -L "${DEST}" ]; then
  resolved="$(readlink "${DEST}")"
  case "${resolved}" in
    "${REPO}"|"${REPO}"/*)
      echo "error: ${DEST} is a symlink into this repo (${resolved})." >&2
      echo "Remove it (rm \"${DEST}\") and re-run." >&2
      exit 1
      ;;
  esac
fi

mkdir -p "${DEST}"

find "${REPO}/skills" -name SKILL.md -print0 |
while IFS= read -r -d '' skill_md; do
  src="$(dirname "${skill_md}")"
  name="$(basename "${src}")"
  target="${DEST}/${name}"

  if [ -e "${target}" ] && [ ! -L "${target}" ]; then
    rm -rf "${target}"
  fi
  ln -sfn "${src}" "${target}"
  echo "linked ${name} -> ${src}"
done

echo
echo "Done. Start a new Claude Code session and type /blindspot."
