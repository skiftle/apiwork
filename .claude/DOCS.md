# Apiwork Documentation Guide

This file defines **how Claude Code must write, edit, and review documentation for Apiwork**.

It is not a style suggestion.
It is a set of rules.

---

## Core Principle

**Documentation is part of the API.**

If documentation is wrong, the API is wrong.

---

## The Golden Rule

**Verify everything against the code.**

Documentation that is incorrect is worse than no documentation.

Before writing or changing anything:

- Read the implementation
- Run the code if uncertain
- Check tests for expected behavior
- Never guess or assume

When describing behavior:

- Quote actual method names and options
- Use real examples from the codebase
- If you are not 100% sure, look it up

::: danger
Never invent behavior.
If something cannot be verified in code, do not document it.
:::

---

## Roles and Phases

Claude must treat documentation work as **separate phases**.
Never mix these.

### Phase 1 — Style & Tone

- Improve clarity and consistency
- Do not change meaning
- Do not add or remove features

### Phase 2 — Verification

- Compare documentation against code
- Identify incorrect, incomplete, or conditional claims
- Do not rewrite text unless required for correctness

### Phase 3 — Navigation & Linking

- Improve internal links and reference links
- Add introductions and "See also" sections where useful
- Do not re-explain content

Claude must only perform **one phase at a time**.

---

## Tone

**Direct.** Say what something does. Do not hedge.

```markdown
# Bad

Schemas can potentially be used to describe your data structures.

# Good

Schemas describe your data structures.
```

**Technical.** Assume the reader knows Ruby and Rails.

```markdown
# Bad

First, you'll want to create a new Ruby class that inherits from the base class.

# Good

class InvoiceSchema < Apiwork::Schema::Base
```

**Pedagogical.** Teach through concrete examples. Show code first, explain briefly after.

---

## Language Rules

### Active Voice

```markdown
# Bad

The request is validated by the contract.

# Good

The contract validates the request.
```

### Present Tense

```markdown
# Bad

When you call schema!, the adapter will generate types.

# Good

When you call schema!, the adapter generates types.
```

### Second Person

Address the reader as "you".
Avoid "we" unless collaboration is explicit.

---

## What to Avoid

### AI-Generated Patterns

| Pattern                          | Alternative       |
| -------------------------------- | ----------------- |
| "Let's explore how..."           | (just explain it) |
| "It's important to note that..." | (state the fact)  |
| "This allows you to..."          | "You can..."      |
| "In this section, we will..."    | (just do it)      |
| "As mentioned earlier..."        | (link to it)      |

### Marketing Language

| Bad                     | Good         |
| ----------------------- | ------------ |
| "powerful feature"      | "feature"    |
| "seamlessly integrates" | "integrates" |
| "best-in-class"         | (delete)     |

### Filler Words

| Bad                | Good        |
| ------------------ | ----------- |
| "simply add"       | "add"       |
| "just call"        | "call"      |
| "easily configure" | "configure" |
| "In order to"      | "To"        |

### Arrows

Never use arrow characters.

| Bad                | Good                   |
| ------------------ | ---------------------- |
| `"123"` → `123`    | `"123"` becomes `123`  |
| Request → Response | Request, then response |

---

## Structure

### Headings

- `#` page title (one per page)
- `##` major sections
- `###` subsections
- Avoid deeper levels

### Paragraphs

1–3 sentences. One idea per paragraph.

### Page Introductions

Every page must start with:

- What the page covers
- What the reader will learn
- How it fits into the rest of the docs

Never sell. Never list features.

---

## Code Examples

- Show code immediately after introducing a concept
- Use real, runnable examples
- Minimal but complete

### Block Formatting

Never inline nested structures:

```ruby
# Bad
request { body { param :name } }

# Good
request do
  body do
    param :name
  end
end
```

Each statement on its own line:

```ruby
# Bad
body { param :id; param :title }

# Good
body do
  param :id
  param :title
end
```

Exception: Simple single-item blocks can stay inline:

```ruby
response { no_content! }
```

---

## Formatting

### Bullet Lists

Prefer lists over prose:

```markdown
# Bad

The adapter validates the request, queries the database, serializes the response, and handles errors.

# Good

The adapter:

- Validates the request
- Queries the database
- Serializes the response
- Handles errors
```

### Tables

Use tables for reference information.

### Callouts

Use VitePress callout boxes sparingly. Never include headings — the box type provides context. Text must stand on its own.

```markdown
::: info
The adapter delegates to `Schema.deserialize()` for the decode step.
:::

::: tip
Use `filterable: true` on attributes you want to query.
:::

::: warning
This will delete all records. Use with caution.
:::

::: danger
Never expose this endpoint publicly.
:::
```

```markdown
# ❌ Bad — heading inside box

::: info

## How it works

The adapter delegates to Schema.deserialize().
:::

# ✅ Good — text stands alone

::: info
The adapter delegates to `Schema.deserialize()` for the decode step.
:::
```

---

## Linking & Navigation

### Inline Linking

Link the first mention of:

- Core concepts
- Options
- APIs
- Behavior explained elsewhere

```markdown
# Bad

Schemas define attributes. See the Attributes page for more information.

# Good

Schemas define [attributes](./attributes.md) that map to model columns.
```

### Guide vs Reference

- Guides explain _how_ and _why_
- Reference explains _what_

### See Also Sections

Use at the end of pages when helpful. Max 3–5 links.

---

## Example Linking System

Documentation examples link to real implementations in `docs/playground/` using VitePress inline embeds.

### Format

```markdown
<!-- example: eager-lion -->

<<< @/playground/app/contracts/eager_lion/invoice_contract.rb

<details>
<summary>Introspection</summary>

<<< @/playground/public/eager-lion/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/eager-lion/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/eager-lion/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/eager-lion/openapi.yml

</details>
```

### Namespace Naming Conventions

| Context          | Format            | Example                              |
| ---------------- | ----------------- | ------------------------------------ |
| Example comment  | dash-case         | `<!-- example: eager-lion -->`       |
| Ruby namespace   | PascalCase        | `EagerLion::Invoice`                 |
| App folder       | snake_case        | `app/models/eager_lion/`             |
| API mount path   | dash-case         | `/eager-lion`                        |
| Generated output | dash-case         | `docs/playground/public/eager-lion/` |
| Table name       | snake_case prefix | `eager_lion_invoices`                |

### Creating New Examples

When you discover a NEW example tag (e.g., `<!-- example: lazy-cow -->`):

1. **Always create:** `config/apis/lazy_cow.rb`
2. **Contracts only (no `schema!`):** `app/contracts/lazy_cow/`
3. **With schemas (`schema!`):** Also create `app/schemas/`, `app/models/`, `db/migrate/`
4. Run `rake docs:generate` to generate output files
5. Add `<details>` blocks for each format

### Synchronization Rules

Code → `docs/playground/` → `rake docs:generate` → `docs/playground/public/` → VitePress embeds.

Change one, change all. Same commit. No exceptions.

---

## Introspection & Mental Model

Apiwork documentation must reflect its architecture:

- The database is the primary source of truth
- Rails and Active Record define much of the domain
- Apiwork introspects this structure
- Contracts, schemas, and API definitions build on it
- Specs, types, and validation are derived, never duplicated

---

## Verification Checklist

Before committing documentation:

- [ ] Verified against actual code
- [ ] No invented behavior
- [ ] Runnable examples
- [ ] No marketing language
- [ ] No AI-style phrasing
- [ ] Active voice
- [ ] Present tense
- [ ] Short paragraphs (1–3 sentences)
- [ ] Correct links
- [ ] Multi-line block formatting

---

## Final Rule

If something is unclear:

- Do not guess
- Do not invent
- Ask, or leave it undocumented

**Documentation is a contract.**
