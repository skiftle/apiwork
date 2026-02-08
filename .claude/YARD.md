# YARD & Documentation Audit

Checklist for auditing YARD documentation in `lib/apiwork/`.

**Consistency is mandatory. No deviations. No subjective decisions.**

---

## Description Rules

**Principle:** Only describe what the reader cannot already infer from the method name and type.

### When to Skip

If the method name + type tells the full story, skip the description.

```ruby
# @api public
# @return [String, nil]
def email

# @api public
# @return [Boolean]
def deprecated?
```

### When to Write

Write when there is extra information: behavior, domain terms, fallback logic, scope.

### Style

- Direct and factual
- Active voice, present tense
- No filler words ("This method", "allows you to")
- Describe behavior, not existence

```ruby
# Good — describes behavior
# @api public
# Transforms request and response keys in query and body.
#
# @return [Symbol, nil]
def key_format

# Good — explains fallback
# @api public
# Uses type_name if set, otherwise the model's sti_name.
#
# @return [String]
# @see #type_name
def sti_name

# Good — explains domain term
# @api public
# The Single Table Inheritance type name for polymorphic serialization.
#
# @return [String]
def polymorphic_name
```

---

## Void Methods

Methods with `@return [void]` require:
1. Description using verb prefix from table below
2. `@example` (mandatory)

### Verb Prefix by Method Pattern

| Method pattern | Verb | Example |
|----------------|------|---------|
| `find*` | "Finds" | "Finds an API by mount path." |
| `register*` | "Registers" | "Registers an adapter." |
| `define*`, DSL methods | "Defines" | "Defines a reusable object type." |
| `transform*` | "Transforms" | "Transforms the request body." |
| `to_*` | "Converts" | "Converts this param to a hash." |
| `create*`, `build*` | "Creates" | "Creates a new request context." |
| `set*`, `configure*` | "Sets" / "Configures" | "Sets the target for this operation." |

```ruby
# @api public
# Defines a reusable object type scoped to this contract.
#
# @param name [Symbol] the object name
# @return [void]
#
# @example
#   object :address do
#     string :street
#   end
def object(name, &block)
```

---

## Additional Context (Optional Second Paragraph)

After the description, you MAY add additional context when needed.

### Allowed Phrases

| Type | Pattern |
|------|---------|
| Preference | "Prefer [alternative]." |
| Default | "Defaults to [value] when [condition]." |
| Constraint | "Must be [requirement]." / "Cannot be [X]." |
| Usage | "Use when [scenario]." / "Avoid when [scenario]." |
| Behavior | "Can be [action]." / "Called multiple times to [effect]." |

### Examples

```ruby
# @api public
# Defines a param with explicit type.
#
# Prefer sugar methods (string, integer, etc.) for cleaner syntax.
#
# @param name [Symbol] the param name
# @return [void]
#
# @example
#   param :status, type: :string, enum: %w[draft sent]
def param(name, type: nil, ...)

# @api public
# Scopes types, enums, and unions defined on this contract.
#
# For example, a type :address becomes :invoice_address when
# identifier is :invoice. Derived from representation's root_key
# if not set.
#
# @param value [Symbol, String, nil] the scope prefix
# @return [String, nil]
def identifier(value = nil)
```

### Forbidden

- "It's important to note..."
- "This method..."
- Passive voice
- Marketing language ("powerful", "seamlessly", "simply")

---

## Forbidden Phrases (Anywhere)

| Forbidden | Fix |
|-----------|-----|
| "Gets or sets the X" | "The X." (getter formula) |
| "Without arguments, returns..." | delete (redundant with @return) |
| "With an argument, sets..." | delete (redundant with @param) |
| "Will return" | "Returns" |
| "is transformed" | "Transforms" |
| "allows you to" | delete or rephrase |
| "powerful", "seamlessly", "simply" | delete |
| "query params", "body params" | "query", "body" |

---

## Tag Order

Strict order for all `@api public` methods:

```ruby
# @api public
# Mechanical description.
#
# Optional extra context following formulas.
#
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

**Order:** `@api public` → description → `@param` → `@yield` → `@yieldparam` → `@return` → `@raise` → `@see` → `@example`

---

## Punctuation

| Element | Rule | Example |
|---------|------|---------|
| Description | Uppercase start, period | "The summary for this action." |
| @param | lowercase, no period | "the object name" |
| @return | type only, no description | `[String, nil]` |

---

## @param Format

```ruby
# Self-evident — skip description
@param name [Symbol]
@param id [Integer]
@param klass [Class<Adapter::Base>]

# Constraint — include description
@param direction [Symbol] :asc or :desc
@param limit [Integer] must be positive

# Default value — include description
@param replace [Boolean] (default: false)

# Behavior — include description
@param fallback [String, nil] used if primary is blank

# Include nil in type if optional
@param value [String, nil]
```

Same principle as method descriptions: only describe when it adds information.

---

## @return Format

Type only. No description.

```ruby
@return [void]
@return [String]
@return [Symbol, nil]
@return [Class<Adapter::Base>]
@return [Boolean]
```

**Forbidden:**
- `@return [String] the name` — redundant
- `@return [Class]` — too vague, use `Class<Type>`

### Type Rules

| Rule | Bad | Good |
|------|-----|------|
| Class returns use `Class<Type>` | `@return [Class]` | `@return [Class<Adapter::Base>]` |
| If signature has `= nil`, include nil | `@param name [Symbol]` | `@param name [Symbol, nil]` |
| Class params specify type | `@param klass [Class]` | `@param klass [Class<Representation::Base>]` |

When method returns a class (not instance), description says "X class":

```ruby
# Good — explicit "class"
# The representation class for this association.

# Bad — ambiguous (could be instance)
# The representation for this association.
```

---

## @see Rules

**Use @see for:**
- find/find! pairs (cross-reference)
- Delegates to `@api public` methods
- Methods that reference another method in description (e.g., "Uses type_name if set")

**Never use @see for:**
- Getter/predicate pairs (implicit in Ruby)

### Link Syntax

```ruby
@see #method           # Instance method, same class
@see .method           # Class method, same class
@see OtherClass#method # Instance method, other class
@see OtherClass.method # Class method, other class
@see OtherClass        # Class reference
```

---

## @raise Rules

**Document @raise for:**
- ArgumentError — input validation
- KeyError — find! methods
- ConfigurationError — invalid configuration

**Never document:**
- NotImplementedError in abstract methods

---

## @yield / @yieldparam

```ruby
# Block with named parameter — use both
# @yield block for configuration
# @yieldparam config [Configuration] the configuration object

# Block with instance_eval — only @yield
# @yield block evaluated in resource context
```

---

## @example Format

- Void methods: `@example` is mandatory
- Single example: title optional
- Multiple examples: title required on each
- Code must be runnable
- Output shown with `# =>`

---

## Validation

```bash
# Forbidden phrases
grep -rn "It's important" lib/
grep -rn "This method" lib/
grep -rn "allows you to" lib/
grep -rn "Gets or sets" lib/
grep -rn "Without arguments" lib/
grep -rn "Will return" lib/

# Punctuation violations
grep -rn "@param.*\.$" lib/

# Type violations
grep -rn "@return \[Class\]$" lib/
grep -rn "@param.*\[Class\]" lib/

# @return with description (forbidden)
grep -rn "@return \[[^]]*\] [a-z]" lib/

# Predicates not following formula
grep -rn "# Whether" lib/ | grep -v "Whether this"

# Void methods missing @example (manual check required)
```

---

## Audit Checklist

For each `@api public` method:

1. [ ] Description only if it adds info beyond method name + type
2. [ ] Description uses mechanical pattern (transformation, fallback, etc.)
3. [ ] No redundant descriptions ("The email." on `def email`)
4. [ ] Void methods have verb prefix + @example
5. [ ] Tag order correct
6. [ ] @param lowercase, no period
7. [ ] @return type only, no description after type
8. [ ] Class returns use `Class<Type>`, never bare `[Class]`
9. [ ] If signature has `= nil`, type includes nil
10. [ ] No forbidden phrases
