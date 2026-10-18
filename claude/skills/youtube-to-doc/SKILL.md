---
name: youtube-to-doc
description: Convert a YouTube video into readable Markdown documentation using yt-dlp inside a disposable Docker container. Use when the user gives a YouTube URL and asks to "document", "transcribe", "summarize into docs", "turn into notes/markdown/README", or invokes /youtube-to-doc. Pulls subtitles + metadata, detects language, keeps English as-is, otherwise translates to English before formatting.
---

# youtube-to-doc

Converts a YouTube video to Markdown docs. All heavy lifting (yt-dlp, ffmpeg, language detection) runs inside a one-shot Docker container that is removed after the run.

## When to use

User gives a YouTube URL and wants readable text/docs from it. Not for downloading the video itself.

## Pipeline

1. Receive YouTube URL from the user.
2. Run `scripts/run.sh <url> <out_dir>` - builds (if missing) and runs the Docker container, mounts `<out_dir>`, extracts subtitles + metadata, writes:
   - `<out_dir>/meta.json` - title, uploader, duration, description, url, detected_language
   - `<out_dir>/transcript.txt` - plain-text transcript (subtitles stripped of timing)
3. Read `meta.json`. If `detected_language == "en"` use `transcript.txt` as-is. Otherwise translate `transcript.txt` to English yourself before formatting.
4. Produce a Markdown document with this structure, written to `<out_dir>/documentation.md`:
   ```
   # <title>

   **Source:** <url>
   **Channel:** <uploader>
   **Duration:** <duration>
   **Original language:** <lang> (translated to English if not en)

   ## Summary
   <2-4 sentence overview>

   ## Key points
   - <bullet>
   - <bullet>

   ## Full transcript (cleaned)
   <paragraph-formatted transcript, English>
   ```
5. The container is started with `--rm` so it is removed on exit. After the pipeline completes, also run `scripts/cleanup.sh` to drop the image.

## Invocation

```
bash .claude/skills/youtube-to-doc/scripts/run.sh "<youtube-url>" "<out_dir>"
```

Use the session scratchpad as `<out_dir>` unless the user names another location.

After reading outputs and writing `documentation.md`, run:

```
bash .claude/skills/youtube-to-doc/scripts/cleanup.sh
```

## Notes

- If yt-dlp finds no subtitles (manual or auto), the script exits with code 2 and prints the languages it saw. Tell the user the video has no captions - this skill does not transcribe audio.
- Never commit `<out_dir>` artifacts to git unless asked.
- Do not pass `--no-rm` or keep the container around; the whole point is a disposable run.
