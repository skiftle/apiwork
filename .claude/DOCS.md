# DOCS.md

Rules for writing documentation. Documentation is part of the API.

---

## Golden Rule

**Verify against code.** Never invent behavior.

Before writing:
1. Read the implementation
2. Run the code if uncertain
3. Check tests for expected behavior

If you cannot verify it, do not document it.

---

## Phases

Work in **one phase at a time**. Never mix.

| Phase | Do | Do Not |
|-------|-----|--------|
| **1. Style & Tone** | Improve clarity, consistency | Change meaning, add/remove features |
| **2. Verification** | Compare docs to code, fix errors | Rewrite unless required for correctness |
| **3. Navigation** | Add links, intros, "See also" | Re-explain content |

---

## Tone

**Direct.** State facts. No hedging.
**Technical.** Assume Ruby/Rails knowledge.
**Pedagogical.** Show code first, explain briefly after.

---

## Avoid

| Pattern | Fix |
|---------|-----|
| "Let's explore how..." | Just explain it |
| "It's important to note that..." | State the fact |
| "This allows you to..." | "You can..." |
| "In this section, we will..." | Just do it |
| "As mentioned earlier..." | Link to it |
| "powerful feature" | "feature" |
| "seamlessly integrates" | "integrates" |
| "simply", "just", "easily" | Delete |
| "In order to" | "To" |
| Arrow characters (`→`) | "becomes", "then" |
| Passive voice | Active voice |
| Future tense ("will") | Present tense |
| "We" | "You" or direct statement |

---

## Structure

- `#` page title (one per page)
- `##` major sections
- `###` subsections (avoid deeper)
- 1–3 sentences per paragraph

**Page intro:** What it covers, what reader learns, how it fits. No selling.

---

## Code Examples

Show immediately after concept. Real, runnable, minimal.

```ruby
# ❌ Bad
request { body { param :name } }
body { param :id; param :title }

# ✅ Good
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

**Callouts** — sparingly, no headings inside:
```markdown
::: info
Text stands on its own. No heading needed.
:::
```

Types: `info`, `tip`, `warning`, `danger`

---

## Linking

Link first mention of concepts, options, APIs, related behavior.

```markdown
Schemas define [attributes](./attributes.md) that map to model columns.
```

- Guides: *how* and *why*
- Reference: *what*
- See Also: end of page, max 3–5 links

---

## Example Linking System

Examples link to `docs/playground/` via VitePress embeds.

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

### Namespace conventions

| Context | Format | Example |
|---------|--------|---------|
| Comment | dash-case | `<!-- example: eager-lion -->` |
| Ruby | PascalCase | `EagerLion::Invoice` |
| Folder | snake_case | `app/models/eager_lion/` |
| Mount path | dash-case | `/eager-lion` |
| Output | dash-case | `public/eager-lion/` |
| Table | snake_case | `eager_lion_invoices` |

### New example

1. Create `config/apis/lazy_cow.rb`
2. Contracts only: `app/contracts/lazy_cow/`
3. With schemas: also `app/schemas/`, `app/models/`, `db/migrate/`
4. Run `rake docs:generate`
5. Add `<details>` blocks

### Sync rule

Code → `docs/playground/` → `rake docs:generate` → `public/` → VitePress embeds.

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

- [ ] Verified against code
- [ ] No invented behavior
- [ ] Runnable examples
- [ ] No marketing/filler/AI patterns
- [ ] Active voice, present tense
- [ ] 1–3 sentence paragraphs
- [ ] Correct links
- [ ] Multi-line block formatting
- [ ] No headings in callouts

---

## Final Rule

Unclear? **Do not guess. Do not invent. Ask, or leave undocumented.**
