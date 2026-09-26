#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${DOTFILES_DIR}/claude"
CLAUDE_DIR="${HOME}/.claude"

ITEMS=(AGENTS.md CLAUDE.md settings.json skills)

mkdir -p "${CLAUDE_DIR}"

link_item() {
  local name="$1"
  local src="${SRC_DIR}/${name}"
  local dst="${CLAUDE_DIR}/${name}"

  if [[ ! -e "${src}" ]]; then
    echo "skip ${name}: source missing at ${src}"
    return
  fi

  if [[ -L "${dst}" ]]; then
    local current
    current="$(readlink "${dst}")"
    if [[ "${current}" == "${src}" ]]; then
      echo "ok   ${name}: already linked"
      return
    fi
    rm "${dst}"
  elif [[ -e "${dst}" ]]; then
    rm -rf "${dst}"
  fi

  ln -s "${src}" "${dst}"
  echo "link ${name} -> ${src}"
}

for item in "${ITEMS[@]}"; do
  link_item "${item}"
done

echo "done."
