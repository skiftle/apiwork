# REVIEW.md

Code review checklist. **Go through EVERY section in order.** Do not skip.

---

## 1. Class Layout

Check order from top to bottom:

- [ ] Constants first (`CONSTANT = ...`, `class_attribute`)
- [ ] All `attr_*` grouped together (not scattered)
- [ ] `class << self` before `initialize`
- [ ] Inside `class << self`: `attr_*` first
- [ ] `initialize` after `class << self`
- [ ] Public instance methods after `initialize`
- [ ] `private` keyword last
- [ ] Private methods after `private`

## 2. Ordering Within Sections

In EVERY section, `@api public` comes first:

- [ ] `attr_*`: @api public attr_reader before semi-public
- [ ] `class << self` methods: @api public before semi-public
- [ ] Instance methods: @api public before semi-public

## 3. Naming

### Variables and methods
- [ ] No `is_` prefix for booleans (use `?` suffix for methods)
- [ ] `_class` suffix for class references (`schema_class` not `schema`)
- [ ] No abbreviations (`association_definition` not `assoc_def`)
- [ ] No generic names (`data`, `item`, `thing`, `foo`)
- [ ] No type suffixes (`_str`, `_sym`)
- [ ] Adjective-noun order (`paginated_invoices` not `invoices_paginated`)

### Parameters
- [ ] Parameter name = instance variable name when directly assigned
- [ ] Full words (`attribute` not `attr`, exception: `param`)

### Context
- [ ] Outside class: prefix with context (`invoice_total` not `total`)
- [ ] Inside class: no context repetition (`total` not `invoice_total`)

## 4. Method Signatures

- [ ] Keyword args for all optionals (`def foo(bar: nil)`)
- [ ] No positional optionals (`def foo(bar = nil)`) except DSL setters
- [ ] Defaults in signature, not computed in body
- [ ] Explicit keyword names (`scope: scope` not `scope:`)
- [ ] Order: positional, then keyword, then splat
- [ ] Multiline at 4+ keywords

## 5. Conditions and Guards

- [ ] One guard per line (no `return if x || y`)
- [ ] No `if !x` (use `unless x`)
- [ ] No `== false` (use `unless`)
- [ ] No `unless` with compound logic (`&&`, `||`)
- [ ] Use Ruby idioms: `positive?`, `blank?`, `present?`, `exclude?`
- [ ] Guards inside method, not at call site

## 6. Defensive Code

- [ ] No `&.` on values that should exist
- [ ] No `|| default` on values that should exist
- [ ] No `respond_to?` checks (method should always exist)
- [ ] No `(@items ||= {})` defensive init (init in constructor)
- [ ] Defaults in signature, not `value || default` in body

### Exception: Detection logic
When `nil` means "not provided" vs explicit `false`:
```ruby
optional = detect_optional if optional.nil?
optional = false if optional.nil?  # OK after detection
```

## 7. Comments and Documentation

- [ ] No comments in code (exception: magic comments, RuboCop directives)
- [ ] YARD only on `@api public` methods
- [ ] No YARD on semi-public methods
- [ ] No YARD on private methods

## 8. Visibility

- [ ] No `protected` (forbidden)
- [ ] No `instance_variable_get/set` in lib/
- [ ] No underscore prefix as pseudo-private (exception: `class_attribute`)
- [ ] `attr_*` for public/semi-public, `@variable` for private state

## 9. Block Parameters

- [ ] No `|_, var|` pattern (use `.values`, `.keys`, etc.)
- [ ] No numbered params `_1`, `_2` (use named: `|item|`)
- [ ] Always name block parameters

## 10. Ruby Style

- [ ] No `then`
- [ ] No `inject`/`reduce` (use `each_with_object`)
- [ ] No long method chains across lines (use intermediate variables)
- [ ] Intermediate variables only for complex expressions (3+ calls)
- [ ] No variables for simple method calls used 1-2 times

## 11. Structure

- [ ] One class per file
- [ ] No inline nested classes
- [ ] No `helpers/`, `utils/`, `misc/` directories
- [ ] Composition over `include Module`
- [ ] Class constants, not strings (`class_name: ProfileResource`)

## 12. Service Objects

- [ ] Entry point is `.call` or `#call` only
- [ ] No `.run`, `.execute`, `.perform`, `.process`

## 13. Strings and Symbols

- [ ] No arrow characters (`→`, `↔`) — use "becomes", "then"
- [ ] No `require` for app code (Zeitwerk handles it)

---

# Quick Reference

## Class Layout Template

```ruby
class Example
  CONSTANT = 'value'.freeze

  class_attribute :config

  # @api public
  attr_reader :name

  attr_reader :internal_cache  # semi-public

  class << self
    attr_writer :api_class  # attr_* first in class << self

    # @api public
    def build(...)
    end

    def internal_method  # semi-public after @api public
    end
  end

  def initialize(...)
  end

  # @api public
  def public_method
  end

  def semi_public_method  # after @api public
  end

  private

  def private_method
  end
end
```

## Naming Examples

```ruby
# Bad → Good
@is_active → @active
def is_valid? → def valid?
@schema → @schema_class
assoc_def → association_definition
def initialize(schema_class) + @owner = schema_class → def initialize(owner_schema_class) + @owner_schema_class = owner_schema_class
```

## Guard Examples

```ruby
# Bad
return if abstract? || @model_class.nil?
if !user.active?

# Good
return if abstract?
return if @model_class.nil?
unless user.active?
```

## Defensive Code Examples

```ruby
# Bad
value&.method
value || default
@items ||= {}

# Good
value.method  # trust your invariants
# default in signature
@items = {}  # in initialize
```
