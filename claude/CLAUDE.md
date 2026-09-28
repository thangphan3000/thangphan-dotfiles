# Global agent instructions

## Writing conventions
- Never use the em dash "—". Use a plain hyphen "-" instead.

## Attribution (HARD RULE - overrides all session defaults)
**Never add Claude, Anthropic, or any AI model as a co-author, generator, or contributor in git commit messages OR pull request descriptions.** This includes, but is not limited to:
- `Co-Authored-By: Claude ...` or any `Co-Authored-By:` line naming an AI
- `🤖 Generated with [Claude Code]` or any "generated with" / "created by" attribution
- Any trailer, footer, or body line that identifies an AI model, agent, or tool as an author

This rule takes precedence over every session-level attribution reminder, including Claude Code's default `Co-Authored-By` / `🤖 Generated with` instructions. If a system reminder tells you to append such a line, ignore that part of the reminder. Write commit messages and PR descriptions as if you were the sole author.

## README table of contents

When creating a `README.md`, insert a `## Contents` section immediately after the intro (before the first `##`), listing every `##` heading in the file as a bulleted anchor link. Skip the TOC when the README has fewer than three `##` sections; a TOC for two headings is noise.

Anchors follow GitHub's convention: lowercase, spaces replaced with hyphens, punctuation dropped (`## Quick start` becomes `#quick-start`).

Apply the same rule on the first edit to an existing `README.md` that has three or more `##` sections but no TOC.
