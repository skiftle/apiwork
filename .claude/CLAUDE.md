# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

```bash
# Run all tests
bundle exec rspec

# Run a single test file
bundle exec rspec spec/integration/filtering_spec.rb

# Run a specific test by line number
bundle exec rspec spec/integration/filtering_spec.rb:42

# Lint and auto-fix
bundle exec rubocop -A

# Run tests and lint (CI default)
bundle exec rake

# Generate reference docs from YARD comments
bundle exec rake apiwork:docs:reference

# Generate documentation examples (from docs/playground)
cd docs/playground && RAILS_ENV=test rake docs:generate

# Export API specs
bundle exec rake apiwork:export:write OUTPUT=public/exports
```

## Architecture

Apiwork is a contract-driven API framework for Rails. Core components:

- **API** (`lib/apiwork/api/`) - Defines resources, mount points, and configuration. `API::Base` is the DSL entry point. APIs register themselves globally via `API::Registry`.

- **Contract** (`lib/apiwork/contract/`) - Defines request/response shapes with typed parameters. `Contract::Base` provides the DSL. Contracts declare actions (`index`, `show`, `create`, etc.) with request body params and response schemas.

- **Schema** (`lib/apiwork/schema/`) - Connects contracts to ActiveRecord models. `Schema::Base` defines attributes and associations that map to database columns. Schemas infer types from the database and drive serialization.

- **Adapter** (`lib/apiwork/adapter/`) - Runtime execution layer. Translates contracts into database queries. `Adapter::Standard` handles filtering, sorting, pagination, and includes based on what contracts allow.

- **Export** (`lib/apiwork/export/`) - Generates output from API definitions. Built-in exports: OpenAPI (`open_api.rb`), TypeScript (`type_script.rb`), Zod (`zod.rb`). Each mapper transforms introspection data to the target format.

- **Introspection** (`lib/apiwork/introspection/`) - Internal representation of API structure. Param types, schemas, and contracts are serialized to a format that exports consume.

- **Controller** (`lib/apiwork/controller.rb`) - Rails integration. Handles request parsing, validation, execution via adapter, and response serialization.

### Request Flow

1. Router (`API::Router`) matches request to contract action
2. Controller parses request using `Contract::RequestParser`
3. Adapter executes the action (query, filter, paginate)
4. Controller serializes response using schema definitions
5. Contract validates response structure

### Test Structure

- `spec/lib/` - Unit tests for individual classes
- `spec/integration/` - Full-stack tests using `spec/dummy/` Rails app
- `spec/dummy/` - Minimal Rails app with test APIs, models, schemas, and contracts

### Documentation Structure

- `docs/` - VitePress documentation site
- `docs/playground/` - Rails app for documentation examples
- `docs/playground/public/` - Generated output (introspection.json, typescript.ts, zod.ts, openapi.yml)

Run `rake docs:generate` from `docs/playground/` after any change affecting output formats.

---

# Ruby & Rails Style Guide

Follow these rules in this project.

---

## Simplification

- One way to do it, not three. Consolidate similar classes into one with parameters.
- If the only difference is configuration, use parameters — not separate classes.
- Don't create multiple storage levels when one will do.

```ruby
# ❌ Bad
class GlobalTypeRegistrar
  def register(name, &block) ...
end
class ScopedTypeRegistrar
  def register(name, scope, &block) ...
end

# ✅ Good
class TypeRegistrar
  def register(name, scope: nil, &block)
  end
end
```

---

## Composition

- Prefer class instances over modules (modules create hidden coupling)
- Exception: `ActiveSupport::Concern` for DSLs
- One class per file — no inline nested classes
- Extract for concepts, not lines — three similar lines beats a premature abstraction
- Never create: `helpers/`, `utils/`, `misc/`

**Extract private methods only when:**

1. Reused in 2+ places
2. Complex enough (5+ lines) that a name helps

```ruby
# ❌ Bad — module inclusion, inline class
class Api::Base
  include Recorder
  class Result; end
end

# ✅ Good — composition, separate files
class Api::Base
  def initialize
    @recorder = Recorder.new(@metadata)
  end
end
# lib/api/result.rb
class Api::Result; end
```

---

## Principles

- Readability over cleverness — no unnecessary meta-programming
- Explicit over implicit — no magic or monkey patching
- Small, focused objects with one responsibility
- Rails-ness matters — declarative, expressive, conventional
- Clean up as you go — remove dead code, breaking changes are fine (pre-release)
- No comments — code speaks for itself (allowed: magic comments, RuboCop directives, TODOs)
- Guard clauses over deep nesting, one guard per line
- Positive conditions — avoid `unless` with compound logic, `!`, `== false`
- Full names — `attribute` not `attr` (exception: `param`, `attr_reader`)
- Don't repeat namespace context: `CaseTransformer.hash`, not `transform_keys`
- Use `ActiveSupport::Concern` over `self.included(base)` + `base.extend(ClassMethods)`
- Use stable identifiers for registry keys (not class references that become stale on reload)

```ruby
# ❌ Bad — combined guards
return if abstract? || @model_class.nil? || @schema_class

# ✅ Good — one per line
return if abstract?
return if @model_class.nil?
return if @schema_class
```

**Exception:** Logically connected conditions can stay together or extract to predicate:

```ruby
return unless @record.respond_to?(:errors) && @record.errors.any?
```

---

## Class References

Use class constants, not strings.

```ruby
# ✅ Good
has_one :profile, class_name: ProfileResource
resource UserResource

# ❌ Bad
has_one :profile, class_name: 'ProfileResource'
```

Exception: `config/routes.rb` and files that run before autoloading.

---

## Option Naming

Don't repeat context. In a Resource class, use `class_name:` not `resource_class_name:`.

```ruby
# ✅ In Resource class
has_one :author, class_name: UserResource

# ✅ Outside context
def initialize(resource_class_name:)
```

---

## Naming

- Names describe what something IS: `invoice_total` not `total`
- Natural word order (adjective-noun): `paginated_invoices` not `invoices_paginated`
- No type suffixes (`_str`, `_sym`): describe purpose, not type
- Class references use `_class` suffix: `api_class` not `api` (instances use short names)
- Positive predicates: `list.exclude?(key)` not `!list.include?(key)`
- Nouns for getters, verbs for actions: `Registry.types(api)`, `TypeStore.serialize(api)`

```ruby
# ❌ Bad
def initialize(api)  # Is this a class or instance?
  @total = invoice.total  # What total?
end

# ✅ Good
def initialize(api_class)
  @invoice_total = invoice.total
end
```

**Cross-module naming:** When classes share names across modules (e.g., `Introspection::Contract` and `Contract::Action`):

- Inside module: local class is `contract`, external is `contract_action` (module-prefixed)
- Outside both modules: prefix both with module name

```ruby
# Inside Introspection module
contract = Introspection::Contract.new
contract_action = Contract::Action.new

# Outside both modules
introspection_contract = Introspection::Contract.new
contract_action = Contract::Action.new
```

---

## No Multi-line Block Chains

```ruby
# ❌ Bad
collection
  .map do |item|
    process(item)
  end
  .select do |item|
    valid?(item)
  end

# ✅ Good
processed = collection.map { |item| process(item) }
validated = processed.select { |item| valid?(item) }
```

---

## Method Arguments

- **Positional:** Required and unambiguous — `User.find(id)`
- **Keyword:** Optional or unclear meaning — `resize(width: 800, height: 600)`
- **Never** optional positional (`arg = nil`) — use keywords instead
- **Order:** positional → keyword → splat
- **4+ keywords:** Multi-line, one per line, defaults in signature

```ruby
def initialize(name, type, schema_class,
               schema: nil,
               include: :optional,
               filterable: false)
  @name = name
end
```

---

## Ruby/Rails Idioms

**Use:**

- `map(&:to_s)`, `select(&:present?)`, `compact_blank`
- `index_by`, `each_with_object({})`, `group_by`
- `delegate`, `attr_reader` + memoization (`@x ||= ...`)
- `tap` for side effects in chains
- `present?`, `blank?`, `presence`
- Freeze constants: `FOO = {...}.freeze`
- Hash shorthands OK: `{ title, value }`
- Explicit keyword args: `scope: scope`, not `scope:`
- Predicate methods: `amount.positive?`, `collection.any?`, `value.zero?`

**Avoid:**

- `then` — use intermediate variables instead
- Numbered parameters (`_1`, `_2`) — use named block arguments
- `module_function` — use class methods or a class instead

---

## Zeitwerk

Never `require` application code. Just use the class.

```ruby
# ❌ Bad
require 'app/models/user'

# ✅ Good
User.find(1)
```

Use `require` for: gems, stdlib, files outside autoload paths.

---

## YARD

Only document public API methods. A method is public if it has `@api public`.

**YARD comments are documentation.** Follow `DOCS.md` strictly:

- Same tone — direct, technical, pedagogical
- No filler words, no AI patterns, no marketing
- Add `@example` when it helps understanding
- Use `@see` to reference related methods or classes

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
  # ...
end
```

Methods without `@api public` are internal — no YARD comments needed.

---

## Documentation

Keep docs in sync with code. See `.claude/DOCS.md` for detailed guidelines.

Key rules:

- Verify against actual code — never invent behavior
- Run `rake docs:generate` from `docs/playground/` after changes affecting output formats
- Code and docs change together in the same commit

---

## Quick Reference

| Category   | ❌ Bad                                                       | ✅ Good                         |
| ---------- | ------------------------------------------------------------ | ------------------------------- |
| Conditions | `if !user.active?`                                           | `unless user.active?`           |
|            | `if order.total > 0`                                         | `if order.total.positive?`      |
|            | `if !items.empty?`                                           | `if items.any?`                 |
|            | `if user.admin? == false`                                    | `unless user.admin?`            |
|            | `return if a \|\| b \|\| c`                                  | `return if a` (one per line)    |
| Guards     | `do_thing if @x` + `return unless @x` in method              | Put guard inside method only    |
| Naming     | `total = invoice.total`                                      | `invoice_total = invoice.total` |
|            | `invoices_paginated`                                         | `paginated_invoices`            |
|            | `key_string = key.to_s`                                      | `key = key.to_s`                |
|            | `def initialize(api)` (class ref)                            | `def initialize(api_class)`     |
|            | `!list.include?(key)`                                        | `list.exclude?(key)`            |
| Classes    | `class_name: 'ProfileResource'`                              | `class_name: ProfileResource`   |
|            | `include Recorder`                                           | `@recorder = Recorder.new(...)` |
|            | Inline nested classes                                        | One class per file              |
| Methods    | `arg = nil` (optional positional)                            | `arg: nil` (keyword)            |
|            | `options = defaults.merge(opts)`                             | Defaults in signature           |
|            | Multi-line block chains                                      | Break into variables            |
| Code       | `require 'app/models/user'`                                  | Just use `User` (Zeitwerk)      |
|            | Comments explaining code                                     | Well-named methods              |
|            | `helpers/`, `utils/` folders                                 | Concept-based classes           |
| Style      | Run `bundle exec rubocop -A` on every file you modify        |
| Testing    | Run tests after every change, integration tests are priority |
