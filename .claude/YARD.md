# YARD & Documentation Audit

Checklist for auditing YARD documentation in `lib/apiwork/`.

**Consistency is mandatory. No deviations.**

---

## Style & Tone

### Description Must Start With

| Method type | Start with | Example |
|-------------|------------|---------|
| Lookup | "Finds" | "Finds an API by its mount path." |
| DSL/config | "Defines", "Sets", "Configures" | "Defines a reusable object type." |
| Getter | "The X." (noun phrase) | "The output type for this export." |
| Transform | "Transforms" | "Transforms the body parameters." |
| Predicate | "Returns whether" or "Whether" | "Returns whether this is abstract." |
| Factory | "Creates" | "Creates a new request context." |

### Forbidden Phrases

```bash
# Check for violations
grep -rn "Gets or sets" lib/
grep -rn "Defaults to" lib/
grep -rn "Without arguments" lib/
grep -rn "With an argument" lib/
grep -rn "This method" lib/
grep -rn "allows you to" lib/
```

| Forbidden | Use instead |
|-----------|-------------|
| "Gets or sets the X" | "The X." |
| "Defaults to X if Y" | `(default: X)` in @param |
| "Without arguments, returns..." | (delete — @return makes it clear) |
| "With an argument, sets..." | (delete — @param makes it clear) |
| "This method" | (start with verb directly) |
| "Will return" | "Returns" |
| "is transformed" | "Transforms" |
| "allows you to" | (delete or rephrase) |
| "powerful", "seamlessly", "simply" | (delete) |

### Voice & Tense

- **Active voice only**: "Transforms the body" not "The body is transformed"
- **Present tense only**: "Finds" not "Will find"
- **Imperative form**: "Finds", "Defines", "Returns"

### Capitalization

| Element | Case | Example |
|---------|------|---------|
| First line (methods) | Uppercase start | "Finds an API by path." |
| @param description | lowercase | "the mount path" |
| @return description | lowercase | "the API class or nil" |
| Class-level docs | Full sentence | "Base class for API definitions." |

---

## @param Format

```ruby
# Format
@param name [Type] the description

# With default — always in @param, never in description
@param replace [Boolean] replace existing (default: false)
@param name [Symbol, nil] adapter name (default: :standard)

# With enum values
@param format [Symbol] :keep, :camel, :underscore, or :kebab

# Dynamic/inherited default — brief note in description instead
# The key format. Inherits from API when not set.
#
# @param format [Symbol, nil] :keep, :camel, :underscore, or :kebab
```

**Rules:**
- Lowercase description
- Static defaults: `(default: X)` in @param line
- Dynamic defaults: brief note in description, nothing in @param
- Never "Defaults to X if Y" in description
- Enum values listed with colons
- Include `nil` in type if parameter accepts nil

**Check:**
```bash
grep -rn "Defaults to" lib/
```

---

## @return Format

```ruby
# Simple return
@return [String] the mount path

# Nullable
@return [Class<API::Base>, nil] the API class or nil if not found

# Boolean predicate
@return [Boolean] true if abstract

# New instance
@return [Request] new context with transformed data
```

**Patterns:**
- "the X" for simple returns
- "X or nil if not found" for nullable
- "true if X" for booleans
- "new X with..." for factory methods

---

## @example Format

**Code examples must follow CLAUDE.md style guide.** No exceptions.

```ruby
# With title
@example Finding an API
  Apiwork::API.find('/api/v1')

# With output
@example
  request.query  # => { page: 1 }

# Multi-step
@example
  api = Apiwork::API.define '/api/v1' do
    resources :users
  end
  api.path  # => "/api/v1"
```

**Rules:**
- Optional title after `@example`
- Runnable code (not pseudocode)
- Output shown with `# =>`

---

## Type Rules

### Class Return Types

Methods returning **class objects** (not instances) use `Class<Type>`:

```ruby
# Bad
@return [Representation::Base]      # implies instance
@return [Class]                      # too vague

# Good
@return [Class<Representation::Base>]
@return [Class<ActiveRecord::Base>]
```

**Check:**
```bash
grep -rn "@return \[Class\]" lib/
```

---

### Parameter Types Must Match

If signature has `= nil`, type must include `nil`:

```ruby
# Bad
@param name [Symbol] the name
def export_name(name = nil)

# Good
@param name [Symbol, nil] the name
def export_name(name = nil)
```

---

## Structural Rules

### No @raise for Abstract Methods

```ruby
# Bad
# @raise [NotImplementedError] subclasses must implement

# Good
# (omit — self-evident from code)
```

**Check:**
```bash
grep -rn "@raise \[NotImplementedError\]" lib/
```

---

### YARD Only for @api public

No YARD on internal methods. Only `@api public` gets documentation.

---

### Declaration Grouping

```ruby
# @api public — one per line with YARD
# @api public
# @return [Hash]
attr_reader :context

# Internal — group without YARD
attr_reader :cache,
            :options,
            :registry
```

---

## Quick Audit

```bash
# Style violations
grep -rn "Gets or sets" lib/
grep -rn "Without arguments" lib/
grep -rn "This method" lib/

# Type violations
grep -rn "@return \[Class\]" lib/
grep -rn "@raise \[NotImplementedError\]" lib/

# All clean = Exit: 1
grep -rn "Gets or sets" lib/; echo "Exit: $?"
```

---

## Audit Checklist

- [ ] `lib/apiwork/api/`
- [ ] `lib/apiwork/adapter/`
- [ ] `lib/apiwork/contract/`
- [ ] `lib/apiwork/representation/`
- [ ] `lib/apiwork/export/`
- [ ] `lib/apiwork/introspection/`
- [ ] `lib/apiwork/*.rb`
- [ ] `docs/guide/`
- [ ] `docs/reference/`

For each `@api public` method:
1. Description starts correctly (verb or noun phrase)
2. No forbidden phrases
3. Active voice, present tense
4. @param types match signature
5. @return type matches actual return
6. Class references use `Class<Type>`
