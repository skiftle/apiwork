# YARD Documentation

Rules for YARD documentation in `lib/apiwork/`.

**Every `@api public` method has a description. No exceptions.**

---

## Core Principle

Descriptions are mechanical. Category + formula + glossary = description.

**Quality check for every description:**

1. Apply formula mechanically
2. Grammatically correct?
3. Factually correct?
4. If no → adjust until both are satisfied

---

## Method Categories

### Decision Tree

```
1. Ends with `?`
   → Predicate

2. Ends with `!`
   → Mutator

3. Takes `&block`
   → DSL/Builder

4. Starts with `find`
   → Finder

5. Starts with `transform`/`normalize`
   → Transformer

6. Starts with `to_`
   → Converter

7. Starts with `build`/`create`
   → Factory

8. Starts with `register`/`add`
   → Registrar

9. Returns value, has fallback/computation
   → Computed getter

10. Returns value, no logic
    → Simple getter
```

---

## Formulas by Category

| Category | Formula | Example |
|----------|---------|---------|
| Simple getter | See Context-Based Formula | "The API title." / "The format for this param." |
| Predicate | "Whether [context] [glossary term]." | "Whether this param is boundable." |
| Mutator | "Marks [context] as [state]." | "Marks this contract as abstract." |
| Finder | "Finds [what] by [key]." | "Finds an API by mount path." |
| Finder (bang) | "Finds [what] by [key]." + `@raise` | Same + `@raise [KeyError]` |
| Converter | "Converts [context] to [format]." | "Converts this param to a hash." |
| Transformer | "Transforms [what]." | "Transforms request keys." |
| Factory | "Creates [what]." | "Creates a new request context." |
| Registrar | "Registers [what]." | "Registers an adapter." |
| DSL/Builder | See DSL/Builder Rules | "Defines an action..." / "The API contact." |
| Computed getter | "Uses {#method} if set, otherwise [fallback]." | "Uses {#type_name} if set, otherwise the model's `sti_name`." |

**Note:** `[context]` already includes "this" or "the" from Context Table.

### The [what] Rule

The `[what]` is the method name. Apply these transformations:

| Transformation | Example |
|----------------|---------|
| Underscores → spaces | `terms_of_service` → "terms of service" |
| Add clarifying context when needed | `status` → "HTTP status" (in ErrorCode) |

### Context-Based Formula

| Context starts with | Formula | Example |
|---------------------|---------|---------|
| "the" | "The [context without 'the'] [what]." | "The API title." |
| "this" | "The [what] for [context]." | "The format for this param." |

```ruby
# Info class — context is "the API"
# @api public
# The API title.
def title

# Info class — underscore method
# @api public
# The API terms of service.
def terms_of_service

# Param class — context is "this param"
# @api public
# The format for this param.
def format

# ErrorCode class — add clarifying context
# @api public
# The HTTP status for this error code.
def status
```

### DSL/Builder Rules

Methods that take `&block`. Check these signals in order:

| Signal | Formula | Example |
|--------|---------|---------|
| Takes name/key parameter | "Defines a/an [what]..." | `action(name, &block)` → "Defines an action for this contract." |
| `@return [Array<T>]` or `[Hash]` | "Defines a/an [what]..." | `server(&block)` → "Defines a server for the API." |
| `@return [void]` | "Defines [what]..." | (rare) |
| `@return [T]` (single object) | "The [what]." | `contact(&block)` → "The API contact." |

```ruby
# Takes name parameter — defines one of many named items
# @api public
# Defines an action for this contract.
def action(name, &block)

# Adds to collection — defines one of many
# @api public
# Defines a server for the API.
#
# Can be called multiple times.
def server(&block)

# Returns single object — getter/builder hybrid
# @api public
# The API contact.
def contact(&block)

# Returns single object — getter/builder hybrid
# @api public
# The request for this action.
def request(&block)
```

---

## Context Table

The context is inserted directly into formulas. Include "this" or "the" in the value.

### Domain Classes (use "this")

| Class | Context |
|-------|---------|
| Action | "this action" |
| API::Base | "this API" |
| Adapter | "this adapter" |
| Association | "this association" |
| Attribute | "this attribute" |
| Capability | "this capability" |
| Contract | "this contract" |
| Controller | "this controller" |
| Enum | "this enum" |
| ErrorCode | "this error code" |
| Export | "this export" |
| Inheritance | "this inheritance" |
| Issue | "this issue" |
| Operation | "this operation" |
| Param::* | "this param" |
| Representation | "this representation" |
| Request | "this request" |
| Resource | "this resource" |
| Response | "this response" |
| Serializer | "this serializer" |
| Transformer | "this transformer" |
| Type | "this type" |
| Wrapper | "this wrapper" |

### Helper Classes (use "the")

| Class | Context |
|-------|---------|
| Info | "the API" |
| Contact | "the contact" |
| License | "the license" |
| Server | "the server" |
| RootKey | "the root key" |

### Nested Classes

| Class | Context |
|-------|---------|
| Definition | use parent context |
| Shape | use parent context |

**Class not in table?** Add it before writing YARD.

---

## Domain Glossary

Use these exact phrases in predicate descriptions:

| Term | Meaning | Used in |
|------|---------|---------|
| `is abstract` | has no concrete implementation | contracts |
| `is boundable` | supports min/max constraints | params |
| `is deprecated` | scheduled for removal | all |
| `is filterable` | can be used in filter queries | attributes |
| `is formattable` | supports format hints (email, uri, etc.) | params |
| `is nullable` | accepts null values | params |
| `is optional` | not required in requests | params |
| `is partial` | uses partial serialization | associations |
| `is readable` | exposed in responses | attributes |
| `is scalar` | a single value (not array/object) | params |
| `is sortable` | can be used in sort queries | attributes |
| `is writable` | can be modified on create or update | attributes |
| `has a default` | has a default value | params |
| `has an enum` | has enumerated values | params |
| `has an example` | has an example value | params |
| `is a collection` | a has_many association | associations |
| `is singular` | a has_one or belongs_to association | associations |
| `is an enum reference` | references an enum defined elsewhere | params |
| `is numeric` | represents numerical values | params |
| `is a literal` | a fixed/constant value | params |
| `is a reference` | references another type | params |
| `needs transform` | requires value transformation | inheritance |

### Type Predicates

For type-checking predicates (`string?`, `integer?`, `array?`, etc.):

| Method | Description |
|--------|-------------|
| `string?` | "Whether this param is a string." |
| `integer?` | "Whether this param is an integer." |
| `number?` | "Whether this param is a number." |
| `decimal?` | "Whether this param is a decimal." |
| `boolean?` | "Whether this param is a boolean." |
| `array?` | "Whether this param is an array." |
| `object?` | "Whether this param is an object." |
| `union?` | "Whether this param is a union." |
| `date?` | "Whether this param is a date." |
| `datetime?` | "Whether this param is a datetime." |
| `time?` | "Whether this param is a time." |
| `uuid?` | "Whether this param is a UUID." |
| `binary?` | "Whether this param is binary data." |
| `unknown?` | "Whether this param is of unknown type." |

---

## Examples

### Simple Getter

```ruby
# @api public
# The format for this param.
#
# @return [Symbol, nil]
def format

# @api public
# The name of the API.
#
# @return [String]
def name

# @api public
# The singular form of the root key.
#
# @return [String]
def singular
```

### Predicate (Glossary Term)

```ruby
# @api public
# Whether this param is boundable.
#
# @return [Boolean]
def boundable?
```

### Predicate (Type Check)

```ruby
# @api public
# Whether this param is a string.
#
# @return [Boolean]
def string?
```

### Predicate (Info class - uses "the")

```ruby
# @api public
# Whether the API is deprecated.
#
# @return [Boolean]
def deprecated?
```

### Mutator

```ruby
# @api public
# Marks this contract as abstract.
#
# @return [void]
def abstract!
```

### Finder

```ruby
# @api public
# Finds an API by mount path.
#
# @param path [String]
# @return [API::Base, nil]
def find(path)
```

### Finder (Bang)

```ruby
# @api public
# Finds an API by mount path.
#
# @param path [String]
# @return [API::Base]
# @raise [KeyError] if not found
# @see .find
def find!(path)
```

### Converter

```ruby
# @api public
# Converts this param to a hash.
#
# @return [Hash]
def to_h
```

### DSL/Builder

```ruby
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

### Computed Getter

```ruby
# @api public
# Uses {#type_name} if set, otherwise the model's `sti_name`.
#
# @return [String]
def sti_name
```

---

## Tag Order

Strict order for all `@api public` methods:

```ruby
# @api public
# Description.
#
# Optional extra context.
#
# @param name [Type] description
# @yield description
# @yieldparam name [Type]
# @return [Type]
# @raise [Error] description
# @see #other_method
#
# @example Title if multiple
#   code_here
```

**Order:** `@api public` → description → `@param` → `@yield` → `@yieldparam` → `@return` → `@raise` → `@see` → `@example`

---

## @param Format

Type in brackets. Default in parentheses. Values in square brackets. Description last.

### Pattern

```
@param name [Type] (default) [:value1, :value2] description
```

All parts after `[Type]` are optional:

1. `[Type]` — type in brackets (required)
2. `(default)` — default value in parentheses
3. `[:values]` — allowed values in square brackets
4. Description — freeform text

### Type Formats

| Scenario | Format |
|----------|--------|
| Simple type | `[Symbol]` |
| Nullable type | `[Symbol, nil]` |
| Boolean | `[Boolean]` |
| Nullable boolean | `[Boolean, nil]` |
| Hash with structure | `[Hash{on: Array<Symbol>}]` |
| Container type | `[Array<String>]` |

### Examples

**Just type (required param):**
```ruby
# @param name [Symbol]
```

**With default:**
```ruby
# @param deprecated [Boolean] (false)
```

**With values:**
```ruby
# @param type [Symbol] [:string, :integer, :boolean]
```

**With default + values:**
```ruby
# @param include [Symbol] (:optional) [:always, :optional]
```

**With description:**
```ruby
# @param optional [Boolean, nil] auto-detected from model
```

**All parts:**
```ruby
# @param format [Symbol] (:json) [:json, :xml] output format
```

### Generated Output

The reference generator creates a table with dynamic columns:

| Name | Type | Default | Values | Description |
|------|------|---------|--------|-------------|
| `name` | `Symbol` | | | |
| `deprecated` | `Boolean` | `false` | | |
| `include` | `Symbol` | `:optional` | `:always`, `:optional` | |
| `optional` | `Boolean, nil` | | | auto-detected from model |

- **Name** + **Type**: always shown
- **Default**: shown if any param has `(value)`
- **Values**: shown if any param has `[:values]` (without brackets in output)
- **Description**: shown if any param has text

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

### Type Rules

| Rule | Bad | Good |
|------|-----|------|
| Class returns use `Class<Type>` | `@return [Class]` | `@return [Class<Adapter::Base>]` |
| Include nil if can return nil | `@return [String]` | `@return [String, nil]` |

---

## @yield / @yieldparam

| Signal in code | Use |
|----------------|-----|
| `yield(object)` or `block.call(object)` | `@yieldparam` only |
| `instance_eval(&block)` | `@yield` only |
| Checks arity, supports both | Both `@yield` and `@yieldparam` |

---

## @see Rules

**Use @see for:**
- find/find! pairs
- Delegates to `@api public` methods
- Methods that reference another method in description

**Format:**
```ruby
@see #instance_method
@see .class_method
@see OtherClass#method
```

---

## @example Rules

- DSL/void methods: `@example` is mandatory
- Code must be runnable
- Output shown with `# =>`
- Use domain terms: invoice, customer, item
- Never: foo, bar, baz, test, example

---

## Punctuation

| Element | Rule |
|---------|------|
| Description | Uppercase start, period |
| @param | lowercase, no period |
| @return | type only, no description |

---

## Audit Checklist

For each `@api public` method:

1. [ ] Has a description (no exceptions)
2. [ ] Description matches formula for its category
3. [ ] Uses glossary term for predicates
4. [ ] @param: signal-based format
5. [ ] @return: type only
6. [ ] @yield/@yieldparam: signal-based
7. [ ] DSL/void methods have @example
8. [ ] Tag order correct
9. [ ] Class returns use `Class<Type>`
10. [ ] Nil included in type if can return nil

---

## Verification

```bash
bundle exec rake apiwork:docs:reference
```

Review generated documentation for consistency.
