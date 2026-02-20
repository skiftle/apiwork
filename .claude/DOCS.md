# Documentation Style Guide

This document defines how documentation in Apiwork should be written.

The goal is consistency, clarity, and long-term maintainability.  
All contributors — human or AI — must follow these rules.

---

# 1. Structural Principles

Documentation is divided into three categories:

## Core Concepts

Purpose:

- Define what the system _is_.
- Explain responsibility and relationships.
- Provide a mental model.

Rules:

- Conceptual, not instructional.
- No step-by-step instructions.
- Minimal or no code examples.
- No feature lists.
- Focus on architectural responsibility.
- Avoid repetition across sections.

Core explains _what_ and _why_, not _how_.

---

## Guides

Purpose:

- Explain how to use a specific concept in practice.
- Provide working examples.
- Show common patterns.

Rules:

- Practical and action-oriented.
- Code examples appear early.
- Do not restate Core Concepts.
- Do not reference Core Concepts explicitly.
- Avoid philosophical explanations.
- Prefer short paragraphs over bullet lists.
- Avoid excessive formatting.
- Avoid marketing language.

Guides explain _how_.

---

## Reference

Purpose:

- Exhaustively document API surface.
- List methods, options, and configuration.

Rules:

- Concise and precise.
- No narrative.
- No conceptual explanations.
- No examples unless necessary for clarity.

Reference explains _what exists_.

---

# 2. Tone and Language

All documentation must follow these tone rules:

- Declarative sentences.
- Calm, precise, neutral language.
- No hype or marketing adjectives.
- No rhetorical questions.
- No dramatic emphasis.
- No exclamation marks.
- No conversational filler.

Avoid words like:

- powerful
- robust
- seamless
- elegant
- flexible
- modern
- advanced
- enterprise-ready

Prefer precision over enthusiasm.

---

# 3. Clarity Rules

- One idea per paragraph.
- Avoid unnecessary repetition.
- Do not over-explain obvious behavior.
- Do not describe implementation details unless relevant.
- Do not describe intent twice.

If a sentence can be removed without losing meaning, remove it.

---

# 4. Concept Integrity

Do not blur boundaries between concepts.

- API Definitions define surface and configuration.
- Contracts define and execute the boundary.
- Representations reflect domain models.
- Adapters interpret declarative structure.
- Introspection exposes the boundary model.
- Errors describe boundary guarantees.

Do not merge responsibilities across sections unless technically accurate.

---

# 5. Link Usage

- Link a concept the first time it appears.
- Do not repeatedly link the same term.
- Do not overload paragraphs with links.
- Links support navigation — they do not replace explanation.

---

# 6. AI-Specific Rules

When generating documentation using AI:

- Explicitly state whether writing Core, Guide, or Reference.
- Provide an example paragraph to match tone.
- Instruct the model to avoid marketing language.
- Instruct the model not to restate conceptual sections in guides.
- If the output feels explanatory instead of precise, simplify it.

If the text becomes philosophical, reduce it.
If the text becomes promotional, remove adjectives.
If the text becomes repetitive, condense it.

---

# 7. Final Test

Before publishing documentation, verify:

- Does this section clearly belong to Core, Guide, or Reference?
- Does it avoid repetition from other sections?
- Does it maintain neutral, declarative tone?
- Is it concise without losing clarity?
- Does it avoid marketing language?

If any answer is no, revise.
