---
name: oxford-lookup
description: Look up meaning, pronunciation, and examples of an English word from oxfordlearnersdictionaries.com. Use when the user asks for the definition, meaning, pronunciation, example sentences, or part of speech of an English word, or says things like "what does X mean", "define X", "look up X", "/oxford X".
---

# Oxford Learner's Dictionary lookup

Fetch and extract a word's entry from `https://www.oxfordlearnersdictionaries.com/definition/english/<slug>`, then report it concisely.

## Steps

1. **Build the URL.** Slug = lowercase word, spaces replaced with hyphens, no punctuation. If the user hints at a specific entry (noun vs verb, sense number), try that slug first, e.g. `run_1`, `run_2`. On a 404, try `<word>_1`, then without the suffix.

2. **Fetch the page.** Use `Bash` with `curl`:
   ```
   curl -sL -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
     "https://www.oxfordlearnersdictionaries.com/definition/english/<slug>" \
     -o "$TMPDIR/oxford_<slug>.html" -w "%{http_code}\n" --max-time 20
   ```
   Pass `allowed_domains: ["www.oxfordlearnersdictionaries.com"]`. HTTP 200 = found; 404 = try an alternate slug; other = tell the user plainly.

3. **Extract.** Run `python3 scripts/extract.py "$TMPDIR/oxford_<slug>.html"`. It prints JSON with `headword`, `pos`, `phon_br`, `phon_am`, and `senses` (each with `grammar`, `cefr`, `definition`, `examples`).

4. **Report.** Format like:
   ```
   **word** /brPhon/ US /amPhon/  pos
   1. (cefr) definition
      - example
   2. ...
   ```
   Keep it tight. Always include the full source URL (`https://www.oxfordlearnersdictionaries.com/definition/english/<slug>`) at the bottom so the user can click through to play the audio pronunciation on the page. If multiple entries exist on the page, note the other suffixes (e.g. "see also `<word>_2` for the verb").

## Notes

- Only use this skill for English word lookups. For translations or other languages, say so and stop.
- Do not cache results across sessions; always refetch.
- If the sandbox blocks the host, tell the user to allow `www.oxfordlearnersdictionaries.com`.
