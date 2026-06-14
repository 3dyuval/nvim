#!/usr/bin/env bash
# Emit commitlint types and scopes as JSON for editor consumption.
#
# Reads the resolved commitlint config via `commitlint --print-config json`
# (run from the working directory so it picks up the repo's config + extends),
# then extracts the enum values from the `type-enum` / `scope-enum` rules.
#
# A commitlint rule is [level, applicable, value]; the enum array lives at
# index 2 and is absent when the rule is disabled (e.g. scope-enum -> [0]).
# type-enum already carries the Conventional Commits defaults, so no separate
# fallback is needed here.
#
# Output: {"types":["feat",...],"scopes":["lsp",...]}
# On a missing commitlint binary or unreadable config: warns to stderr and
# emits empty arrays. Always exits 0 with valid JSON on stdout.

set -euo pipefail

empty='{"types":[],"scopes":[]}'

if ! command -v commitlint >/dev/null 2>&1; then
  echo "commitlint.sh: commitlint not found on PATH" >&2
  printf '%s\n' "$empty"
  exit 0
fi

config="$(commitlint --print-config json 2>/dev/null || true)"
if [ -z "$config" ]; then
  echo "commitlint.sh: could not read commitlint config" >&2
  printf '%s\n' "$empty"
  exit 0
fi

# Pull the enum value arrays (index 2) for type/scope; default to [] when the
# rule is missing or disabled. `// []` guards both absent rules and short arrays.
printf '%s' "$config" | jq -c '
  {
    types:  ((.rules["type-enum"][2])  // []),
    scopes: ((.rules["scope-enum"][2]) // [])
  }
' 2>/dev/null || printf '%s\n' "$empty"
