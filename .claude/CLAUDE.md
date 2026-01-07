# CLAUDE.md

Rules for working with code in this repository.

## Commands

```bash
bundle exec rspec                                    # all tests
bundle exec rspec spec/integration/filtering_spec.rb # single file
bundle exec rspec spec/integration/filtering_spec.rb:42  # single test
bundle exec rubocop -A                               # lint + auto-fix
bundle exec rake                                     # tests + lint (CI)
bundle exec rake apiwork:docs:reference              # generate YARD docs
cd docs/playground && RAILS_ENV=test rake docs:generate  # generate examples
```

## Architecture

```
lib/apiwork/
├── api/          # API definitions, resources, router
├── contract/     # Request/response shapes, typed params, validation
├── schema/       # ActiveRecord mapping, attributes, associations
├── adapter/      # Runtime: filtering, sorting, pagination, includes
├── export/       # OpenAPI, TypeScript, Zod generators
├── introspection/# Internal API structure representation
└── controller.rb # Rails integration, request/response handling

spec/
├── lib/          # Unit tests
├── integration/  # Full-stack tests
└── dummy/        # Test Rails app

docs/
├── playground/   # Example Rails app
└── playground/public/  # Generated output
```

**Request flow:** Router → Controller → Adapter → Serialization → Response

---

## Philosophy

- Readability over cleverness
- One way to do it — consolidate similar classes with parameters
- Classic Ruby elegance — no meta-programming without reason
- Rails-ness matters — declarative, expressive, conventional
- Clean up as you go — remove dead code
- Breaking changes are fine — this is pre-release

---

## Rules

### Do

| Rule                             | Example                                       |
| -------------------------------- | --------------------------------------------- |
| Public API: simple names         | `Contract` not `ContractDefinition`           |
| Internal: descriptive names      | `ContractDefinition`, `ParamValidator`        |
| One class per file               | `lib/api/result.rb` for `Api::Result`         |
| Composition over modules         | `@recorder = Recorder.new(...)`               |
| Class constants, not strings     | `class_name: ProfileResource`                 |
| `_class` suffix for class refs   | `def initialize(api_class)`                   |
| Descriptive names with context   | `invoice_total` not `total`                   |
| Adjective-noun order             | `paginated_invoices` not `invoices_paginated` |
| One guard per line               | `return if x` then `return if y`              |
| Keyword args for optional        | `def foo(bar: nil)`                           |
| Defaults in signature            | Not `options = defaults.merge(opts)`          |
| Explicit keyword args            | `scope: scope` not `scope:`                   |
| Don't repeat context in options  | `class_name:` not `resource_class_name:`      |
| Named block arguments            | `{ \|item\| process(item) }`                  |
| Intermediate variables           | Instead of `.then` or block chains            |
| `@api public` for public methods | YARD only for public API                      |
| `@example` in YARD               | When it helps understanding                   |
| `@see` in YARD                   | Reference related methods                     |

### Avoid

| Never                           | Instead                             |
| ------------------------------- | ----------------------------------- |
| `then`                          | Intermediate variables              |
| `_1`, `_2` (numbered params)    | Named block arguments               |
| `module_function`               | Class methods or a class            |
| `include Module`                | Composition: `@x = Module.new(...)` |
| Inline nested classes           | Separate files                      |
| `helpers/`, `utils/`, `misc/`   | Concept-based classes               |
| Optional positional `arg = nil` | Keyword `arg: nil` (exception: DSL setters) |
| `require 'app/...'`             | Just use the class (Zeitwerk)       |
| Comments (except magic/directives/TODO) | Well-named methods          |
| Type suffixes `_str`, `_sym`    | Describe purpose                    |
| `!list.include?(x)`             | `list.exclude?(x)`                  |
| `if !x`                         | `unless x`                          |
| `== false`                      | `unless`                            |
| `unless` with compound logic    | Positive conditions                 |
| Multi-line block chains         | Break into variables                |
| Arrow characters                | "becomes", "then"                   |

### No Comments

Extract logic to well-named predicates instead of commenting.

```ruby
# ❌ Bad
if user.subscription_tier == 'premium' && user.api_calls_this_month < 10_000

# ✅ Good
if user.can_make_api_call?
```

Allowed: YARD for `@api public` methods, magic comments, RuboCop directives, temporary TODOs.

### When to Extract Private Methods

A private method is justified by:
1. **Reuse** — used in 2+ places
2. **Complexity** — 5+ lines of non-trivial logic

Not justified by: "It's cleaner", "Methods should be short", "Can be reused later"

### Conditions

```ruby
# ❌ Bad
return if abstract? || @model_class.nil? || @schema_class
if !user.active?
if order.total > 0

# ✅ Good
return if abstract?
return if @model_class.nil?
return if @schema_class
unless user.active?
if order.total.positive?
```

### Guard Logic

Guards belong inside the method, not at the call site:

```ruby
# ❌ Bad
validate_association! if @model_class

# ✅ Good
validate_association!

def validate_association!
  return unless @model_class
  # ...
end
```

Exception: external context conditions stay at call site:
```ruby
send_notification if user.opted_in?
```

### Cross-module naming

When classes share names (e.g., `Introspection::Contract` vs `Contract::Action`):

```ruby
# Inside Introspection module
contract = Introspection::Contract.new      # local = short name
contract_action = Contract::Action.new      # external = prefixed

# Outside both modules — prefix both
introspection_contract = Introspection::Contract.new
contract_action = Contract::Action.new
```

### Method signatures

```ruby
# 4+ keywords: multi-line, defaults in signature
def initialize(name, type, schema_class,
               schema: nil,
               include: :optional,
               filterable: false)
  @name = name
end
```

### YARD

Only for `@api public` methods. Follow DOCS.md tone.

```ruby
# Finds a record by ID.
#
# @api public
# @param id [Integer] the record ID
# @return [Record, nil]
# @see #find_all
#
# @example
#   contract.find(123)
#   # => #<Record id: 123>
def find(id)
end
```

No `@api public` = internal = no YARD comments.

---

## Idioms

**Use:** `map(&:to_s)`, `select(&:present?)`, `compact_blank`, `index_by`, `each_with_object({})`, `group_by`, `delegate`, `@x ||= ...`, `tap`, `present?`, `blank?`, `presence`, `FOO = {...}.freeze`, `{ title, value }`, `amount.positive?`, `collection.any?`

---

## Testing

1. `bundle exec rubocop -A`
2. `bundle exec rspec`

- Run tests after every code change
- New functionality requires new tests
- Integration tests are priority
- Update tests when code changes

Documentation: see `.claude/DOCS.md`.
