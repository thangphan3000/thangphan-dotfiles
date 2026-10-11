# Global agent instructions

## Writing conventions
- Never use the em dash "—". Use a plain hyphen "-" instead.
- When reporting information to me, be extremely concise and sacrifice grammar for sake of concision.

## Solution preference
- Prefer built-in or existing functionality over writing new code. When suggesting a solution, check the tool/language/framework for a built-in option first and recommend that. Only write a new script, function, or wrapper when no built-in or existing equivalent exists, and say explicitly why the built-in doesn't fit.

## README table of contents

When creating a `README.md`, insert a `## Contents` section immediately after the intro (before the first `##`), listing every `##` heading in the file as a bulleted anchor link. Skip the TOC when the README has fewer than three `##` sections; a TOC for two headings is noise.

Anchors follow GitHub's convention: lowercase, spaces replaced with hyphens, punctuation dropped (`## Quick start` becomes `#quick-start`).

Apply the same rule on the first edit to an existing `README.md` that has three or more `##` sections but no TOC.
