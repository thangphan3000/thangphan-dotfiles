---
name: prepositions
description: Show a visual chart of English prepositions of place and movement (at, in, on, under, over, between, among, around, into, upon, towards, through, along, across, from-to, before, behind, away, out of, within, beside, above, below) and explain each one in English. Use this skill whenever the user asks about English prepositions, prepositions of place, prepositions of movement, how to use "in" vs "on" vs "at", spatial prepositions, directional prepositions, or says things like "explain prepositions", "/prepositions", "preposition cheat sheet", or asks what a specific preposition from the chart means. Trigger even if the user doesn't explicitly say the word "chart" or "image".
---

# Prepositions

Help the user learn English prepositions using the visual chart in `assets/prepositions.webp`.

## How to respond

1. **Show the right image once, at the start.** Use `SendUserFile` with `display: "render"`, before the text. Pick the file this way:
   - **Specific preposition** (e.g. `/prepositions into`, "what does upon mean?") - send only that one preposition's cell: `assets/<name>.png`. Normalize the name to lowercase and replace spaces with hyphens: `into` → `into.png`, `out of` → `out-of.png`, `from to` / `from-to` → `from-to.png`. Available: at, in, on, under, over, between, among, around, into, upon, towards, through, along, across, from-to, before, behind, away, out-of, within, beside, above, below.
   - **General overview** ("explain prepositions", bare `/prepositions`) - send the full chart `assets/prepositions.webp`.
   - Send exactly one image per response. Do not resend if the same image was already shown earlier in the conversation unless the user asks to see it again.
   - If the user asks about a word that is not in the list above, skip the image and say so.

2. **Explain in English only.** The user is studying English, so never translate to Vietnamese or any other language, even though the chart itself has Vietnamese glosses. Keep every explanation in plain, clear English.

3. **Match depth to the request.**
   - If the user asks generally ("explain prepositions", "/prepositions"), send the image and give a short overview grouped by meaning: position (at, in, on, under, over, above, below, beside, between, among, within), movement/direction (into, out of, towards, away, through, across, along, around, from-to), and order (before, behind, upon).
   - If the user asks about a specific preposition (e.g. "what does 'upon' mean?"), send only that word's cell image, then focus on that word: definition, **exactly 2 natural example sentences**, and a note on common confusions (e.g. in vs on vs at, between vs among, above vs over, below vs under).

4. **Use concrete example sentences.** Prepositions are easier to feel than to define, so prefer short real-world examples over abstract definitions. Give **exactly 2 examples per preposition** - not one, not three.

5. **Point out common pairs that confuse learners** when relevant:
   - *in* (enclosed space) vs *on* (surface) vs *at* (point)
   - *between* (two or clearly separated items) vs *among* (a group)
   - *over* / *above* (above, over can imply movement or covering) vs *under* / *below*
   - *into* / *out of* (crossing a boundary) vs *in* / *out* (state)
   - *through* (one side to the other, inside something) vs *across* (one side to the other, over a surface)
   - *beside* (next to) vs *besides* (in addition to - not on the chart, but worth flagging)

## Style

- English only.
- Short, friendly, concrete.
- Lead with the image, then the explanation.
- Do not dump every preposition unless the user asked for the full overview.

## Response template for a specific preposition

After sending the image, format the explanation exactly like this (Markdown, no extra sections, no closing summary):

```
## <preposition>

**Meaning:** <one-sentence definition - what it does spatially or in motion>.

**Examples:**
- <sentence 1 with the preposition in **bold**>
- <sentence 2 with the preposition in **bold**>

**Common confusion - `<preposition>` vs `<neighbor>`:**
- `<preposition>` = <short contrast>. "<example sentence>" (<quick parenthetical note>)
- `<neighbor>` = <short contrast>. "<example sentence>" (<quick parenthetical note>)

**Opposite:** `<opposite>` - <one-line gloss>. "<example sentence>"
```

Rules for the template:
- The `## <preposition>` heading is lowercase (e.g. `## into`, not `## Into`).
- Exactly 2 bullets under **Examples:** - no more, no less. Bold the target preposition inside each sentence.
- The **Common confusion** block compares against the one closest neighbor (into/in, between/among, above/over, through/across, beside/besides, etc.). If the preposition genuinely has no confusing neighbor, drop this block.
- The **Opposite:** line is optional - include it when there is a clear opposite on the chart (into/out of, before/behind, above/below, towards/away, in/out of, etc.). Skip it otherwise.
- Use backticks around prepositions when discussing them as words, bold them inside example sentences.
- No preamble, no "Here's an explanation", no trailing summary.

### Full worked example (for `into`)

```
## into

**Meaning:** movement from outside to inside something - crossing a boundary.

**Examples:**
- She walked **into** the room.
- Pour the milk **into** the glass.

**Common confusion - `into` vs `in`:**
- `into` = the movement of entering (dynamic). "He ran **into** the house." (was outside → now inside)
- `in` = the location, already inside (static). "He is **in** the house." (just where he is)

**Opposite:** `out of` - movement from inside to outside. "She stepped **out of** the car."
```
