# NEW_DOCS.md

Rules for writing and reviewing guide documentation pages.

---

## Introduction Pages

Every guide section has an `introduction.md`. It answers: **what is this and why do I care?**

### Must contain

| Element | Rule |
|---------|------|
| Opening | One sentence: what it is and what it does |
| Responsibility | "What X Does" section — concrete breakdown of what it is responsible for |
| Example | One minimal code example showing the concept working |
| Connection | How it relates to other concepts, with links |
| Sub-topics | One-line summary + link per sub-page |
| See also | Link to reference page |

### Must NOT contain

| Forbidden | Belongs in |
|-----------|------------|
| Bullet-lists as table of contents | Navigation sidebar or sub-topic links |
| Content that repeats core-concepts | core-concepts.md |
| Deep configuration details | Dedicated sub-page |
| Multiple code examples showing variations | Dedicated sub-page |
| Reference-level option tables | Reference docs or dedicated sub-page |
| Edge cases and workarounds | Dedicated sub-page |

### Decision test

If a section on the introduction page could stand as its own sub-page — it should. Move it out and replace it with a one-line summary and link.

### Reference: adapters/introduction.md

The adapters introduction is the model to follow:

1. One sentence saying what the adapter is and does
2. "What Adapters Do" — numbered list of concrete responsibilities
3. Brief paragraph connecting it to representations
4. "Capabilities" — short explanation of the architecture
5. "Standard Adapter" — summary with links to sub-pages
6. "Custom Adapters" — summary with link to sub-page
