---
name: grammar-breakdown
description: Break down the grammar of an English sentence or paragraph at C1-C2 level - structure, named constructions, and notable vocabulary/collocations. Use when the user pastes English text from a web page or elsewhere and asks to "break down", "parse", "explain the grammar of", "what tense/clause/construction is this", says "/grammar <text>", or wants to study grammar from real reading.
---

# English grammar breakdown (C1-C2)

Analyse pasted English sentences so the user can learn grammar from real reading. Pure text analysis - no fetching, no scripts.

## Output per sentence

1. **Quote** the sentence verbatim on its own line, in bold or as a block quote.
2. **Structure** - 1-3 lines naming the top-level clause pattern (e.g. "main clause + non-finite adverbial + non-restrictive relative"). Mark subject / finite verb / object or complement when it clarifies.
3. **Patterns** - bulleted list of named constructions, one line each, with a short gloss. Name things precisely:
   - tenses and aspects (past perfect continuous, future perfect, etc.)
   - mood and modality (subjunctive, counterfactual, epistemic *must*)
   - clause types (reduced relative, non-finite adverbial, nominal *that*-clause, cleft, pseudo-cleft)
   - information-packaging (inversion, fronting, extraposition, left/right dislocation, ellipsis)
   - voice and transformation (passive, middle, causative)
   - noun phrase structure (nominalisation, heavy post-modification, apposition)
   - punctuation-driven devices (parenthetical, em-dash parenthesis, colon elaboration)
4. **Vocab / collocations** - 2-5 bullets of items worth stealing: strong collocations, idioms, phrasal verbs, register-marked or formal lexis. Skip the section if nothing stands out.
5. **Paraphrase** (optional) - include only when the sentence is syntactically dense; give a plainer rewrite so the construction is visible by contrast. Omit for simple sentences.

## Formatting rules

- Never use em dashes. Use plain hyphens.
- Terse. One sentence per bullet. Do not restate the meaning unless asked.
- For multi-sentence input, process each in order with a blank line between.
- Assume C1-C2 reader - skip explaining basic tenses or SVO. Only name a feature if there is something noteworthy about it in this sentence.

## Scope

- English only. If the input is not English, say so and stop.
- Do not fetch URLs. If the user pastes a URL, ask them to paste the sentence instead.
- No caching across sessions.
