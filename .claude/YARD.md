# YARD Documentation

Rules for YARD documentation in `lib/apiwork/`.

**Every `@api public` method has a description. No exceptions.**

---

## Core Principle

Descriptions are mechanical. Category + formula + tables = description.

**Process:**

1. Categorize the method
2. Look up Qualifier Table (if applicable)
3. Apply Acronym Table
4. Apply formula

---

## Method Categories

### Decision Tree

```
1. Ends with `?`           → Predicate
2. Ends with `!`           → Mutator
3. Takes `&block`          → DSL/Builder
4. Starts with `find`      → Finder
5. Starts with `to_`       → Converter
6. Otherwise               → Getter
```

---

## Formulas by Category

| Category | Formula |
|----------|---------|
| Getter (Helper class) | "The [class] [method]." |
| Getter (Domain class) | "The [method] for this [class]." |
| Predicate (Helper class) | "Whether the [class] [predicate]." |
| Predicate (Domain class) | "Whether this [class] [predicate]." |
| Converter | "Converts this [class] to a [format]." |
| Mutator | "Marks this [class] as [state]." |
| Finder | "Finds [what] by [key]." |
| Finder (bang) | "Finds [what] by [key]." + `@raise` |
| DSL/Builder (single return) | "The [context] [method]." |
| DSL/Builder (collection) | "Defines a [method] for [context]." |
| DSL/Builder (with name param) | "Defines a [method] for [context]." |

---

## Class Categories

### Helper Classes

Use "the [class]" pattern.

| Class | Display Name |
|-------|--------------|
| Info | "API" |
| Contact | "contact" |
| License | "license" |
| Server | "server" |
| RootKey | "root key" |

### Domain Classes

Use "this [class]" pattern.

| Class | Display Name |
|-------|--------------|
| Action | "action" |
| API::Base | "API" |
| Adapter | "adapter" |
| Association | "association" |
| Attribute | "attribute" |
| Capability | "capability" |
| Contract | "contract" |
| Controller | "controller" |
| Enum | "enum" |
| ErrorCode | "error code" |
| Export | "export" |
| Inheritance | "inheritance" |
| Issue | "issue" |
| Operation | "operation" |
| Param::* | "param" |
| Representation | "representation" |
| Request | "request" |
| Resource | "resource" |
| Response | "response" |
| Serializer | "serializer" |
| Transformer | "transformer" |
| Type | "type" |
| Wrapper | "wrapper" |

**Class not in table?** Add it before writing YARD.

---

## Qualifier Table

Methods that need semantic context beyond the class name.

| Method | Qualifier |
|--------|-----------|
| status | HTTP |
| method | HTTP |

**Algorithm:**

1. Look up method in Qualifier Table
2. If found, prepend qualifier to method name
3. `status` → "HTTP status"
4. `method` → "HTTP method"

---

## Acronym Table

Always uppercase these terms.

```
ID, API, URL, URI, HTTP, UUID, JSON, XML, HTML, SQL, CRUD, REST, YAML
```

**Algorithm:**

1. After applying formula, scan for these words (case-insensitive)
2. Replace with uppercase version
3. `url` → "URL", `id` → "ID", `api` → "API"

---

## Complete Algorithm

```
1. Categorize method (Decision Tree)
2. Determine class category (Helper or Domain)
3. Look up Qualifier Table → prepend if found
4. Transform method name: underscores → spaces
5. Apply formula for category
6. Apply Acronym Table to result
```

### Example: ErrorCode#status

```
1. Category: Getter (no ?, !, &block, find, to_)
2. Class: ErrorCode → Domain → "this error code"
3. Qualifier: status → "HTTP status"
4. Transform: status → "status" (no underscores)
5. Formula: "The [method] for this [class]."
         → "The HTTP status for this error code."
6. Acronyms: HTTP already uppercase ✓
```

### Example: License#url

```
1. Category: Getter
2. Class: License → Helper → "license"
3. Qualifier: url → not in table
4. Transform: url → "url"
5. Formula: "The [class] [method]."
         → "The license url."
6. Acronyms: url → URL
         → "The license URL."
```

### Example: Attribute#terms_of_service

```
1. Category: Getter
2. Class: Attribute → Domain → "this attribute"
3. Qualifier: terms_of_service → not in table
4. Transform: terms_of_service → "terms of service"
5. Formula: "The [method] for this [class]."
         → "The terms of service for this attribute."
6. Acronyms: none
```

### Example: Info#title

```
1. Category: Getter
2. Class: Info → Helper → "API" (special display name)
3. Qualifier: title → not in table
4. Transform: title → "title"
5. Formula: "The [class] [method]."
         → "The API title."
6. Acronyms: API already uppercase ✓
```

---

## DSL/Builder Rules

Methods that take `&block`. Check return type:

| Return Type | Formula |
|-------------|---------|
| Single object `[T]` | "The [context] [method]." |
| Collection `[Array<T>]` | "Defines a [method] for [context]." |
| Has name/key param | "Defines a [method] for [context]." |

```ruby
# Returns single object
# @api public
# The API contact.
def contact(&block)

# Returns collection
# @api public
# Defines a server for the API.
#
# Can be called multiple times.
def server(&block)

# Has name parameter
# @api public
# Defines an action for this contract.
def action(name, &block)
```

---

## Predicate Rules

| Pattern | Description |
|---------|-------------|
| Type check (`string?`, `integer?`) | "Whether this [class] is a [type]." |
| State check (`deprecated?`, `abstract?`) | "Whether this [class] is [state]." |
| Capability check (`boundable?`, `filterable?`) | "Whether this [class] is [capability]." |

```ruby
# @api public
# Whether this param is a string.
def string?

# @api public
# Whether this contract is abstract.
def abstract?

# @api public
# Whether this param is boundable.
def boundable?
```

---

## Tag Order

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

```
@param name [Type] (default) [:values] description
@param name [Type] (default) [TargetType: :values] description
```

All parts after `[Type]` are optional.

| Part | Format |
|------|--------|
| Type | `[Symbol]`, `[String, nil]`, `[Array<String>]` |
| Default | `(nil)`, `(false)`, `(:optional)` |
| Values | `[:json, :xml]` or `[Symbol: :json, :xml]` |
| Description | freeform text |

### Default Value Rules

| Code | YARD |
|------|------|
| `def foo(bar)` | `@param bar [String]` |
| `def foo(bar = nil)` | `@param bar [String, nil] (nil)` |
| `def foo(bar = :json)` | `@param bar [Symbol] (:json)` |
| `def foo(bar = false)` | `@param bar [Boolean] (false)` |
| `def foo(bar: nil)` | `@param bar [String, nil] (nil)` |
| `def foo(bar: :optional)` | `@param bar [Symbol] (:optional)` |

**Always show the default value explicitly, including `(nil)`.**

### Values Syntax

Values constrain a type to specific allowed values.

**Simple (replaces Symbol by default):**
```ruby
@param format [Symbol] [:json, :xml]
```

**Explicit target type (when multiple types):**
```ruby
@param input [String, Symbol] [Symbol: :json, :xml]
```

The target type must match one of the declared types in `[Type]`.

### Rendered Table

Values appear in the Type column as `Type<values>`:

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `format` | `Symbol<:json, :xml>` | `:json` | output format |
| `format` | `Symbol<:json, :xml>`, `nil` | `:json` | |
| `input` | `String`, `Symbol<:json, :xml>` | | format or string |
| `value` | `String`, `nil` | `nil` | |
| `name` | `Symbol` | | |

**Table always shows 4 columns:** Name, Type, Default, Description

---

## @param Descriptions

**Every parameter gets a description. No exceptions.**

### Structure

Description always on a separate line:

```ruby
# @param name [Type] (default) [values]
#   Description sentence.
```

- **Line 1:** Name, type, default, values (metadata)
- **Line 2+:** Description (semantik)

### Examples

```ruby
# @param name [Symbol]
#   The attribute name.

# @param filterable [Boolean] (false)
#   Whether the attribute is filterable.

# @param nullable [Boolean, nil] (nil)
#   Whether the value can be null. If nil, auto-detected from column NULL constraint.

# @param type [Symbol, nil] (nil) [:string, :integer, :boolean, :datetime, :date, :uuid, :decimal, :number, :object, :array]
#   The type. If nil and name maps to a database column, auto-detected from column type.

# @param include [Symbol] (:optional) [:always, :optional]
#   The inclusion strategy.
```

### Patterns

| Category | Pattern | Example |
|----------|---------|---------|
| Boolean flag | "Whether the [element] is [adjective]." | "Whether the attribute is filterable." |
| Boolean (auto-detect) | "Whether [subject]. If nil, auto-detected from [source]." | "Whether the value can be null. If nil, auto-detected from column NULL constraint." |
| Value | "The [thing]." | "The description." |
| Value (auto-detect) | "The [thing]. If nil, auto-detected from [source]." | "The type. If nil and name maps to a database column, auto-detected from column type." |
| Value (conditional) | "The [thing]. If nil and [condition], auto-detected from [source]." | "The type. If nil and name maps to a database column, auto-detected from column type." |
| Function | "Transform for [purpose]." | "Transform for serialization." |

### Rules

- Capital letter at start of description
- Period at end of description
- Use "auto-detected" not "automatically detected"
- Use "If nil" not "When nil"
- Present tense only
- Omit redundant context: "The type." not "The type of the attribute."

### Verification

**Before writing any parameter description, verify its actual behavior in the code.**

1. Read the implementation
2. Check for auto-detection logic, validation, and special cases
3. Document what the code actually does

---

## @return Format

Type only. No description.

```ruby
@return [void]
@return [String]
@return [Symbol, nil]
@return [Boolean]
@return [Class<Adapter::Base>]
```

---

## @yield / @yieldparam

| Signal in code | Use |
|----------------|-----|
| `yield(object)` or `block.call(object)` | `@yieldparam` only |
| `instance_eval(&block)` | `@yield` only |
| Checks arity, supports both | Both `@yield` and `@yieldparam` |

---

## @example Rules

- Required for: `&block` methods, mutators
- Code must be runnable
- Output shown with `# =>`
- Use domain terms: invoice, customer, item
- Never: foo, bar, baz, test, example

---

## Audit Checklist

For each `@api public` method:

1. [ ] Has description
2. [ ] Correct category applied
3. [ ] Qualifier Table checked
4. [ ] Acronyms uppercase
5. [ ] @param matches signature (see below)
6. [ ] @return type only (no description)
7. [ ] @example for &block/mutator methods
8. [ ] Tag order correct

---

## @param Signature Verification

**Every @param must match the method signature exactly.**

### Algorithm

For each parameter in the method signature:

1. **Required positional** (`name`) → `@param name [Type]` (no default)
2. **Optional positional** (`name = value`) → `@param name [Type] (value)`
3. **Required keyword** (`name:`) → `@param name [Type]` (no default)
4. **Optional keyword** (`name: value`) → `@param name [Type] (value)`

### Examples

```ruby
# Signature
def foo(required, optional = nil, keyword:, keyword_opt: false)

# YARD
# @param required [String]
# @param optional [String, nil] (nil)
# @param keyword [Symbol]
# @param keyword_opt [Boolean] (false)
```

### Common Mistakes

| Signature | Wrong | Correct |
|-----------|-------|---------|
| `name = nil` | `@param name [String, nil]` | `@param name [String, nil] (nil)` |
| `name = false` | `@param name [Boolean]` | `@param name [Boolean] (false)` |
| `name:` (required) | `@param name [Symbol] (nil)` | `@param name [Symbol]` |

### Verification Command

```bash
# Find @param with nil type but missing (nil) default
grep -rn '@param.*\[.*nil\]' lib/apiwork/ --include="*.rb" | grep -v '(nil)'
```

---

## Verification

```bash
cd docs/playground && bundle exec rake apiwork:docs:reference
```

Review generated documentation for consistency.
