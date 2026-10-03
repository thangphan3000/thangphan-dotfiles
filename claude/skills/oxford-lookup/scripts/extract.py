#!/usr/bin/env python3
"""Extract an Oxford Learner's Dictionary entry from a saved HTML page."""
import json, re, sys, html


def strip(s):
    s = re.sub(r"<[^>]+>", "", s)
    return html.unescape(s).strip()


def first(pat, s, flags=re.S):
    m = re.search(pat, s, flags)
    return m.group(1) if m else None


def find_senses(html_text):
    senses = []
    for block in re.findall(r'<li class="sense"[^>]*>(.*?)</li>', html_text, re.S):
        cefr = first(r'<span class="symbols"><a[^>]*class="[^"]*ox3ksym_([^ "]+)', block)
        grammar = first(r'<span class="grammar">(.*?)</span>', block)
        definition = first(r'<span class="def"[^>]*>(.*?)</span>', block)
        if not definition:
            continue
        examples = [strip(e) for e in re.findall(r'<span class="x">(.*?)</span>', block)][:2]
        senses.append({
            "cefr": cefr,
            "grammar": strip(grammar) if grammar else None,
            "definition": strip(definition),
            "examples": examples,
        })
    return senses


def extract(html_text):
    headword = first(r'<h1 class="headword"[^>]*>(.*?)</h1>', html_text)
    pos = first(r'<span class="pos"[^>]*>([^<]+)</span>', html_text)
    phon_br = first(r'class="phons_br"[^>]*>.*?class="phon"[^>]*>(.*?)</span>', html_text)
    phon_am = first(r'class="phons_n_am"[^>]*>.*?class="phon"[^>]*>(.*?)</span>', html_text)
    return {
        "headword": strip(headword) if headword else None,
        "pos": pos,
        "phon_br": strip(phon_br) if phon_br else None,
        "phon_am": strip(phon_am) if phon_am else None,
        "senses": find_senses(html_text),
    }


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: extract.py <path-to-html>", file=sys.stderr)
        sys.exit(2)
    with open(sys.argv[1], encoding="utf-8") as f:
        data = extract(f.read())
    if not data["headword"]:
        print(json.dumps({"error": "no entry parsed"}))
        sys.exit(1)
    print(json.dumps(data, ensure_ascii=False, indent=2))
