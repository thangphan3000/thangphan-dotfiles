#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LINKS=(
  "claude/CLAUDE.md:${HOME}/.claude/CLAUDE.md"
  "claude/settings.json:${HOME}/.claude/settings.json"
  "claude/statusline.sh:${HOME}/.claude/statusline.sh"
  "claude/skills:${HOME}/.claude/skills"
  "tmux:${HOME}/.config/tmux"
  "tmux/tmux.conf:${HOME}/.tmux.conf"
  ".gitconfig:${HOME}/.gitconfig"
  ".git-hooks:${HOME}/.git-hooks"
  "nvim:${HOME}/.config/nvim"
)

link_one() {
  local rel_src="$1"
  local dst="$2"
  local src="${DOTFILES_DIR}/${rel_src}"

  if [[ ! -e "${src}" ]]; then
    echo "skip ${rel_src}: source missing at ${src}"
    return
  fi

  mkdir -p "$(dirname "${dst}")"

  if [[ -L "${dst}" ]]; then
    local current
    current="$(readlink "${dst}")"
    if [[ "${current}" == "${src}" ]]; then
      echo "ok   ${dst} -> ${src}"
      return
    fi
    rm "${dst}"
  elif [[ -e "${dst}" ]]; then
    rm -rf "${dst}"
  fi

  ln -s "${src}" "${dst}"
  echo "link ${dst} -> ${src}"
}

for entry in "${LINKS[@]}"; do
  rel_src="${entry%%:*}"
  dst="${entry#*:}"
  link_one "${rel_src}" "${dst}"
done

echo "done."
