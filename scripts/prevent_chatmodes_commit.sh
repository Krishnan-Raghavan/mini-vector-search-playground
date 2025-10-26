#!/usr/bin/env bash
# Prevent commits that include files under .github/chatmodes/
set -euo pipefail

# List staged files
STAGED=$(git diff --cached --name-only --no-renames || true)

if echo "$STAGED" | grep -qE '^.github/chatmodes/'; then
  echo "" >&2
  echo "ERROR: Detected staged files in .github/chatmodes/." >&2
  echo "This folder is intended for local chatmode configs and should not be committed." >&2
  echo "If you need to add a template, use .github/chatmodes/example.chatmode.md or contact the maintainers." >&2
  echo "To continue without the hook, remove those files from the index (git reset <file>) or run 'git add -f' if you really intend to add them." >&2
  echo "" >&2
  exit 1
fi

exit 0
