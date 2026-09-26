# thangphan-dotfiles

Personal dotfiles. Currently ships Claude Code configuration and a bootstrap script that symlinks it into `~/.claude/`.

## Contents

- [What's inside](#whats-inside)
- [Quick start](#quick-start)
- [How it works](#how-it-works)

## What's inside

- `bootstrap.sh` - installer that symlinks the tracked files into `~/.claude/`.
- `claude/AGENTS.md` - global agent instructions (writing conventions, README rules).
- `claude/CLAUDE.md` - top-level Claude Code project file; imports `AGENTS.md`.
- `claude/settings.json` - Claude Code settings (model, status line, theme).
- `claude/skills/` - user skills, including vendored anthropic-skills under `synced/`.

## Quick start

```bash
git clone https://github.com/thangphan3000/thangphan-dotfiles.git
cd thangphan-dotfiles
./bootstrap.sh
```

The script is idempotent: rerun it any time to repair or refresh the links.

## How it works

`bootstrap.sh` walks a fixed list of items (`AGENTS.md`, `CLAUDE.md`, `settings.json`, `skills`) and, for each one, points `~/.claude/<item>` at `claude/<item>` in this repo. Anything already at the target path (regular file, directory, or wrong symlink) is removed before the new symlink is created, so no backup copy is kept.
