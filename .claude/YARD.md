# YARD & Documentation Audit

Checklist for auditing YARD documentation in `lib/apiwork/`.

**Consistency is mandatory. No deviations.**

---

## Tag Order

Strict order for all `@api public` methods:

```ruby
# Description line (verb or noun phrase).
#
# Extended description if needed.
#
# @api public
# @param name [Type] description
# @yield description
# @yieldparam name [Type] description
# @return [Type]
# @raise [Error] description
# @see #other_method
#
# @example Title if multiple
#   code_here
```

**Order:** description → `@api public` → `@param` → `@yield` → `@yieldparam` → `@return` → `@raise` → `@see` → `@example`

---

## Punctuation

### Method Descriptions — WITH period

```ruby
# Finds an API by its mount path.
# Defines a reusable object type.
# The output type for this export.
```

### @param — NO period

```ruby
# @param name [Symbol] the object name
```

These are fragments, not sentences. Never end with period.

### @return — NO description

```ruby
# @return [Request]
```

Type only. Method description provides context.

**Check:**
```bash
grep -rn "@param.*\.$" lib/
grep -rn "@return.*\.$" lib/
```

---

## Style & Tone

### Description Must Start With

| Method type | Start with | Example |
|-------------|------------|---------|
| Lookup | "Finds" | "Finds an API by its mount path." |
| DSL/config | "Defines", "Sets", "Configures" | "Defines a reusable object type." |
| Getter | "The X." (noun phrase) | "The output type for this export." |
| Transform | "Transforms" | "Transforms the body parameters." |
| Predicate (`?` method) | "Whether this X is Y." | "Whether this param is nullable." |
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

### Always Include Context

Descriptions must be complete, self-contained sentences. Always include the context noun.

**Rule:** Use the correct noun for what the class represents:

| Class | Context noun | Example |
|-------|--------------|---------|
| `Param::*` | "this param" | "Whether this param is nullable." |
| `Action` | "this action" | "Whether this action is deprecated." |
| `Enum` | "this enum" | "Whether this enum is deprecated." |
| `Contract` | "this contract" | "Actions defined on this contract." |
| `Representation` | "this representation" | "The model class for this representation." |
| `Association` | "this association" | "The representation class for this association." |
| `Attribute` | "this attribute" | "Whether this attribute is filterable." |
| `Export` | "this export" | "The output type for this export." |
| `Type` | "this type" | "Whether this type is boundable." |

```ruby
# Good — complete, natural English
# Whether this param is nullable.
# Returns whether this action is deprecated.
# The model class for this representation.
# Actions defined on this contract.

# Bad — incomplete fragments
# Whether nullable.
# Returns whether deprecated.
# The model class.
# Defined actions.
```

**Why?** Documentation is read in isolation (IDE tooltips, YARD HTML). Each description must stand alone.

### Predicate Pattern

All `?` methods use exactly this pattern:

```ruby
# Whether this [noun] is [adjective].
```

**Examples:**

```ruby
# Good — consistent pattern
# Whether this param is nullable.
# Whether this param is optional.
# Whether this param is deprecated.
# Whether this param is boundable.
# Whether this param is formattable.
# Whether this action is deprecated.
# Whether this enum is deprecated.

# Bad — mixed patterns
# Whether this param supports bounds.
# Returns whether nullable.
# Whether nullable.
```

**No exceptions.** The adjective comes from the method name (`nullable?` → "nullable").

### Voice & Tense

- **Active voice only**: "Transforms the body" not "The body is transformed"
- **Present tense only**: "Finds" not "Will find"
- **Imperative form**: "Finds", "Defines", "Returns"

### Capitalization

| Element | Case | Example |
|---------|------|---------|
| Method description | Uppercase start, period | "Finds an API by path." |
| @param description | lowercase, no period | "the mount path" |
| @return | type only, no description | `[API::Base]` |
| Class-level docs | Full sentence with period | "Base class for API definitions." |

---

## @param Format

### Description Always Required

```ruby
# ALWAYS include description
@param name [Symbol] the adapter name
@param klass [Class] the serializer class
@param value [String] the configuration value

# With default
@param replace [Boolean] replace existing (default: false)

# With enum values
@param format [Symbol] :keep, :camel, :underscore, or :kebab
```

**Why?** Same as @return — consistency over "obviousness."

### Rules

- Lowercase description, no period
- Static defaults: `(default: X)` at end of description
- Dynamic defaults: brief note in method description instead
- Enum values: list with colons in description
- Include `nil` in type if parameter accepts nil

**Check:**
```bash
grep -rn "Defaults to" lib/
```

---

## @return Format

### No Description — Type Only

```ruby
@return [void]
@return [String]
@return [Symbol, nil]
@return [Class<Adapter::Base>]
@return [Boolean]
```

**Why?** The method description already explains what the method does/returns. The @return tag provides type information only. No redundancy.

### Forbidden

- Any description after type: `@return [String] the name` — redundant
- "or nil if not found" — redundant, type shows `nil`
- "or nil when X" — redundant, type shows `nil`

### Instance vs Class Types

Use `Class<Type>` when returning a class object (not an instance):

```ruby
# Instance return
@return [Adapter::Base]

# Class return
@return [Class<Adapter::Base>]
```

---

## @see Rules

### Always Use @see For

1. **find/find! pairs** — always cross-reference:
```ruby
# @see .find!
def find(key)

# @see .find
def find!(key)
```

2. **Delegates** — link to source method:
```ruby
# @api public
# @see Request#query
# @return [Hash] parsed query parameters
delegate :query, to: :request
```

3. **Related methods** — when behavior is connected:
```ruby
# @see .register
def find(key)
```

### Link Syntax

```ruby
# Instance method in same class
@see #other_method

# Class method in same class
@see .other_method

# Method in other class
@see OtherClass#method
@see OtherClass.method

# Class reference
@see OtherClass
```

**Check:**
```bash
# find without @see .find!
grep -B5 "def find(" lib/ | grep -L "@see .find!"
```

---

## @raise Rules

### Always Document @raise For

1. **ArgumentError** — when validating input:
```ruby
# @raise [ArgumentError] if klass is not a Representation subclass
def representation(klass)
```

2. **KeyError** — for find! methods:
```ruby
# @raise [KeyError] if not found
def find!(key)
```

3. **ConfigurationError** — for invalid configuration:
```ruby
# @raise [ConfigurationError] if error code is not registered
def error(code)
```

### Never Document @raise For

- `NotImplementedError` in abstract methods (self-evident)
- Internal errors that users can't trigger

---

## @yield / @yieldparam Rules

### When Block Has Named Parameter — Use Both

```ruby
# @yield block for configuration
# @yieldparam config [Configuration] the configuration object
def configure(&block)
  config = Configuration.new
  yield(config) if block
end
```

### When Block Uses instance_eval — Only @yield

```ruby
# @yield block evaluated in resource context
def resource(name, &block)
  instance_eval(&block)
end
```

### Format

```ruby
# @yield description of what block does
# @yieldparam name [Type] description (lowercase, no period)
```

---

## @example Format

**Code examples must follow CLAUDE.md style guide.** No exceptions.

### Titles

- **Single example** — title optional
- **Multiple examples** — title required on each

```ruby
# Single — no title needed
# @example
#   Apiwork::API.find('/api/v1')

# Multiple — titles required
# @example Basic usage
#   Apiwork::API.find('/api/v1')
#
# @example With block
#   Apiwork::API.define '/api/v1' do
#     resources :users
#   end
```

### Format Rules

- Runnable code (not pseudocode)
- Output shown with `# =>`
- Multi-line blocks use proper indentation

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
grep -rn "Defaults to" lib/

# Punctuation violations
grep -rn "@param.*\.\$" lib/

# @return with description (forbidden)
grep -rn "@return \[[^]]*\] [a-z]" lib/

# Type violations
grep -rn "@return \[Class\]" lib/
grep -rn "@raise \[NotImplementedError\]" lib/

# All clean = Exit: 1
grep -rn "Gets or sets" lib/; echo "Exit: $?"
```

---

## Audit Checklist

### Directories

- [ ] `lib/apiwork/api/`
- [ ] `lib/apiwork/adapter/`
- [ ] `lib/apiwork/contract/`
- [ ] `lib/apiwork/representation/`
- [ ] `lib/apiwork/export/`
- [ ] `lib/apiwork/introspection/`
- [ ] `lib/apiwork/*.rb`

### For Each `@api public` Method

1. **Tag order:** description → @api public → @param → @yield → @return → @raise → @see → @example
2. **Description:** starts with verb/noun, ends with period
3. **@param:** lowercase, no period, includes `nil` if optional
4. **@return:** type only, no description
5. **@see:** present for find/find! pairs and delegates
6. **@raise:** documented for validation errors
7. **@yield/@yieldparam:** both present when block has named param
8. **@example:** titles on multiple examples
9. **Types:** `Class<Type>` for class returns, no bare `[Class]`
10. **No forbidden phrases**
