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
| Optional positional `arg = nil` | Keyword `arg: nil`                  |
| `require 'app/...'`             | Just use the class (Zeitwerk)       |
| Comments explaining code        | Well-named methods                  |
| Type suffixes `_str`, `_sym`    | Describe purpose                    |
| `!list.include?(x)`             | `list.exclude?(x)`                  |
| `if !x`                         | `unless x`                          |
| `== false`                      | `unless`                            |
| `unless` with compound logic    | Positive conditions                 |
| Multi-line block chains         | Break into variables                |
| Arrow characters                | "becomes", "then"                   |

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

## After every change

1. `bundle exec rubocop -A`
2. `bundle exec rspec`

Integration tests are priority. Documentation: see `.claude/DOCS.md`.
