# REVIEW.md

Code review checklist. **Go through EVERY point in order.** Do not skip.

---

## Checklist (run for each file)

### 1. Class Layout - correct order?
- [ ] Constants first
- [ ] `attr_*` declarations grouped (ALL together, not scattered)
- [ ] `class << self` before `initialize`
- [ ] `initialize` after `class << self`
- [ ] Public instance methods after `initialize`
- [ ] `private` last

### 2. Within each section - @api public first?
- [ ] In `attr_*`: @api public attr_reader before semi-public
- [ ] In `class << self`: attr_* first, then @api public methods, then semi-public
- [ ] In instance methods: @api public before semi-public

### 3. Naming
- [ ] No `is_` prefix (use `?` suffix)
- [ ] `_class` suffix for class references
- [ ] Parameter = instance variable (same name)
- [ ] No abbreviations

### 4. Defensive code
- [ ] No `&.` on values that should exist
- [ ] No `|| default` on values that should exist
- [ ] No `respond_to?` checks
- [ ] Defaults in signature, not in method body

### 5. Other
- [ ] No comments (except YARD on @api public)
- [ ] No `|_, var|` - restructure instead
- [ ] No arrow symbols (`→`, `↔`)
- [ ] One guard per line

---

## Naming

### Boolean methods and variables

- **Methods:** Use `?` suffix, not `is_` prefix
- **Instance variables:** Nouns without prefix

```ruby
# Bad - Java-style
@is_active
def is_valid?

# Good - Ruby-style
@active
def valid?
```

### Class references

- Variables holding class references need `_class` suffix

```ruby
# Bad
@schema
@contract

# Good
@schema_class
@contract_class
```

### Parameter to instance variable

- If a parameter is assigned directly to an instance variable, use the same name

```ruby
# Bad - inconsistent
def initialize(schema_class)
  @owner_schema_class = schema_class
end

# Good - consistent
def initialize(owner_schema_class)
  @owner_schema_class = owner_schema_class
end
```

### No abbreviations

- Write out full words

```ruby
# Bad
assoc_def
attr_def
param_val

# Good
association_definition
attribute_definition
parameter_value
```

---

## Block parameters

### Avoid underscore for unused parameters

- Restructure to avoid the need

```ruby
# Bad
hash.any? { |_, value| value.active? }

# Good
hash.values.any?(&:active?)
```

### Always name block parameters

```ruby
# Bad
items.map { |_1| _1.name }

# Good
items.map { |item| item.name }
```

---

## Intermediate Variables

### Create only when it adds clarity

- Complex expressions that need a name
- Chains with 3+ method calls

### Don't create for

- Simple method calls used 1-2 times
- Expressions already clear from context

```ruby
# Bad - unnecessary variable
schema_class = definition.schema_class
serialize(schema_class)

# Good - direct usage
serialize(definition.schema_class)

# Good - justified variable (complex expression)
filtered_active_users = users.select(&:active?).reject(&:banned?).sort_by(&:name)
```

---

## Documentation

### Visibility levels

| Level | YARD | Comments |
|-------|------|----------|
| `@api public` | Yes | Yes |
| Semi-public | No | No |
| Private | No | No |

### Semi-public methods

- Methods needed internally between classes but not part of public API
- Use `attr_writer` or `attr_accessor` instead of `attr_reader` + manual setter
- **No documentation whatsoever**

```ruby
# Bad - semi-public with documentation
# Sets the visited types for cycle detection.
attr_writer :visited_types

# Good - semi-public without documentation
attr_writer :visited_types
```

---

## Class Layout

Order within a class:

1. Constants (`ALLOWED_FORMATS = ...`)
2. `class_attribute` / `attr_*` declarations
3. `class << self` block (if present)
4. `initialize`
5. Public instance methods
6. `private`
7. Private methods

```ruby
class Example
  CONSTANT = 'value'.freeze

  attr_reader :name, :type
  attr_writer :internal_state

  class << self
    def build(...)
    end
  end

  def initialize(name)
    @name = name
  end

  def process
  end

  private

  def validate!
  end
end
```

---

## Defensive Code

### Avoid

| Pattern | Problem |
|---------|---------|
| `value&.method` | Hides nil where nil shouldn't be |
| `value \|\| default` | Hides unexpected nil |
| `respond_to?(:method)` | Method should always exist |
| `x == false` | Use `unless x` |

### Defaults in signature

```ruby
# Bad - defensive default
def initialize(active: nil)
  @active = active || false
end

# Good - default in signature
def initialize(active: false)
  @active = active
end
```

### Exception: Detection logic

When `nil` means "not provided" and needs to be distinguished from `false`:

```ruby
def initialize(optional: nil)
  optional = detect_optional if optional.nil?
  optional = false if optional.nil?  # Fallback after detection
  @optional = optional
end
```

---

## Guards

### One guard per line

```ruby
# Bad
return if abstract? || @model_class.nil?

# Good
return if abstract?
return if @model_class.nil?
```

### Positive logic

```ruby
# Bad
if !user.active?
unless user.active? && user.verified?

# Good
unless user.active?
if user.inactive? || user.unverified?
```
