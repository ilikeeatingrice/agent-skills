#!/usr/bin/env bash
# Install these skills as .claude/skills + .codex/skills twins.
#
#   ./install.sh                     -> user level (~/.claude, ~/.codex)
#   ./install.sh /path/to/repo       -> project level (<repo>/.claude, <repo>/.codex)
#   ./install.sh . tdd brainstorming -> only the named skills
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
[[ -d $src ]] || { echo "no skills/ next to install.sh" >&2; exit 1; }

target="${1:-}"
if [[ -z $target ]]; then
  base_claude="$HOME/.claude"; base_codex="$HOME/.codex"; label="user level"
else
  target="$(cd "$target" && pwd)"
  base_claude="$target/.claude"; base_codex="$target/.codex"; label="$target"
fi
shift || true

if (($#)); then
  names=("$@")
  for n in "${names[@]}"; do
    [[ -d "$src/$n" ]] || { echo "no such skill: $n" >&2; exit 1; }
  done
else
  names=(); for d in "$src"/*/; do names+=("$(basename "$d")"); done
fi

for harness in "$base_claude" "$base_codex"; do
  mkdir -p "$harness/skills"
  for n in "${names[@]}"; do
    rm -rf "$harness/skills/$n"
    cp -r "$src/$n" "$harness/skills/$n"
  done
done

# The twins must stay byte-identical; a silent drift here is a real bug.
for n in "${names[@]}"; do
  if ! diff -rq "$base_claude/skills/$n" "$base_codex/skills/$n" >/dev/null; then
    echo "TWIN MISMATCH: $n" >&2; exit 1
  fi
done

echo "installed ${#names[@]} skills to $label (.claude + .codex twins verified)"
printf '  %s\n' "${names[@]}"
