# YARD & Documentation Audit

Checklist for auditing YARD documentation in `lib/apiwork/`.

**Consistency is mandatory. No deviations. No subjective decisions.**

---

## Description Rules

**Description only when it adds information beyond the signature.**

Signature = method name + parameters + return type. If these say everything, no description.

### When to Add Description

| Method category | Description needed? |
|-----------------|---------------------|
| Simple getter (returns stored value) | NO |
| Predicate (ends with `?`) | NO |
| Mutator (ends with `!`) | NO |
| Computed getter (has logic/fallbacks) | YES — describe the logic |
| Void/DSL method | YES + `@example` required |
| Finder | YES — "Finds X by Y." |
| Transformer | YES — "Transforms X." |
| Factory | YES — "Creates X." |

### Step 1: Determine Category

| Signal | Category |
|--------|----------|
| Ends with `?` | Predicate |
| Ends with `!` | Mutator |
| Has `&block` | DSL/Builder |
| Starts with `find` | Finder |
| Starts with `transform`/`normalize` | Transformer |
| Starts with `build`/`create` | Factory |
| Starts with `register`/`add` | Registrar |
| Returns value, has fallback/logic | Computed getter |
| Returns value, no logic | Simple getter |

### Step 2: Apply Rules by Category

**Predicates (`?` methods):**

NO description. Ever. The method name is the documentation.

```ruby
# @api public
# @return [Boolean]
def deprecated?

# @api public
# @return [Boolean]
def writable?

# @api public
# @return [Boolean]
def boundable?
```

Domain knowledge is expected. If the caller doesn't understand what `boundable?` means, they can read the class examples or the code.

**Mutators (`!` methods):**

NO description. The method name + return type say it all.

```ruby
# @api public
# @return [void]
def deprecated!

# @api public
# @return [void]
def abstract!
```

**Computed Getter Formula** (when there's fallback logic):
```
Uses {#method} if set, otherwise [fallback].
Derived from [source].
```

**Finder Formula**:
```
Finds [thing] by [key].
```

**DSL Formula**:
```
Defines [thing].
```

### Step 3: Lookup Context (when using formula)

| Class | Type | Context/Qualifier |
|-------|------|-------------------|
| Action | domain | "this action" |
| API::Base | domain | "this API" |
| Adapter | domain | "this adapter" |
| Association | domain | "this association" |
| Attribute | domain | "this attribute" |
| Capability | domain | "this capability" |
| Contract | domain | "this contract" |
| Controller | domain | "this controller" |
| Enum | domain | "this enum" |
| Export | domain | "this export" |
| Inheritance | domain | "this inheritance" |
| Issue | domain | "this issue" |
| Operation | domain | "this operation" |
| Param::* | domain | "this param" |
| Representation | domain | "this representation" |
| Request | domain | "this request" |
| Resource | domain | "this resource" |
| Response | domain | "this response" |
| Serializer | domain | "this serializer" |
| Transformer | domain | "this transformer" |
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
# Simple getter — NO description
# @api public
# @return [String]
attr_reader :name

# Predicate — NO description
# @api public
# @return [Boolean]
def deprecated?

# @api public
# @return [Boolean]
def writable?

# @api public
# @return [Boolean]
def boundable?

# Mutator — NO description
# @api public
# @return [void]
def deprecated!

# @api public
# @return [void]
def abstract!

# Computed getter — description needed (fallback logic)
# @api public
# Uses {#type_name} if set, otherwise the model's `sti_name`.
#
# @return [String]
def sti_name

# Finder — description needed
# @api public
# Finds an API by mount path.
#
# @param path [String]
# @return [API::Base, nil]
def find(path)

# DSL — description + @example needed
# @api public
# Defines an action on this contract.
#
# @param name [Symbol]
# @yieldparam action [Action]
# @return [Action]
#
# @example
#   action :create do |action|
#     action.request { body { string :title } }
#   end
def action(name, &block)
```

### Style

- Direct and factual
- Active voice, present tense
- No filler words ("This method", "allows you to")
- Describe behavior, not existence

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

### Signal-Based Rules

Check the method signature for signals. Apply rules mechanically.

| Signal in signature | @param format |
|---------------------|---------------|
| `name` (no default) | `@param name [Type]` |
| `name = value` | `@param name [Type] (default: value)` |
| `name = nil` | `@param name [Type, nil]` |

### Default Values

**Signal:** `= value` in method signature.

```ruby
# Signature: def action(name, replace: false)
@param name [Symbol]
@param replace [Boolean] (default: false)

# Signature: def find(key, scope: nil)
@param key [Symbol]
@param scope [Symbol, nil]

# Signature: def paginate(limit: 25, offset: 0)
@param limit [Integer] (default: 25)
@param offset [Integer] (default: 0)
```

**Rule:** If signature has `= nil`, type includes `nil` but no `(default: nil)`.

### Enum Values

**Signal:** Known from code inspection (validation, constant, or explicit annotation).

| Count | Format |
|-------|--------|
| 2 values | `:a or :b` |
| 3 values | `:a, :b, or :c` |
| 4+ values | `see {CONSTANT}` or list if no constant |

```ruby
# 2 values
@param direction [Symbol] :asc or :desc

# 3 values
@param format [Symbol] :json, :xml, or :csv

# 4+ values — reference constant
@param status [Symbol] see {STATUS_VALUES}

# Enum + default
@param direction [Symbol] :asc or :desc (default: :asc)
```

### Constraints

**Signal:** Validation in method body or semantic meaning.

```ruby
# Positive constraint
@param limit [Integer] must be positive

# Behavior explanation
@param fallback [String, nil] used if primary is blank
```

### Skip Description When

- Parameter name is self-evident: `name`, `id`, `key`, `value`
- Type annotation is sufficient: `klass [Class<Adapter::Base>]`
- No default, no enum, no constraint

```ruby
# Self-evident — no description
@param name [Symbol]
@param id [Integer]
@param klass [Class<Adapter::Base>]
```

### Decision Tree

```
1. Has `= nil` in signature?
   → Add nil to type: [Type, nil]
   → No description needed for default

2. Has `= value` (non-nil) in signature?
   → Add (default: value) at end

3. Has known enum values?
   → 2-3 values: list inline with "or"
   → 4+ values: reference constant

4. Has constraint or special behavior?
   → Add brief description

5. None of above?
   → Type only, no description
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

### Signal-Based Rules

Check how the block is called in the method body.

| Signal in code | Use |
|----------------|-----|
| `yield(object)` or `block.call(object)` | `@yieldparam` only |
| `instance_eval(&block)` or `instance_exec(&block)` | `@yield` only |

### Yield-style (block receives parameter)

**Signal:** `yield(x)`, `block.call(x)`, `block.arity.positive?`

```ruby
# Code: yield(action)
# Use only @yieldparam — @yield is redundant

# @yieldparam action [Action]
def action(name, &block)
  action = Action.new(name)
  yield(action) if block
end
```

### instance_eval-style (no parameter)

**Signal:** `instance_eval(&block)`, `instance_exec(&block)`

```ruby
# Code: instance_eval(&block)
# Use only @yield — no parameter to document

# @yield block evaluated in action context
def action(name, &block)
  action = Action.new(name)
  action.instance_eval(&block) if block
end
```

### Hybrid (supports both)

**Signal:** `block.arity.positive? ? yield(x) : instance_eval(&block)`

```ruby
# Code checks arity
# Document both styles

# @yield block evaluated in action context (instance_eval style)
# @yieldparam action [Action] (yield style)
def action(name, &block)
  action = Action.new(name)
  if block
    block.arity.positive? ? yield(action) : action.instance_eval(&block)
  end
end
```

### Decision Tree

```
1. Check method body for block usage

2. Uses yield(x) or block.call(x)?
   → @yieldparam name [Type] only

3. Uses instance_eval(&block)?
   → @yield description only

4. Checks arity and supports both?
   → Both @yield and @yieldparam
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

# Predicates with unnecessary descriptions (should be rare)
# Only predicates with jargon, hidden logic, or ambiguity need descriptions
grep -rn "# Whether this.*is " lib/

# Void methods missing @example (manual check required)
```

---

## Audit Checklist

For each `@api public` method:

1. [ ] Simple getters: NO description
2. [ ] Predicates (`?`): NO description
3. [ ] Mutators (`!`): NO description
4. [ ] Computed getters: describe the logic/fallback
5. [ ] Void/DSL methods: verb prefix + `@example`
6. [ ] Finders: "Finds X by Y."
7. [ ] @param: signal-based (default, enum, constraint, or skip)
8. [ ] @return: type only, no description
9. [ ] @yield/@yieldparam: signal-based (yield vs instance_eval)
10. [ ] Class returns use `Class<Type>`, never bare `[Class]`
11. [ ] If signature has `= nil`, type includes nil
12. [ ] No forbidden phrases
13. [ ] Tag order correct
