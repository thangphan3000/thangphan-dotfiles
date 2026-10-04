# thangphan-dotfiles

Personal dotfiles. Ships Claude Code, tmux, and Neovim configuration plus a bootstrap script that symlinks each one into the right XDG location.

## Contents

- [What's inside](#whats-inside)
- [Quick start](#quick-start)
- [How it works](#how-it-works)

## What's inside

- `bootstrap.sh` - installer that symlinks every tracked file into its destination.
- `claude/` - Claude Code config: `AGENTS.md`, `CLAUDE.md`, `settings.json`, `skills/` and `agents/` (custom sub-agents).
- `tmux/` - `tmux.conf` and `themes/` (dank, nord, catppuccin latte/mocha).
- `nvim/` - Neovim config (`init.lua`, `lua/`, `snippets/`, `lazy-lock.json`).

## Quick start

```bash
git clone https://github.com/thangphan3000/thangphan-dotfiles.git
cd thangphan-dotfiles
./bootstrap.sh
```

The script is idempotent: rerun it any time to repair or refresh the links.

## How it works

`bootstrap.sh` walks a `source:destination` mapping and, for each entry, symlinks the target path to the tracked file or folder in this repo:

| Source in repo | Destination |
| --- | --- |
| `claude/AGENTS.md` | `~/.claude/AGENTS.md` |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `claude/skills` | `~/.claude/skills` |
| `claude/agents` | `~/.claude/agents` |
| `tmux` | `~/.config/tmux` |
| `nvim` | `~/.config/nvim` |

Anything already at a destination (regular file, directory, or wrong symlink) is removed before the new symlink is created, so no backup copy is kept. Parent directories are created as needed.

If a legacy `~/.tmux.conf` still exists, tmux will read that instead of the XDG config; remove it so `~/.config/tmux/tmux.conf` wins.
