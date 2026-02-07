# YARD & Documentation Audit

Checklist for auditing YARD documentation in `lib/apiwork/`.

**Consistency is mandatory. No deviations. No subjective decisions.**

---

## Mechanical Description Rules

Descriptions are generated mechanically based on `@return` type and class context. No creativity allowed.

### Step 1: Check @return Type

| @return | Rule |
|---------|------|
| `[void]` | Description + `@example` required (see Void Methods) |
| `[Boolean]` + method ends with `?` | Use Predicate Formula |
| Anything else | Use Getter Formula |

### Step 2: Apply Formula

**Predicate Formula** (`@return [Boolean]`, method ends with `?`):
```
Whether this [context] is [method_name_without_?].
```

**Getter Formula** (all other non-void):
```
# Domain class:
The [method] for this [context].

# Helper class:
The [qualifier] [method].
```

### Step 3: Lookup Context

| Class | Type | Context/Qualifier |
|-------|------|-------------------|
| Action | domain | "this action" |
| API::Base | domain | "this API" |
| Adapter | domain | "this adapter" |
| Association | domain | "this association" |
| Attribute | domain | "this attribute" |
| Capability | domain | "this capability" |
| Contract | domain | "this contract" |
| Enum | domain | "this enum" |
| Export | domain | "this export" |
| Issue | domain | "this issue" |
| Operation | domain | "this operation" |
| Param::* | domain | "this param" |
| Representation | domain | "this representation" |
| Request | domain | "this request" |
| Resource | domain | "this resource" |
| Response | domain | "this response" |
| Type | domain | "this type" |
| Wrapper | domain | "this wrapper" |
| Info | helper | "API" |
| Contact | helper | "contact" |
| License | helper | "license" |
| Server | helper | "server" |
| Definition | helper | use parent context |
| Shape | helper | use parent context |

**Class not in table?** Add it before writing YARD.

### Examples

```ruby
# Predicate in Action class
# method: deprecated?
# @return [Boolean]
# Formula: Whether this [action] is [deprecated].
# Result:
# Whether this action is deprecated.

# Getter in Action class
# method: summary
# @return [String, nil]
# Formula: The [summary] for this [action].
# Result:
# The summary for this action.

# Getter in Contact class (helper)
# method: name
# @return [String, nil]
# Formula: The [contact] [name].
# Result:
# The contact name.

# Getter in Info class (helper)
# method: title
# @return [String, nil]
# Formula: The [API] [title].
# Result:
# The API title.
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

## Extra Context (Optional Second Paragraph)

After the mechanical description, you MAY add extra context. Each line must follow a formula:

| Type | Formula |
|------|---------|
| Preference | "Prefer [alternative]." |
| Default behavior | "Defaults to [value] when [condition]." |
| Constraint | "Must be [requirement]." / "Cannot be [X]." |
| When to use | "Use when [scenario]." |
| When to avoid | "Avoid when [scenario]." |
| Behavior | "Can be [action]." |

**Examples:**

```ruby
# @api public
# Defines a param with explicit type.
#
# Prefer sugar methods (string, integer, etc.) for static definitions.
#
# @param name [Symbol] the param name
# @return [void]
#
# @example
#   param :status, type: :string, enum: %w[draft sent]
def param(name, type: nil, ...)

# @api public
# Defines a server for this API.
#
# Can be called multiple times to define multiple servers.
#
# @param url [String] the server URL
# @return [void]
#
# @example
#   server 'https://api.example.com'
def server(url, &block)
```

**Forbidden in extra context:**
- "It's important to note..."
- "This method..."
- Passive voice
- Any phrase not matching the formulas above

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
# Always include description
@param name [Symbol] the adapter name
@param klass [Class<Adapter::Base>] the adapter class

# With default
@param replace [Boolean] replace existing (default: false)

# With enum values
@param format [Symbol] :keep, :camel, :underscore, or :kebab

# Include nil if optional
@param value [String, nil] the value
```

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

1. [ ] @return type determines which formula to use
2. [ ] Description follows exact formula (no variations)
3. [ ] Context from lookup table (no guessing)
4. [ ] Extra context uses allowed formulas only
5. [ ] Void methods have verb prefix + @example
6. [ ] Tag order correct
7. [ ] @param lowercase, no period
8. [ ] @return type only, no description
9. [ ] Class returns use `Class<Type>`, never bare `[Class]`
10. [ ] If signature has `= nil`, type includes nil
11. [ ] Class returns described as "X class" (not just "X")
12. [ ] No forbidden phrases
