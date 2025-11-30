# Ruby & Rails Style Guide

Follow these rules in this project.

---

## Simplification

- One way to do it, not three. Consolidate similar classes into one with parameters.
- If the only difference is configuration, use parameters — not separate classes.
- Don't create multiple storage levels when one will do.

```ruby
# ❌ Bad
class GlobalTypeRegistrar
  def register(name, &block) ...
end
class ScopedTypeRegistrar
  def register(name, scope, &block) ...
end

# ✅ Good
class TypeRegistrar
  def register(name, scope: nil, &block)
  end
end
```

---

## Composition

- Prefer class instances over modules. Modules create hidden coupling.
- Exception: `ActiveSupport::Concern` for DSLs.

```ruby
# ❌ Bad
class Api::Base
  include Recorder
end

# ✅ Good
class Api::Base
  def initialize
    @recorder = Recorder.new(@metadata, @namespaces)
  end
end
```

### One Class, One File

Every class lives in its own file. No inline classes.

```ruby
# ❌ Bad
class Builder
  class Result
    attr_reader :value
  end
end

# ✅ Good
# lib/builder.rb
class Builder; end

# lib/builder/result.rb
class Builder::Result; end
```

### Extract for Concepts, Not Lines

Only extract when there's a conceptual win. Three similar lines is better than a premature abstraction.

Never create: `helpers/`, `utils/`, `misc/`

```ruby
# ❌ Bad
def format_date(d) = d.strftime("%Y-%m-%d")

# ✅ Good
class CaseTransformer
  def self.camelize(s) ... end
  def self.snake(s) ... end
end
```

---

## Philosophy

- Readability over cleverness
- Classic Ruby elegance — no unnecessary meta-programming
- Rails-ness matters — declarative, expressive, conventional
- Never break what already works — refactor inside, not outside
- Clean up as you go — remove dead code
- Breaking changes are fine — this is pre-release
- Use stable identifiers for registry keys (not class references that become stale on reload)

---

## No Comments

Code should speak for itself. Extract logic to well-named methods.

```ruby
# ❌ Bad
if user.subscription_tier == 'premium' && user.api_calls_this_month < 10_000

# ✅ Good
if user.can_make_api_call?
```

Allowed: magic comments, RuboCop directives, temporary TODOs.

---

## Core Principles

- Small, focused objects with one responsibility
- Explicit over implicit — no magic or monkey patching
- Guard clauses over deep nesting
- Positive conditions — avoid `unless` with compound logic, `!`, `== false`
- Full names — `attribute` not `attr` (exception: `param`, `attr_reader`)
- Don't repeat namespace context: `CaseTransformer.hash`, not `transform_keys`
- Use `ActiveSupport::Concern` over `self.included(base)` + `base.extend(ClassMethods)`

### Guard Logic Belongs in Methods

```ruby
# ❌ Bad
validate_association_exists! if @model_class

def validate_association_exists!
  return unless @model_class
  # ...
end

# ✅ Good
validate_association_exists!

def validate_association_exists!
  return unless @model_class
  # ...
end
```

Exception: External context conditions can stay at call site:
```ruby
send_notification if user.opted_in?
```

---

## Class References

Use class constants, not strings.

```ruby
# ✅ Good
has_one :profile, class_name: ProfileResource
resource UserResource

# ❌ Bad
has_one :profile, class_name: 'ProfileResource'
```

Exception: `config/routes.rb` and files that run before autoloading.

---

## Option Naming

Don't repeat context. In a Resource class, use `class_name:` not `resource_class_name:`.

```ruby
# ✅ In Resource class
has_one :author, class_name: UserResource

# ✅ Outside context
def initialize(resource_class_name:)
```

---

## Naming

### Names describe what something IS

```ruby
# ✅ Good
key_transform = serialize_key_transform
invoice_total = invoice.total

# ❌ Bad
total = invoice.total  # Context lost
```

### Natural word order (adjective → noun)

| ❌ Wrong | ✅ Right |
|----------|----------|
| `invoices_paginated` | `paginated_invoices` |
| `user_serialized` | `serialized_user` |

### Preserve full names

```ruby
# ✅ Good
action_name_sym = action_name.to_sym
customer_email = customer.email

# ❌ Bad
action_sym = action_name.to_sym
email = customer.email
```

### Positive predicates

```ruby
# ✅ Good
list.include?(key)
list.exclude?(key)

# ❌ Bad
!list.include?(key)
```

### Method names: nouns for getters, verbs for actions

```ruby
# ✅ Good
Registry.types(api)
TypeStore.serialize(api)

# ❌ Bad
TypeStore.serialize_all_types_for_api(api)
```

---

## No Multi-line Block Chains

```ruby
# ❌ Bad
collection
  .map do |item|
    process(item)
  end
  .select do |item|
    valid?(item)
  end

# ✅ Good
processed = collection.map { process(_1) }
validated = processed.select { valid?(_1) }
```

---

## Method Arguments

### Positional
When unambiguous and essential: `User.find(id)`, `Money.new(amount, currency)`

### Keyword
When meaning isn't obvious, for booleans, optionals, or >2 args:
```ruby
resize(width: 800, height: 600)
broadcast(event, async: true)
```

### Options hash
Only when truly dynamic: `define_resource(:invoice, **options)`

### Order
positional → keyword → splat

---

## Ruby/Rails Idioms

- `map(&:to_s)`, `select(&:present?)`, `compact_blank`
- `index_by`, `each_with_object({})`, `group_by`
- `delegate`, `attr_reader` + memoization (`@x ||= ...`)
- `tap`, `then` for fluent flow
- `present?`, `blank?`, `presence`
- Freeze constants: `FOO = {...}.freeze`
- Ruby 3 hash shorthands: `{ title, value }`
- Predicate methods: `amount.positive?`, `collection.any?`, `value.zero?`

---

## Zeitwerk

Never `require` application code. Just use the class.

```ruby
# ❌ Bad
require 'app/models/user'

# ✅ Good
User.find(1)
```

Use `require` for: gems, stdlib, files outside autoload paths.

---

## Documentation

Keep docs in sync with code. Docs live in `docs/`.

Before writing documentation:
- Verify against actual code and tests
- Never invent formats or structures
- Run specs or read spec tests to see real output
- Copy exact output — documentation must match reality

### Example Linking System

Documentation examples are linked to real implementations in `docs/app/` using HTML comments.

**Format:**
```markdown
<!-- example: eager-lion -->
```ruby
# code example here
```

<details>
<summary>Introspection</summary>

<<< @/examples/eager-lion/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/examples/eager-lion/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/examples/eager-lion/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/examples/eager-lion/openapi.yml

</details>
```

**How it works:**
1. The `<!-- example: NAME -->` comment goes BEFORE the code block
2. Each format gets its own `<details>` block with VitePress inline embed `<<<`
3. The comment stays permanently — it marks the connection for future updates

**When you discover a NEW example tag (e.g., `<!-- example: lazy-cow -->`):**

1. **Always create:**
   - `config/apis/lazy_cow.rb` — API definition

2. **If the example uses contracts (no `schema!`):**
   - `app/contracts/lazy_cow/` — Contract definitions only

3. **If the example uses schemas (`schema!`):**
   - `app/contracts/lazy_cow/` — Contract with `schema!`
   - `app/schemas/lazy_cow/` — Schema definitions
   - `app/models/lazy_cow/` — ActiveRecord models
   - `db/migrate/` — Migration for tables

4. Run `rake docs:generate` to generate output files
5. Add individual `<details>` blocks for each format after the code block

### Namespace Naming Conventions

| Context | Format | Example |
|---------|--------|---------|
| Example comment | dash-case | `<!-- example: eager-lion -->` |
| Ruby namespace | PascalCase | `EagerLion::Invoice` |
| App folder | snake_case | `app/models/eager_lion/` |
| API mount path | dash-case | `/eager-lion` |
| Examples folder | dash-case | `docs/examples/eager-lion/` |
| Table name | snake_case prefix | `eager_lion_invoices` |

### Directory Structure

```
docs/
├── app/                              # Rails app for generating examples
│   ├── app/
│   │   ├── models/eager_lion/
│   │   ├── schemas/eager_lion/
│   │   └── contracts/eager_lion/
│   ├── config/apis/eager_lion.rb
│   └── db/migrate/
└── examples/
    └── eager-lion/                   # Generated output (dasherized)
        ├── introspection.json
        ├── typescript.ts
        ├── zod.ts
        └── openapi.yml
```

### Generating Examples

Run `rake docs:generate` from `docs/app/` to regenerate all example files:

```bash
cd docs/app && RAILS_ENV=test rake docs:generate
```

This regenerates all files in `docs/examples/` from the playground APIs. Run this after every change that affects output formats.

### Synchronization Rules

**ALWAYS keep these in sync. This is non-negotiable.**

**When writing or changing documentation:**
1. Create/update corresponding code in `docs/app/`
2. Run `rake docs:generate` to produce REAL output
3. Verify files in `docs/examples/<namespace>/`
4. Add individual `<details>` blocks for each format using `<<< @/examples/<name>/file`
5. NEVER invent, abbreviate, or guess output

**When changing code that affects output formats:**
1. Check if it affects Introspection, TypeScript, Zod, or OpenAPI
2. Run `rake docs:generate` to regenerate ALL examples
3. Include updated `docs/examples/` files in the SAME commit

**The fundamental rule:**
Code → docs/app → `rake docs:generate` → docs/examples/ → VitePress inline embeds.
They are ONE system. Change one, change all. Same commit. No exceptions.

Style:
- Pedagogical — teach, don't just describe
- Simple English — no jargon or marketing fluff
- Direct — show code, explain briefly
- Examples over explanations
- Minimal code examples — only what's needed

Type system examples must show all four formats in this order, each in its own `<details>` using VitePress inline embed:

1. Introspection
2. TypeScript
3. Zod
4. OpenAPI

```markdown
<details>
<summary>Introspection</summary>

<<< @/examples/example-name/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/examples/example-name/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/examples/example-name/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/examples/example-name/openapi.yml

</details>
```

---

## Code Style

Run `bundle exec rubocop -A` on every file you modify. This uses aggressive auto-correction.

---

## Testing

- Run tests after every code change
- New functionality requires new tests
- Integration tests with dummy app are priority — test real user flows
- Unit tests when it makes sense
- Update tests when code changes

---

## Quick Reference

| ❌ Bad | ✅ Good |
|--------|---------|
| `if !user.active?` | `unless user.active?` |
| `if order.total > 0` | `if order.total.positive?` |
| `if !items.empty?` | `if items.any?` |
| `if user.admin? == false` | `unless user.admin?` |
