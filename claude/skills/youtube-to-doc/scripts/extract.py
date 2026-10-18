#!/usr/bin/env python3
"""Inside-container extractor: yt-dlp -> transcript.txt + meta.json."""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

from langdetect import detect, DetectorFactory

DetectorFactory.seed = 0

OUT = Path("/work")


def run(cmd: list[str]) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=True, capture_output=True, text=True)


YTDLP_JS = [
    "--js-runtimes", "node",
    "--impersonate", "chrome",
    "--retries", "10",
    "--retry-sleep", "exp=1:30",
    "--extractor-retries", "5",
    "--sleep-subtitles", "2",
]


def fetch_metadata(url: str) -> dict:
    r = run(["yt-dlp", "-J", "--no-warnings", "--no-playlist", *YTDLP_JS, "--skip-download", url])
    return json.loads(r.stdout)


def try_subtitles(url: str) -> tuple[str | None, str | None]:
    """Return (text, lang) if subtitles found, else (None, None)."""
    sub_dir = OUT / "_subs"
    sub_dir.mkdir(exist_ok=True)
    cmd = [
        "yt-dlp",
        "--no-playlist",
        *YTDLP_JS,
        "--skip-download",
        "--write-subs",
        "--write-auto-subs",
        "--sub-langs", ".*-orig",
        "--ignore-errors",
        "--sub-format", "vtt/best",
        "--convert-subs", "vtt",
        "-o", str(sub_dir / "%(id)s.%(ext)s"),
        url,
    ]
    res = subprocess.run(cmd, check=False, capture_output=True, text=True)
    vtts = sorted(sub_dir.glob("*.vtt"))
    if not vtts:
        print(f"[extract] yt-dlp sub stdout tail: {res.stdout[-500:]}", file=sys.stderr)
        print(f"[extract] yt-dlp sub stderr tail: {res.stderr[-500:]}", file=sys.stderr)
        return None, None
    # prefer english if present
    en = [p for p in vtts if ".en" in p.name]
    chosen = en[0] if en else vtts[0]
    text = vtt_to_text(chosen.read_text(encoding="utf-8", errors="replace"))
    m = re.search(r"\.([a-zA-Z-]+)\.vtt$", chosen.name)
    lang_tag = m.group(1) if m else "unknown"
    return text, lang_tag


_VTT_TIMING = re.compile(r"^\d\d:\d\d:\d\d\.\d{3} --> ")
_TAG = re.compile(r"<[^>]+>")


def vtt_to_text(vtt: str) -> str:
    lines: list[str] = []
    seen: set[str] = set()
    for raw in vtt.splitlines():
        line = raw.strip()
        if not line or line == "WEBVTT" or line.startswith("Kind:") or line.startswith("Language:"):
            continue
        if _VTT_TIMING.match(line) or "-->" in line:
            continue
        if line.isdigit():
            continue
        clean = _TAG.sub("", line).strip()
        if not clean or clean in seen:
            continue
        seen.add(clean)
        lines.append(clean)
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("url")
    args = ap.parse_args()

    meta = fetch_metadata(args.url)
    available_subs = sorted(set(meta.get("subtitles", {}).keys()) | set(meta.get("automatic_captions", {}).keys()))
    print(f"[extract] subtitle langs available: {available_subs[:20]}", file=sys.stderr)

    text, lang_tag = try_subtitles(args.url)
    source = "subtitles"
    if not text:
        print(
            "[extract] no subtitles usable. This skill extracts captions only; "
            "video has no manual/auto subs or yt-dlp could not fetch them.",
            file=sys.stderr,
        )
        sys.exit(2)

    # normalize language to primary tag
    primary = (lang_tag or "").split("-")[0].lower() or "unknown"
    if primary == "unknown" and text:
        try:
            primary = detect(text[:4000])
        except Exception:
            primary = "unknown"

    out_meta = {
        "title": meta.get("title"),
        "uploader": meta.get("uploader") or meta.get("channel"),
        "duration": meta.get("duration"),
        "duration_string": meta.get("duration_string"),
        "upload_date": meta.get("upload_date"),
        "description": meta.get("description"),
        "url": meta.get("webpage_url") or args.url,
        "detected_language": primary,
        "transcript_source": source,
    }
    (OUT / "meta.json").write_text(json.dumps(out_meta, indent=2, ensure_ascii=False))
    (OUT / "transcript.txt").write_text(text or "")
    print(f"[extract] done lang={primary} source={source} chars={len(text or '')}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
