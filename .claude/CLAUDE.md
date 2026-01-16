# CLAUDE.md

Rules for working with code in this repository.

This document is the **single source of truth** for style, structure, tests, and documentation.
There is exactly **one** CLAUDE.md. No secondary files.

---

## Commands

```bash
bundle exec rspec                                    # all tests
bundle exec rspec spec/integration/filtering_spec.rb # single file
bundle exec rspec spec/integration/filtering_spec.rb:42  # single test
bundle exec rubocop -A                               # lint + auto-fix
bundle exec rake                                     # tests + lint (CI)
cd docs/playground && bundle exec rake apiwork:docs:reference  # generate YARD reference
cd docs/playground && RAILS_ENV=test rake docs:generate  # generate examples
```

---

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
├── apiwork/      # Unit tests (mirrors lib/apiwork/)
├── integration/  # Full-stack tests
└── dummy/        # Test Rails app

docs/
├── playground/   # Example Rails app
└── playground/public/  # Generated output
```

**Request flow:** Router → Controller → Adapter → Serialization → Response

---

## Core Principle

**Consistency beats local optimization. Always.**

If there are two reasonable ways to do something, one is forbidden.
If something looks cleaner in isolation but introduces variation, it is not allowed.

---

## Philosophy

| Do                                                               | Don't                                              |
| ---------------------------------------------------------------- | -------------------------------------------------- |
| Write code that is read more often than written                  | Show off cleverness                                |
| Optimize for understanding, not brevity                          | Build for "future reuse"                           |
| Let structure and names carry meaning                            | Create abstractions before the pressure exists     |
| Consolidate similar things rather than creating variants         | Leave ambiguity in public APIs                     |
| Think in surfaces (API, contracts, behavior), not implementation | Use meta-programming without extreme justification |
| Be Rails-native — declarative, expressive, conventional          |                                                    |
| Clean up as you go — remove dead code                            |                                                    |
| Small, focused objects with one responsibility                   |                                                    |
| Explicit over implicit — no magic, monkey patching, or defensive guesswork |                                           |
| Use stable identifiers for registry keys (not class references)  |                                                    |

**Breaking changes are acceptable. Inconsistency is not.**

### Consolidation Example

```ruby
# Bad — two classes with minor differences
class GlobalTypeRegistrar
  def register(name, &block) ... end
end
class ScopedTypeRegistrar
  def register(name, scope, &block) ... end
end

# Good — one class with parameters
class TypeRegistrar
  def register(name, scope: nil, &block)
  end
end
```

---

## Quality Bar

Before code is considered done:

1. Can I understand this in 6 months?
2. Is there exactly one way to use this?
3. Is this Rails-idiomatic?
4. Could this be simpler without introducing variation?

If the answer is "yes, but…" — rewrite.

---

# Code Style

## Naming

| Do                                                                     | Don't                                                    |
| ---------------------------------------------------------------------- | -------------------------------------------------------- |
| Use descriptive, context-bearing names outside their context           | Abbreviations: `cfg`, `opts`, `ctx`                      |
| Use unabbreviated words: `schema_class` not `cls`                      | Generic words: `data`, `item`, `thing`, `foo`            |
| `options` is acceptable for hash of optional parameters                |                                                          |
| Follow adjective-noun order: `paginated_invoices`                      | Type suffixes: `_str`, `_sym`                            |
| Names should eliminate the need for comments                           | Repeat context: `class_name:` not `resource_class_name:` |
| Public API: simple names (`Contract` not `ContractDefinition`)         |                                                          |
| Internal: descriptive names (`ContractDefinition`, `ParamValidator`)   |                                                          |
| Use `_class` suffix for class references: `def initialize(api_class)`  |                                                          |
| Full names: `attribute` not `attr` (exception: `param`, `attr_reader`) |                                                          |
| Method names: nouns for getters, verbs for actions                     |                                                          |
| For single-use conversions, inline it                                  |                                                          |

### Variable Names Match Class Names

Variables should be named after their class:

```ruby
# Good — variable name matches class
attribute = schema_class.attributes[key]      # Attribute
association = schema_class.associations[key]  # Association
type_definition = registry.find(name)         # TypeDefinition
enum_definition = registry.find(name)         # EnumDefinition

# Bad — misleading suffix
attribute_definition = schema_class.attributes[key]  # Class is Attribute, not AttributeDefinition
```

**Exception:** When a variable can hold multiple types, use a semantic name:

```ruby
# shape can be Contract::Object, Contract::Union, or API::Object
shape = Object.new(contract_class)

# param_options is a Hash from .params iteration, not a class instance
shape.params.each do |name, param_options|
  # ...
end
```

### Context-aware Naming

Inside a context, use short names. Outside, add context:

```ruby
# Inside Invoice class — short name
class Invoice
  def total; end           # Good — context is clear
  def invoice_total; end   # Bad — repeats context
end

# Outside Invoice — add context
invoice_total = invoice.total    # Good — context needed
total = invoice.total            # Bad — ambiguous
```

### Cross-module Naming

When classes share names (e.g., `Introspection::Contract` vs `Contract::Action`):

```ruby
# Inside Introspection module
contract = Introspection::Contract.new      # local = short name
contract_action = Contract::Action.new      # external = prefixed

# Outside both modules — prefix both
introspection_contract = Introspection::Contract.new
contract_action = Contract::Action.new
```

---

## Structure

| Do                                                          | Don't                                     |
| ----------------------------------------------------------- | ----------------------------------------- |
| One class per file                                          | `helpers/`, `utils/`, `misc/` directories |
| Group code by concept, not technical helpers                | Inline nested classes                     |
| Prefer composition over modules (less hidden coupling)      | Deep inheritance hierarchies              |
| Class constants, not strings: `class_name: ProfileResource` | `include Module` — prefer composition     |

### Composition over Modules

```ruby
# Bad — module inclusion creates hidden coupling
class Api::Base
  include Recorder
end

# Good — explicit dependency via instance
class Api::Base
  def initialize
    @recorder = Recorder.new(metadata: @metadata)
  end
end
```

**Exceptions:**

- `ActiveSupport::Concern` for DSLs is OK
- `config/routes.rb` and files before autoloading may use strings

---

## Instance Variables vs Accessors

**Rule:** `attr_*` is for public API. `@variable` directly is for private state.

**Absolute rule:** Never access `@variable` from outside the class. No exceptions.

```ruby
# Forbidden — accessing @variable from outside
schema.instance_variable_get(:@cache)
object.send(:instance_variable_get, :@name)

# If you need external access — expose it as a method
```

| Want | Use | Example |
|------|-----|---------|
| Public getter | `attr_reader` with YARD | `attr_reader :name` |
| Public setter | `attr_writer` with YARD | `attr_writer :name` |
| Public both | `attr_accessor` with YARD | `attr_accessor :name` |
| Private state | `@variable` directly | `@cache = {}` |

### Visibility Levels

| Level | YARD | Who can use | Example |
|-------|------|-------------|---------|
| **Public** | `@api public` | Users of Apiwork | `Schema.find(path)` |
| **Semi-public** | No YARD | Apiwork internals only | `schema.attribute_definitions` |
| **Private** | `private` | Same class only | `def validate!` |

Semi-public methods are public Ruby methods without `@api public`. They exist for internal Apiwork use but are not part of the user-facing API. No YARD documentation.

**`protected` is forbidden.** Never use it. Choose `private` or semi-public instead.

```ruby
class Schema
  # @api public
  # @return [Hash]
  attr_reader :name  # Public — for users

  attr_reader :attribute_definitions  # Semi-public — for Apiwork internals

  private

  def validate!  # Private — same class only
  end

  # protected  # FORBIDDEN — never use
end
```

```ruby
class Invoice
  # Public — use attr_reader with YARD
  # @api public
  # @return [String]
  attr_reader :number

  def initialize(number)
    @number = number
    @cache = {}  # Private — just use @variable
  end

  def total
    @cache[:total] ||= calculate_total  # Private — @variable directly
  end

  private

  def calculate_total
    # ...
  end
end
```

**Never use `attr_*` for private state:**

```ruby
# Bad — attr_accessor for internal state
class Parser
  private

  attr_accessor :buffer  # Don't do this
end

# Good — just use @variable
class Parser
  def parse(input)
    @buffer = input.dup  # Private state, no accessor needed
    process_buffer
  end
end
```

---

## Underscore Prefix

Never use underscore prefix as pseudo-private.

**Exception:** `class_attribute` doesn't work well with `private`. Use underscore for internal class attributes only:

```ruby
class_attribute :_internal_config, default: {}  # OK — Rails limitation
class_attribute :public_definitions, default: {} # OK — public
```

Everywhere else, use `@variable` directly:

```ruby
# Bad — underscore as pseudo-private
class << self
  attr_accessor :_model_class
end

# Good — @variable directly
class << self
  def model(value = nil)
    value ? @model_class = value : @model_class
  end
end
```

---

## Class-level State

| Need | Use | Inherits to subclass |
|------|-----|----------------------|
| Subclasses should inherit/override | `class_attribute` | Yes |
| Class-specific, not inherited | `@variable` in `class << self` | No |

```ruby
class Schema
  # Subclasses inherit and can override
  class_attribute :attribute_definitions, default: {}
  class_attribute :_internal_cache, default: {}  # Internal — underscore

  class << self
    # Class-specific, not inherited
    def model(value = nil)
      value ? @model_class = value : @model_class
    end
  end
end
```

---

## instance_variable_get/set

**Forbidden in lib/.** If you need external access, expose a method.

```ruby
# Forbidden
object.instance_variable_get(:@cache)
object.instance_variable_set(:@api_class, value)

# Instead — add a method
attr_reader :cache
attr_writer :api_class
```

**In spec/:** Avoid, but allowed for test setup when no alternative exists. Prefer adding semi-public methods.

---

## Class Layout

Mandatory order for classes and modules:

1. Constants
2. All `attr_*` declarations together (`attr_reader`, `attr_writer`, `attr_accessor`)
3. `class << self`
4. `initialize`
5. Public instance methods
6. `private`
7. Private instance methods

**Within every section:** `@api public` methods appear first, then semi-public.

**All `attr_*` must be grouped together at the top.** Never scatter attr declarations throughout the file.

This applies to:
- `attr_reader` / `attr_accessor` declarations
- Methods inside `class << self`
- Instance methods

```ruby
class Schema
  # === attr_reader: @api public first ===
  # @api public
  # @return [Symbol]
  attr_reader :name

  attr_reader :internal_cache  # Semi-public — after @api public

  class << self
    # === class << self: @api public first ===

    # @api public
    # @return [Class]
    def model(value = nil)
      # ...
    end

    # @api public
    def attribute(name, **options)
      # ...
    end

    # Semi-public — after all @api public methods
    def model_class
      # ...
    end

    def build_query(params)
      # ...
    end
  end

  # === Instance methods: @api public first ===

  # @api public
  def as_json
    # ...
  end

  def internal_method  # Semi-public — after @api public
    # ...
  end

  private

  def validate!
    # ...
  end
end
```

No deviations. No reordering.

---

## Methods

| Do                                                         | Don't                                                 |
| ---------------------------------------------------------- | ----------------------------------------------------- |
| Keep public methods small and clear                        | Extract "because it feels cleaner"                    |
| Extract private method when used 2+ places                 | Have guards at call site when they belong to behavior |
| Extract private method when 5+ lines of non-trivial logic  | Test private methods                                  |
| Put guards inside the method, not at call site             | Extract "because methods should be short"             |
| Three similar lines is better than a premature abstraction |                                                       |

### Canonical Entry Points

Class and instance method names match the class's purpose:

| Class suffix | Method name |
|--------------|-------------|
| `*Generator` | `generate` |
| `*Loader` | `load` |
| `*Builder` | `build` |

Pattern: `initialize` takes configuration, method takes input.
Class method combines both: `new(config).method(input)`

```ruby
class RecordLoader
  def initialize(schema_class)
    @schema_class = schema_class
  end

  def load(params)
    # ...
  end

  def self.load(schema_class, params)
    new(schema_class).load(params)
  end
end
```

Forbidden: `.run`, `.execute`, `.perform`, `.process`, `.call`

### Guard Logic

```ruby
# Bad — guard at call site
validate_association! if @model_class

# Good — guard inside method
validate_association!

def validate_association!
  return unless @model_class
  # ...
end
```

Exception: external context stays at call site:

```ruby
send_notification if user.opted_in?
```

---

## Conditions

| Do                                                         | Don't                          |
| ---------------------------------------------------------- | ------------------------------ |
| One guard per line                                         | `if !x` — use `unless x`       |
| Positive conditions                                        | `== false` — use `unless`      |
| Ruby idioms: `positive?`, `blank?`, `present?`, `exclude?` | `unless` with complex logic    |
|                                                            | Compound guards on single line |

```ruby
# Bad
return if abstract? || @model_class.nil? || @schema_class
if !user.active?
if order.total > 0

# Good
return if abstract?
return if @model_class.nil?
return if @schema_class
unless user.active?
if order.total.positive?
```

---

## Arguments

| Do                                                       | Don't                                              |
| -------------------------------------------------------- | -------------------------------------------------- |
| Keyword arguments for all optionals: `def foo(bar: nil)` | `arg = nil` as positional (exception: DSL setters) |
| Defaults in signature, not computed later                | Options hashes                                     |
| Multiline signatures at 4+ keywords                      | Magic defaults computed inside method              |
| Explicit keyword names: `scope: scope` not `scope:`      |                                                    |
| Order: positional, then keyword, then splat              |                                                    |

```ruby
# 4+ keywords: multiline, defaults in signature
def initialize(name, type, schema_class,
               schema: nil,
               include: :optional,
               filterable: false)
  @name = name
end
```

---

## Ruby Style

| Do                                                      | Don't                                    |
| ------------------------------------------------------- | ---------------------------------------- |
| Intermediate variables for complex expressions          | `then`                                   |
| Clear block parameters: `{ \|item\| process(item) }`    | `_1`, `_2` (numbered params)             |
| Rails idioms: `delegate`, `index_by`, `tap`, `presence` | `inject`, `reduce` — use `each_with_object` |
| Transform: `map`, Filter: `select`/`reject`, Accumulate: `each_with_object` | Long method chains across multiple lines |
| Inline simple method calls used 1-2 times               | Variables for trivial expressions        |
|                                                         | Unnecessarily clever Ruby                |

### Intermediate Variables

Use intermediate variables for:
- Complex expressions that need a name for clarity
- Breaking up long method chains (3+ calls)

Don't create variables for:
- Simple method calls used 1-2 times
- Expressions that are already clear from context

```ruby
# Bad — unnecessary variable
schema_class = definition.schema_class
return false unless schema_class
schema_class.validate!

# Good — inline simple method call
return false unless definition.schema_class
definition.schema_class.validate!

# Good — variable for complex expression
filtered_attributes = schema.attributes.select(&:filterable?).index_by(&:name)
```

### Idioms

**Use:** `map(&:to_s)`, `select(&:present?)`, `compact_blank`, `index_by`, `each_with_object({})`, `group_by`, `delegate`, `tap`, `present?`, `blank?`, `presence`, `FOO = {...}.freeze`, `amount.positive?`, `collection.any?`, `value.zero?`, `{ title, value }` (hash shorthand)

**Memoization** (`@x ||= ...`) is allowed for lazy computation only:

```ruby
# OK — lazy computation
def schema
  @schema ||= build_schema
end

# Forbidden — defensive initialization (see Defensive Code)
(@items ||= {})[key] = value
```

---

## Zeitwerk

Never `require` application code. Just use the class.

```ruby
# Bad
require 'app/models/user'

# Good
User.find(1)
```

Use `require` only for: gems, stdlib, files outside autoload paths.

---

## Comments

**Absolute rule.** No comments in code or tests.

Allowed exceptions:

- Magic comments (`# frozen_string_literal: true`)
- RuboCop directives
- Temporary TODOs (must be removed before merge)

**If code requires a comment — it's written wrong.** Extract logic to well-named predicates:

```ruby
# Bad
if user.subscription_tier == 'premium' && user.api_calls_this_month < 10_000

# Good
if user.can_make_api_call?
```

---

## Defensive Code

**Absolute rule:** Never use optional chaining (`&.`) or fallbacks (`|| default`) on values that should exist.

| Forbidden | Problem | Fix |
|-----------|---------|-----|
| `api_class&.adapter&.class` | Hides broken state | Ensure api_class is set |
| `value || default` | Silent fallback masks bugs | Fail if value missing |
| `@items ||= {}` | Lazy init hides missing setup | Initialize in constructor |
| `object&.method` on required object | Pretends nil is valid | Fix construction |

**The code below is a bug, not defensive programming:**

```ruby
# BAD — silent fallback hides broken state
adapter_class = api_class&.adapter&.class || Adapter::Standard

# GOOD — fail fast if invariant violated
def adapter_class
  api_class.adapter.class
end

# Or guard at entry point, not throughout
def load_schema(name)
  return nil unless api_class  # Guard once at entry

  schema_class = api_class.schemas[name]  # Then trust it
  # ...
end
```

**Principle:** If something "can be nil" ask: *should* it be nil? Often the answer is "no, we have a bug elsewhere." Fix that bug instead of adding `&.` everywhere.

Trust your invariants. Fix construction, not symptoms.

---

## YARD

Only for `@api public` methods.

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

### Declarations

`@api public` declarations: one per line with YARD. Otherwise: group.

```ruby
# === @api public — one per line ===

# @api public
# @return [Hash] the context
attr_reader :context

# @api public
# @return [Symbol] the type name
delegate :type, to: :api_class

# === Internal — group, one per line ===
attr_reader :cache,
            :options,
            :registry

delegate :internal_lookup,
         :internal_state,
         to: :api_class

private

# === Private — group, one per line ===
attr_reader :buffer,
            :state
```

### delegate with @api public

Use `@!method` before the delegate block to document `@api public` methods:

```ruby
# @!method register(klass)
#   @api public
#   Registers an adapter.
#   @param klass [Class] an {Adapter::Base} subclass
#   @see Adapter::Base
delegate :all,
         :find,
         :register,
         :registered?,
         to: Registry
```

Internal and public methods are combined in the same delegate — `@!method` documents only the public ones.

### class_methods blocks

YARD can't see inside `class_methods do`. Use `@!method` with `@!scope class`:

```ruby
# @!method option(name, type:, default: nil, enum: nil, &block)
#   @!scope class
#   @api public
#   Defines a configuration option.
#   @param name [Symbol] the option name
#   @param type [Symbol] the option type
#   @return [void]

class_methods do
  def option(name, type:, default: nil, enum: nil, &block)
    # ...
  end
end
```

### Mixin methods

Document mixin methods only when the mixin lacks docs or when adapting for the class's context:

```ruby
# @api public
# Base class for contracts.
#
# @!scope class
# @!method abstract!
#   @api public
#   Marks this contract as abstract.
#   @return [void]
#
# @!method abstract?
#   @api public
#   Returns whether this contract is abstract.
#   @return [Boolean]
class Base
  include Abstractable
end
```

---

# Testing

## Goals

- Tests are specifications, not scripts
- Failures must clearly communicate what broke
- Tests protect **intent**, not internal structure
- Test data must be consistent, recognizable, and boring

---

## Directory Structure

```
spec/
├── apiwork/       # Unit specs (mirrors lib/apiwork/)
├── integration/   # Cross-domain specs
├── dummy/         # Test Rails app
└── support/       # Builders, helpers, shared contexts
```

### Mapping

- `lib/apiwork/**` maps to `spec/apiwork/**`
- Cross-domain behavior goes to `spec/integration/**`
- `spec/lib` is forbidden

**Rule:** If unsure where a test belongs — it's integration.

---

## Unit vs Integration

**Unit:** Tests one domain, minimal setup, no cross-domain assumptions.

**Integration:** Tests interaction between domains, realistic world, real objects.

| Do                                | Don't                             |
| --------------------------------- | --------------------------------- |
| Choose integration when in doubt  | Force integration tests into unit |
| Test behavior, not implementation | Mock away half the system         |
| Prefer real objects over mocks    | Mix domains in unit tests         |

---

## Canonical Test World

Tests must use a **fixed vocabulary**.

| Domain        | Terms                                                                                                       |
| ------------- | ----------------------------------------------------------------------------------------------------------- |
| Billing       | `invoice`, `item`, `items`, `customer`, `payment`, `currency`                                               |
| Content       | `post`, `comment`, `comments`, `author`                                                                     |
| Framework     | `api`, `resource`, `action`, `schema`, `type`, `enum`, `adapter`, `capabilities`, `introspection`, `export` |
| **Forbidden** | `foo`, `bar`, `baz`, `test`, `example`, `sample`                                                            |

---

## Test Naming

### describe

For **stable API surfaces only**:

- Class: `RSpec.describe Apiwork::Schema::Base`
- Instance method: `describe "#call"`
- Class method: `describe ".call"`

### context

For meaningful variation. Must start with:

- `when …`
- `with …`
- `without …`
- `if …`

### it

Short, factual, present tense. One outcome per `it`.

```ruby
# Good
it 'returns a hash'
it 'includes derived types'
it 'raises DomainError'

# Bad — multiple behaviors
it 'validates and saves the record'
```

---

## Test Structure

### Arrange / Act / Assert

Always explicit. Always in order.

### Grouping

Group by public API, never by implementation detail.

Private methods must never be tested directly.

### Shared Code

Builders live in `spec/support`.
Extract after 3+ repetitions.

---

## Mocks

| Do                            | Don't                                       |
| ----------------------------- | ------------------------------------------- |
| Prefer real objects           | Over-mock                                   |
| Mock only external boundaries | Mock internal collaborators                 |
| Use semi-public methods       | Use `instance_variable_get/set`             |
|                               | Use mocks to avoid understanding the system |

**Semi-public in tests:** Tests may use semi-public methods (e.g., `.attribute_definitions`, `.actions`). They are public Ruby methods, just not user-facing API.

---

# Documentation

## Golden Rule

**Verify against code.** Never invent behavior.

Before writing:

1. Read the implementation
2. Run the code if uncertain
3. Check tests for expected behavior

If you cannot verify it, do not document it.

---

## Documentation Rules

| Do                                         | Don't                      |
| ------------------------------------------ | -------------------------- |
| Document only public API                   | Document internal details  |
| Link generously                            | Guess behaviors            |
| Show examples when they help understanding | Let docs diverge from code |
| Use YARD only for `@api public` methods    | Invent features            |

---

## Phases

Work in **one phase at a time**. Never mix.

| Phase               | Do                               | Do Not                                  |
| ------------------- | -------------------------------- | --------------------------------------- |
| **1. Style & Tone** | Improve clarity, consistency     | Change meaning, add/remove features     |
| **2. Verification** | Compare docs to code, fix errors | Rewrite unless required for correctness |
| **3. Navigation**   | Add links, intros, "See also"    | Re-explain content                      |

---

## Tone

**Direct.** State facts. No hedging.
**Technical.** Assume Ruby/Rails knowledge.
**Pedagogical.** Show code first, explain briefly after.

---

## Avoid Patterns

| Pattern                          | Fix                       |
| -------------------------------- | ------------------------- |
| "Let's explore how..."           | Just explain it           |
| "It's important to note that..." | State the fact            |
| "This allows you to..."          | "You can..."              |
| "In this section, we will..."    | Just do it                |
| "As mentioned earlier..."        | Link to it                |
| "powerful feature"               | "feature"                 |
| "seamlessly integrates"          | "integrates"              |
| "simply", "just", "easily"       | Delete                    |
| "In order to"                    | "To"                      |
| Arrow characters (`→`)           | "becomes", "then"         |
| Passive voice                    | Active voice              |
| Future tense ("will")            | Present tense             |
| "We"                             | "You" or direct statement |

---

## Document Structure

- `#` page title (one per page)
- `##` major sections
- `###` subsections (avoid deeper)
- 1–3 sentences per paragraph

**Page intro:** What it covers, what reader learns, how it fits. No selling.

---

## Code Examples

Show immediately after concept. Real, runnable, minimal.

```ruby
# Bad
request { body { param :name } }
body { param :id; param :title }

# Good
request do
  body do
    param :name
  end
end

body do
  param :id
  param :title
end

# Exception: simple single-item
response { no_content! }
```

---

## Formatting

**Lists over prose:**

```markdown
The adapter:

- Validates the request
- Queries the database
- Serializes the response
```

**Tables** for reference information.

**Callouts** — sparingly, never with custom titles:

```markdown
::: info
Text stands on its own.
:::
```

Never:

```markdown
::: info Custom Title
...
:::
```

Types: `info`, `tip`, `warning`, `danger`

---

## Linking

Link first mention of concepts, options, APIs, related behavior.

```markdown
Schemas define [attributes](./attributes.md) that map to model columns.
```

- Guides: _how_ and _why_
- Reference: _what_
- See Also: end of page, max 3–5 links

---

## Example Linking System

Examples link to `docs/playground/` via VitePress embeds.

```markdown
<!-- example: eager-lion -->

<<< @/playground/app/contracts/eager_lion/invoice_contract.rb

<details>
<summary>Introspection</summary>

<<< @/playground/public/eager-lion/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/eager-lion/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/eager-lion/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/eager-lion/openapi.yml

</details>
```

### Namespace conventions

| Context    | Format     | Example                        |
| ---------- | ---------- | ------------------------------ |
| Comment    | dash-case  | `<!-- example: eager-lion -->` |
| Ruby       | PascalCase | `EagerLion::Invoice`           |
| Folder     | snake_case | `app/models/eager_lion/`       |
| Mount path | dash-case  | `/eager-lion`                  |
| Output     | dash-case  | `public/eager-lion/`           |
| Table      | snake_case | `eager_lion_invoices`          |

### New example

1. Create `config/apis/lazy_cow.rb`
2. Contracts only: `app/contracts/lazy_cow/`
3. With schemas: also `app/schemas/`, `app/models/`, `db/migrate/`
4. Run `rake docs:generate`
5. Add `<details>` blocks

### Sync rule

Code changes, then `docs/playground/`, then `rake docs:generate`, then `public/`, then VitePress embeds.

**Same commit. No exceptions.**

---

## Mental Model

- Database = source of truth
- Rails/ActiveRecord = domain
- Apiwork introspects this structure
- Contracts, schemas, APIs build on it
- Specs, types, validation = derived, never duplicated

---

## Documentation Checklist

- [ ] Verified against code
- [ ] No invented behavior
- [ ] Runnable examples
- [ ] No marketing/filler/AI patterns
- [ ] Active voice, present tense
- [ ] 1–3 sentence paragraphs
- [ ] Correct links
- [ ] Multi-line block formatting
- [ ] No custom titles in callouts

---

# Final Rules

## After Every Change

1. `bundle exec rubocop -A`
2. `bundle exec rspec`
3. If `@api public` was added or changed: `cd docs/playground && bundle exec rake apiwork:docs:reference`

## Code

If code requires a comment — it's written wrong.

## Tests

Tests are documentation with consequences.

## Documentation

Unclear? **Do not guess. Do not invent. Ask, or leave undocumented.**

## Code Review

When reviewing code, follow `.claude/REVIEW.md` checklist **point by point**. Do not skip items. Check every rule for every file before moving on.

## Final Law

**Sameness beats cleverness.**

Any variation — even if "better" — is a bug.
