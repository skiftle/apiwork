# Documentation

Rules for writing VitePress documentation, guides, and examples.

For core style rules, see `CLAUDE.md`.
For YARD documentation rules, see `yard.md`.

---

## Golden Rule

**Verify against code.** Never invent behavior.

Before writing:

1. Read the implementation
2. Run the code if uncertain
3. Check tests for expected behavior

If you cannot verify it, do not document it.

---

## Documentation Categories

| Category | Purpose | Rules |
|----------|---------|-------|
| **Core Concepts** | What the system _is_ | Conceptual, not instructional. No step-by-step. Minimal code. |
| **Guides** | How to use it in practice | Practical, action-oriented. Code examples early. Do not restate Core. |
| **Reference** | Exhaustive API surface | Concise, precise. No narrative. No conceptual explanations. |

### Introduction Pages

Every guide section has an `introduction.md` answering: **what is this and why do I care?**

Must contain: opening sentence, responsibility breakdown, one minimal example, connection to other concepts, one-line summary per sub-page, link to reference.

Must NOT contain: bullet-list TOC, repeated core-concepts, deep configuration, multiple examples, reference-level tables.

**Decision test:** If a section could stand as its own sub-page, move it out.

### Concept Integrity

Do not blur boundaries:

- **API Definitions** define surface and configuration
- **Contracts** define and execute the boundary
- **Representations** reflect domain models
- **Adapters** interpret declarative structure
- **Introspection** exposes the boundary model
- **Errors** describe boundary guarantees

---

## Documentation Rules

| Do                                         | Don't                      |
| ------------------------------------------ | -------------------------- |
| Document only public API                   | Document internal details  |
| Link generously                            | Guess behaviors            |
| Show examples when they help understanding | Let docs diverge from code |
| Use YARD only for `@api public` methods    | Invent features            |

---

## Phases

Work in **one phase at a time**. Never mix.

| Phase               | Do                               | Do Not                                  |
| ------------------- | -------------------------------- | --------------------------------------- |
| **1. Style & Tone** | Improve clarity, consistency     | Change meaning, add/remove features     |
| **2. Verification** | Compare docs to code, fix errors | Rewrite unless required for correctness |
| **3. Navigation**   | Add links, intros, "See also"    | Re-explain content                      |

---

## Tone

**Direct.** State facts. No hedging.
**Technical.** Assume Ruby/Rails knowledge.
**Pedagogical.** Show code first, explain briefly after.

---

## Avoid Patterns

| Pattern                          | Fix                       |
| -------------------------------- | ------------------------- |
| "Let's explore how..."           | Just explain it           |
| "It's important to note that..." | State the fact            |
| "This allows you to..."          | "You can..."              |
| "In this section, we will..."    | Just do it                |
| "As mentioned earlier..."        | Link to it                |
| "powerful feature"               | "feature"                 |
| "seamlessly integrates"          | "integrates"              |
| "simply", "just", "easily"       | Delete                    |
| "In order to"                    | "To"                      |
| Arrow characters (`→`)           | "becomes", "then"         |
| Passive voice                    | Active voice              |
| Future tense ("will")            | Present tense             |
| "We"                             | "You" or direct statement |

---

## Document Structure

- `#` page title (one per page)
- `##` major sections
- `###` subsections (avoid deeper)
- 1-3 sentences per paragraph

**Page intro:** What it covers, what reader learns, how it fits. No selling.

---

## Code Examples

Show immediately after concept. Real, runnable, minimal.

```ruby
# Bad
request { body { param :name } }
body { param :id; param :title }

# Good
request do
  body do
    param :name
  end
end

body do
  param :id
  param :title
end

# Exception: simple single-item
response { no_content! }
```

---

## Formatting

**Lists over prose:**

```markdown
The adapter:

- Validates the request
- Queries the database
- Serializes the response
```

**Tables** for reference information.

**Callouts** — sparingly, never with custom titles:

```markdown
::: info
Text stands on its own.
:::
```

Never:

```markdown
::: info Custom Title
...
:::
```

Types: `info`, `tip`, `warning`, `danger`

---

## Linking

Link first mention of concepts, options, APIs, related behavior.

```markdown
Schemas define [attributes](./attributes.md) that map to model columns.
```

- Guides: _how_ and _why_
- Reference: _what_
- See Also: end of page, max 3-5 links

---

## Example Linking System

Examples link to `docs/playground/` via VitePress embeds.

```markdown
<!-- example: eager-lion -->

<<< @/playground/app/contracts/eager_lion/invoice_contract.rb

::: details Introspection

<<< @/playground/public/eager-lion/introspection.json

:::

::: details TypeScript

<<< @/playground/public/eager-lion/typescript.ts

:::

::: details Zod

<<< @/playground/public/eager-lion/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/eager-lion/openapi.yml

:::
```

### Namespace conventions

| Context    | Format     | Example                        |
| ---------- | ---------- | ------------------------------ |
| Comment    | dash-case  | `<!-- example: eager-lion -->` |
| Ruby       | PascalCase | `EagerLion::Invoice`           |
| Folder     | snake_case | `app/models/eager_lion/`       |
| Mount path | dash-case  | `/eager-lion`                  |
| Output     | dash-case  | `public/eager-lion/`           |
| Table      | snake_case | `eager_lion_invoices`          |

### New example

1. Create `config/apis/lazy_cow.rb`
2. Contracts only: `app/contracts/lazy_cow/`
3. With schemas: also `app/schemas/`, `app/models/`, `db/migrate/`
4. Run `rake docs:generate`
5. Add `::: details` blocks

### Sync rule

Code changes, then `docs/playground/`, then `rake docs:generate`, then `public/`, then VitePress embeds.

**Same commit. No exceptions.**

---

## Mental Model

- Database = source of truth
- Rails/ActiveRecord = domain
- Apiwork introspects this structure
- Contracts, schemas, APIs build on it
- Specs, types, validation = derived, never duplicated

---

## Checklist

1. Verified against code
2. No invented behavior
3. Runnable examples
4. No marketing/filler/AI patterns
5. Active voice, present tense
6. 1-3 sentence paragraphs
7. Correct links
8. Multi-line block formatting
9. No custom titles in callouts
