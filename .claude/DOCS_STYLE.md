# Documentation Style Guide

This guide defines how we write documentation for Apiwork.

---

## The Golden Rule

**Verify everything against the code.**

Documentation that's wrong is worse than no documentation. Before writing:

- Read the implementation
- Run the code if uncertain
- Check tests for expected behavior
- Never guess or assume

When describing behavior:

- Quote actual method names and options
- Use real examples from the codebase
- If you're not 100% sure, look it up

::: danger
Never invent behavior. If you can't verify it, don't document it.
:::

---

## Link Generously

Link to related pages directly in the text. Don't make readers hunt for context.

```markdown
# Bad
Schemas define attributes. See the Attributes page for more information.

# Good
Schemas define [attributes](./attributes.md) that map to model columns.
```

When to link:

- First mention of a concept explained elsewhere
- Options or methods with dedicated documentation
- Related features that provide context
- Anywhere the reader might want to go deeper

```markdown
# Good examples
The [Execution Engine](../execution-engine/introduction.md) interprets schemas at runtime.

Use [filterable: true](./attributes.md#filtering) to enable query filtering.

See [meta](../contracts/actions.md#meta) for response metadata.
```

::: tip
If you mention a feature, link to it. Over-linking is better than under-linking.
:::

---

## Tone

**Direct.** Say what something does. Don't hedge.

```markdown
# Bad
Schemas can potentially be used to describe your data structures.

# Good
Schemas describe your data structures.
```

**Technical.** Assume the reader knows Ruby and Rails. Don't over-explain basics.

```markdown
# Bad
First, you'll want to create a new Ruby class that inherits from the base class.

# Good
class InvoiceSchema < Apiwork::Schema::Base
```

**Pedagogical.** Teach through examples. Show the code first, explain briefly after.

```markdown
# Good structure
[code example]

This tells Apiwork that [brief explanation].
```

---

## Formatting

### Bullet Points

Prefer lists over prose. Break things down.

```markdown
# Bad
The adapter validates the request, queries the database, serializes the
response, and handles errors.

# Good
The adapter:

- Validates the request
- Queries the database
- Serializes the response
- Handles errors
```

### VitePress Boxes

Use callout boxes to highlight important information:

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

Use them often. They break up walls of text and draw attention to key points.

---

## What to Avoid

### Arrows

Never use arrow characters:

| Bad | Good |
|-----|------|
| `"123"` → `123` | `"123"` becomes `123` |
| Request → Validation → Response | Request, then validation, then response |

### AI-Generated Patterns

The documentation must sound human. Avoid these tells:

| AI Pattern | Human Alternative |
|------------|-------------------|
| "Let's explore how..." | (just explain it) |
| "It's important to note that..." | (state the fact) |
| "This allows you to..." | "You can..." |
| "In this section, we will..." | (just do it) |
| "As mentioned earlier..." | (link to the section) |
| "For example, consider..." | "Example:" |

### Superlatives and Marketing

| Bad | Good |
|-----|------|
| "powerful feature" | "feature" |
| "seamlessly integrates" | "integrates" |
| "amazing flexibility" | "flexibility" |
| "best-in-class" | (delete) |

### Filler Words

| Bad | Good |
|-----|------|
| "simply add" | "add" |
| "just call" | "call" |
| "easily configure" | "configure" |
| "In order to" | "To" |

### Passive Voice

| Bad | Good |
|-----|------|
| "The record is validated by the adapter" | "The adapter validates the record" |
| "Types are generated automatically" | "Apiwork generates types automatically" |

### Over-explanation

```markdown
# Bad
Before we can begin to understand how schemas work, it's important to first
establish a foundational understanding of the relationship between models
and their serialized representations in the context of API development.

# Good
Schemas connect models to API responses.
```

---

## Structure

### Headings

- `#` for page title (one per page)
- `##` for major sections
- `###` for subsections
- Avoid `####` and deeper

### Paragraphs

Keep them short. 1-3 sentences max.

```markdown
# Bad
Schemas provide a declarative way to describe how your ActiveRecord models
should be exposed through your API. They define which attributes are visible,
how associations are handled, and what query operations are permitted. When
combined with contracts, they form a complete specification of your endpoint's
behavior, including validation, serialization, and query handling.

# Good
Schemas describe how models are exposed through your API.

They define visible attributes, associations, and query operations. Combined
with contracts, they specify complete endpoint behavior.
```

### Code Examples

- Show code immediately after introducing a concept
- Use realistic, runnable examples
- Minimal but complete
- Comments only when necessary

```markdown
# Good
Mark attributes as filterable:

```ruby
attribute :status, filterable: true
```

This enables `?filter[status][eq]=published`.
```

### Tables

Use tables for reference information:

```markdown
| Operator | SQL | Example |
|----------|-----|---------|
| `eq` | `= value` | `filter[status][eq]=sent` |
| `gt` | `> value` | `filter[amount][gt]=100` |
```

### Links

- Link to related pages when they provide deeper context
- Don't over-link common terms
- Use relative paths: `[Filtering](./filtering.md)`

---

## Language

### Active Voice

The subject performs the action.

```markdown
# Bad
The request is validated by the contract.

# Good
The contract validates the request.
```

### Present Tense

Describe current behavior, not future possibilities.

```markdown
# Bad
When you call schema!, the adapter will generate types.

# Good
When you call schema!, the adapter generates types.
```

### Second Person

Address the reader as "you" when giving instructions.

```markdown
# Good
Override when you need a different name:
```

### Avoid "We"

Unless it's genuinely collaborative.

```markdown
# Bad
Let's take a look at how we can configure filtering.

# Good
Configure filtering with the filterable option:
```

---

## Examples

### Introducing a Feature

```markdown
## Filtering

Filter records using query parameters. The adapter translates filters into
ActiveRecord queries.

```http
GET /posts?filter[status][eq]=published
```

Structure: `filter[field][operator]=value`
```

### Explaining Behavior

```markdown
When you call `variant`:

1. **Determines the tag** from your `as:` argument, or falls back to Rails' `sti_name`
2. **Stores the STI type** for runtime routing
3. **Registers with the parent schema**
```

### Showing Defaults

```markdown
| Option | Default | Source |
|--------|---------|--------|
| Discriminator column | `:type` | `model_class.inheritance_column` |
| Variant tag | Class name | `model_class.sti_name` |
```

---

## Checklist

Before committing documentation:

- [ ] **Verified against actual code** (most important)
- [ ] Code examples are runnable
- [ ] No superlatives or marketing language
- [ ] No filler words
- [ ] No arrow characters
- [ ] Doesn't sound AI-generated
- [ ] Uses bullet points where appropriate
- [ ] Uses VitePress boxes for key information
- [ ] Short paragraphs (1-3 sentences)
- [ ] Active voice throughout
- [ ] Present tense
- [ ] Links to related pages where helpful
