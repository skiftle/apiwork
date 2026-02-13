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
├── representation/ # Serialization layer, attributes, associations
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
| Execution details belong in documentation, not in names          |                                                    |

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
| Full names: `attribute` not `attr` (exception: `param`, `arg`, `attr_reader`) |                                                          |
| Method names: nouns for getters, verbs for actions                     |                                                          |
| For single-use conversions, inline it                                  |                                                          |

### DSL Setters for Class References

DSL setters that accept class references skip the `_class` suffix for readability:

```ruby
# Good — setter skips _class
class InvoiceRepresentation < Representation::Base
  model Invoice
end

class InvoiceContract < Contract::Base
  representation InvoiceRepresentation
end

# Bad — setter with _class suffix
model_class Invoice
representation_class InvoiceRepresentation
```

To retrieve the class, always use the `_class` getter:

```ruby
# Good — getter uses _class
representation.model_class
contract.representation_class

# Bad — using setter as getter
representation.model  # Don't use for reading
```

**Important:** Class setters must NOT return their value. Other DSL methods may return values, but class setters return `nil` implicitly.

### Variable Names Match Class Names

Variables should be named after their class:

```ruby
# Good — variable name matches class
attribute = schema_class.attributes[key]      # Attribute
association = schema_class.associations[key]  # Association
type_definition = registry.find(name)         # TypeRegistry::Definition
enum_definition = registry.find(name)         # EnumRegistry::Definition

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

### Variable Names from Methods

When assigning from a method, the variable name should describe what it IS, not how it was obtained:

```ruby
# Good — it's an enum name, the method tells us it's scoped
enum_name = scoped_enum_name(name)

# Bad — repeats the qualifier from the method name
scoped_enum_name = scoped_enum_name(name)
```

Drop qualifiers when the variable is the only one of its kind in scope. Add qualifiers only to distinguish between multiple similar values.

**Exception:** When the variable matches a keyword argument, keep the name for shorthand syntax:

```ruby
# OK — data_type: uses shorthand syntax
data_type = resolve_resource_data_type(representation_class)
shape_class.apply(body, data_type:)
```

### Singleton Class Naming

When there's only one class of a type within a module, skip the qualifier:

```ruby
# Good — Writing capability has only one request transformer
module Writing
  class RequestTransformer < Base; end
end

# Bad — unnecessary qualifier when there's only one
module Writing
  class OpFieldRequestTransformer < Base; end
end
```

The parent module already provides context. Add qualifiers only when distinguishing between multiple classes of the same type.

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

### Private Method Prefixes

Private methods use semantic prefixes:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `validate_*` | Validation logic | `validate_required`, `validate_type` |
| `normalize_*` | Input transformation | `normalize_key`, `normalize_writable` |
| `resolve_*` | Lookup/resolution | `resolve_enum`, `resolve_type` |
| `build_*` | Object construction | `build_issue`, `build_meta` |
| `detect_*` | Auto-detection | `detect_type`, `detect_model` |

```ruby
private

def validate_required(name, value, options)
  return if options[:optional]
  # ...
end

def normalize_key(key)
  key.to_s.underscore.to_sym
end

def resolve_type(name)
  registry.find(name) || raise(KeyError)
end
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

## Registry Pattern

All registries implement a consistent API:

| Method | Purpose |
|--------|---------|
| `find(key)` | Returns item or nil |
| `find!(key)` | Returns item or raises KeyError |
| `exists?(key)` | Returns boolean |
| `keys` | Returns all registered keys |
| `values` | Returns all registered items |
| `register(item)` | Adds item to registry |
| `delete(key)` | Removes item |
| `clear!` | Removes all items (destructive) |

```ruby
# All registries follow this pattern
class MyRegistry < Apiwork::Registry
  class << self
    def normalize_key(key)
      key.to_sym
    end
  end
end
```

Public facade delegates to registry:

```ruby
module Apiwork::MyDomain
  class << self
    delegate :find, :find!, :exists?, :keys, :values,
             to: Registry
  end
end
```

---

## Module and Class Naming

### Principle: Two levels of structure

**Infrastructure-level** (adapter/, shared base classes):
- Use nested modules for concept-namespaces
- File structure matches module path

**Domain-level** (inside capabilities, serializers):
- Use compound names for implementations
- Flatter file structure

### Concept-namespaces (nested modules)

Top-level modules that group related functionality:

| Namespace | Purpose |
|-----------|---------|
| `Capability::` | Capability infrastructure and base classes |
| `Serializer::` | Serialization infrastructure |
| `Wrapper::` | Response wrapper handling |
| `Builder::` | Shared builder base classes |
| `Transformer::` | Request/response transformation |

```ruby
# Infrastructure — nested modules
Adapter::Builder::API::Base
Adapter::Builder::Contract::Base
Adapter::Capability::API::Base
Adapter::Capability::Contract::Base
```

File structure:
```
adapter/
├── builder/
│   ├── api/
│   │   └── base.rb      # Builder::API::Base
│   └── contract/
│       └── base.rb      # Builder::Contract::Base
└── capability/
    ├── api/
    │   └── base.rb      # Capability::API::Base
    └── contract/
        └── base.rb      # Capability::Contract::Base
```

### Domain implementations (compound names)

Inside domain classes (capabilities, serializers), use compound names:

```ruby
# Domain — compound names
class Filtering < Capability::Base
  class APIBuilder < Adapter::Capability::API::Base
  class ContractBuilder < Adapter::Capability::Contract::Base
  class Computation < Adapter::Capability::Computation::Base
end

class Pagination < Capability::Base
  class APIBuilder < Adapter::Capability::API::Base
  class ContractBuilder < Adapter::Capability::Contract::Base
  class Computation < Adapter::Capability::Computation::Base
  class OffsetPaginator    # Strategy implementation
  class CursorPaginator    # Strategy implementation
end
```

File structure:
```
standard/capability/filtering/
├── api_builder.rb         # Filtering::APIBuilder
├── contract_builder.rb    # Filtering::ContractBuilder
├── computation.rb         # Filtering::Computation
└── filter/
    └── ...
```

### Rule: Nested module vs Compound name

| Context | Use | Example |
|---------|-----|---------|
| Infrastructure base class | Nested module | `Adapter::Builder::API::Base` |
| Concept-namespace | Nested module | `Capability::`, `Serializer::` |
| Domain implementation | Compound name | `Filtering::APIBuilder` |
| Strategy/algorithm | Compound name | `OffsetPaginator`, `CursorPaginator` |
| Helper class in domain | Compound name | `OperatorBuilder`, `RequestParser` |

### File structure follows naming

```ruby
# Nested module = directory structure
Adapter::Builder::API::Base
# → lib/apiwork/adapter/builder/api/base.rb

# Compound name = flat file
Filtering::APIBuilder
# → lib/apiwork/adapter/standard/capability/filtering/api_builder.rb
```

### Reopening Classes in Nested Files

When a class is defined with inheritance in one file, nested files that reopen the class must NOT repeat the inheritance:

```ruby
# main_file.rb — defines class with inheritance
class Operation < Adapter::Capability::Operation::Base
  # ...
end

# nested_file.rb — reopens class, NO inheritance
class Operation  # Correct — class already exists
  class Helper
    # ...
  end
end

# nested_file.rb — WRONG
class Operation < Adapter::Capability::Operation::Base  # Don't repeat!
  class Helper
  end
end
```

Inheritance is declared once where the class is defined. Nested files just reopen the class.

### DSL reference

```ruby
class Filtering < Capability::Base
  api_builder APIBuilder           # Compound name
  contract_builder ContractBuilder # Compound name
  computation Computation          # Simple name
end
```

### Class Suffix Conventions

| Suffix | Purpose | Example |
|--------|---------|---------|
| `*Base` | Abstract parent class | `Adapter::Base`, `Capability::Base` |
| `*Definition` | Metadata/configuration holder | `TypeRegistry::Definition`, `EnumRegistry::Definition` |
| `*Registry` | Lookup and storage | `API::Registry`, `TypeRegistry` |
| `*Default` | Concrete standard implementation | `Serializer::Resource::Default` |
| `*Builder` | Construction logic | `APIBuilder`, `ContractBuilder` |
| `*Wrapper` | Response wrapping | `Wrapper::Member::Default` |
| `*Serializer` | Serialization logic | `Resource::Serializer` |

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

### When to Use Each Level

**Public (`@api public`)** — The user-facing API. Use for:
- Methods users call directly
- Configuration DSL methods (`model`, `attribute`, `action`)
- Query methods users need (`find`, `exists?`)
- Factory methods (`define`, `create`)

**Semi-public** (no YARD) — Internal Apiwork API. Use for:
- Methods called across modules within Apiwork
- Accessors needed by other Apiwork classes (`attribute_definitions`, `actions`)
- Helper methods used by adapters, serializers, exporters
- Methods tests may call for setup/verification

**Private** — Same class only. Use for:
- Implementation details (`validate_required`, `normalize_key`)
- Helper methods used only within the class
- Internal state management

### Decision Flowchart

1. Will external users call this? then **Public** (with `@api public` and YARD)
2. Will other Apiwork modules call this? then **Semi-public** (no YARD)
3. Only used in this class? then **Private**

### Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Making everything public | Bloated API, hard to change | Only expose what users need |
| Making helpers semi-public | Unnecessary coupling | Keep implementation private |
| Using private for cross-module | Forces `send` or duplication | Make semi-public |
| Adding YARD to semi-public | Implies user API | Remove YARD, keep method |

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

**Exception:** When a private attr_reader would ONLY be used as a delegate target, use `to: :@variable` syntax instead:

```ruby
# Good — delegate directly to instance variable
class Builder
  delegate :enum, :object, to: :@api_class

  def initialize(api_class)
    @api_class = api_class
  end
end

# Bad — unnecessary private attr_reader
class Builder
  delegate :enum, :object, to: :api_class

  private

  attr_reader :api_class
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

**All `attr_*` and `delegate` must be grouped together at the top.** Never scatter declarations throughout the file. This applies everywhere: at class level, inside `class << self`, and after `private`.

**Never split `attr_*` or `delegate` for YARD documentation.** If one item needs `@api public`, use YARD directives (`@!attribute` for `attr_*`, `@!method` for `delegate`) above the grouped declaration. See `.claude/YARD.md` for the format.

**Multi-item declarations:** Use one item per line with trailing commas:

```ruby
# Multiple attrs — one per line
attr_reader :cache,
            :options,
            :registry

# Multiple delegates — one per line
delegate :find,
         :create,
         :update,
         to: :repository
```

```ruby
class Schema
  # === Class level: ONE attr_reader with all items ===
  # @!method name
  #   @api public
  #   @return [Symbol]
  attr_reader :name,
              :internal_cache

  class << self
    # === Inside class << self: same rules ===
    # @!method model_class
    #   @api public
    #   @return [Class]
    attr_reader :model_class,
                :cache,
                :registry

    attr_writer :building

    # @api public
    def attribute(name, **options)
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

  def internal_method
    # ...
  end

  private

  attr_reader :buffer,
              :state

  def validate!
    # ...
  end
end
```

No deviations. No reordering.

---

## Class Method Style

**Always use `class << self` blocks.** Never `def self.method`.

```ruby
# Good — class << self block
class Schema
  class << self
    def find(key)
      # ...
    end

    def register(item)
      # ...
    end
  end
end

# Bad — def self.method
class Schema
  def self.find(key)
    # ...
  end
end
```

Exception: None. The codebase uses `class << self` exclusively.

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

**`-er` suffix classes (agents) use verb form of the suffix:**

| Class suffix | Method name |
|--------------|-------------|
| `*Generator` | `generate` |
| `*Loader` | `load` |
| `*Builder` | `build` |
| `*Transformer` | `transform` |
| `*Parser` | `parse` |
| `*Resolver` | `resolve` |
| `*Mapper` | `map` |

**Non-`-er` classes use semantically appropriate verb:**

| Class | Method | Rationale |
|-------|--------|-----------|
| `Filter` | `apply` | "apply the filter" |
| `Sort` | `apply` | "apply the sort" |
| `Paginate` | `apply` | "apply pagination" |
| `Operation` | `apply` | "apply the operation" |
| `Export` | `generate` | "generate the export" |

Default is `apply`. Use established domain verb when it fits better.

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

Forbidden: `.execute`, `.perform`, `.process`, `.call`

### Bang Methods

Bang (`!`) suffix indicates one of:

| Type | Meaning | Example |
|------|---------|---------|
| Raises on failure | Method raises instead of returning nil/false | `validate!`, `find!` |
| Destructive | Modifies state irreversibly | `clear!`, `delete!` |
| State mutation | Sets a flag/state | `abstract!`, `deprecated!` |

```ruby
# Raises on failure
def find!(key)
  find(key) || raise(KeyError, "Key not found: #{key}")
end

# Destructive
def clear!
  @store.clear
end

# State mutation
def abstract!
  self._abstract = true
end
```

### Predicate Methods

Predicate methods (ending with `?`) name the condition directly. The `?` suffix already signals a question — prefixes like `should_`, `needs_`, `has_`, `is_`, `can_` are redundant.

| Bad | Good | Why |
|-----|------|-----|
| `should_include_association?` | `include_association?` | `should_` is redundant |
| `needs_transform?` | `transform?` | `needs_` is redundant |
| `has_index_actions?` | `index_actions?` | `has_` is redundant |
| `is_valid?` | `valid?` | `is_` is redundant |
| `can_paginate?` | `paginate?` | `can_` is redundant |

**Exception:** Rails DSL methods (`has_one`, `has_many`) follow Rails conventions.

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
| Required arguments are positional                        | Required arguments as keyword (see exception below) |
| Keyword arguments for all optionals: `def foo(bar: nil)` | `arg = nil` as positional (exception: DSL setters) |
| Defaults in signature, not computed later                | Options hashes                                     |
| Multiline signatures at 4+ keywords                      | Magic defaults computed inside method              |
| Explicit keyword names: `scope: scope` not `scope:`      |                                                    |
| Order: positional, then keyword, then splat              |                                                    |

**Exception:** Required keyword arguments are allowed when they add semantic clarity at the call site:

```ruby
# Good — `as:` clarifies meaning at call site
import CoolContract, as: :cool

# Bad — positional `as` is ambiguous
import CoolContract, :cool
```

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

### Iteration Patterns

| Operation | Method | Example |
|-----------|--------|---------|
| Transform | `map` | `items.map { \|item\| item.name }` |
| Filter | `select` / `reject` | `items.select(&:valid?)` |
| Accumulate | `each_with_object` | `items.each_with_object({}) { \|i, h\| h[i.id] = i }` |
| Side effects | `each` | `items.each { \|item\| save(item) }` |
| Find one | `find` | `items.find { \|item\| item.id == id }` |
| Flatten + transform | `flat_map` | `groups.flat_map(&:items)` |

**Forbidden:**

| Don't | Use instead |
|-------|-------------|
| `inject` / `reduce` | `each_with_object` |
| `_1`, `_2` (numbered params) | Named block params |
| Long chains (4+ calls) | Intermediate variables |

### Rails Idioms

**Required idioms:**

| Idiom | Purpose |
|-------|---------|
| `delegate :method, to: :target` | Method forwarding |
| `class_attribute :name` | Inheritable class state |
| `ActiveSupport::Concern` | DSL mixins |
| `present?` / `blank?` | Nil/empty checks |
| `presence` | Return value or nil |

**String transformations:**

| Method | Example |
|--------|---------|
| `underscore` | `"MyClass"` becomes `"my_class"` |
| `demodulize` | `"Foo::Bar"` becomes `"Bar"` |
| `constantize` / `safe_constantize` | String to class |
| `pluralize` / `singularize` | Inflection |

**Hash transformations:**

| Method | Purpose |
|--------|---------|
| `transform_values` | Transform all values |
| `transform_keys` | Transform all keys |
| `deep_transform_keys` | Recursive key transform |
| `deep_symbolize_keys` | All keys to symbols |

### Symbol Construction

Prefer array join over string interpolation for dynamic symbols:

```ruby
# Good — clear structure, easy to extract
[prefix, name].join('_').to_sym
[action_name, 'payload'].join('_').to_sym

# Avoid — harder to read and extract
:"#{prefix}_#{name}"
:"#{action_name}_payload"
```

When the expression appears 2+ times, extract to a variable:

```ruby
type_name = [name, TYPE_NAME].join('_').to_sym
next if type?(type_name)
union(type_name) do |union|
  # ...
end
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

## Frozen String Literal

**Every file must start with:**

```ruby
# frozen_string_literal: true
```

No exceptions. This is the only allowed comment at file top (besides shebang if needed).

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

## Class Parameter Validation

DSL methods that accept class arguments must validate with two separate checks and consistent error messages.

**Pattern:**

```ruby
def representation(klass)
  unless klass.is_a?(Class)
    raise ConfigurationError,
          "<method> must be a <Type> class, got #{klass.class}. " \
          "Use: <method> Example (not 'Example' or :example)"
  end
  unless klass < ExpectedBaseClass
    raise ConfigurationError,
          '<method> must be a <Type> class (subclass of Apiwork::<Path>), ' \
          "got #{klass}"
  end

  @representation_class = klass
end
```

**Rules:**

1. First check: `klass.is_a?(Class)` — catches strings, symbols, instances
2. Second check: `klass < BaseClass` — catches wrong class hierarchy
3. Error messages include helpful hints: `"Use: method Example (not 'Example' or :example)"`
4. Use `ConfigurationError` for DSL misconfigurations, not `ArgumentError`

**When to use `ConfigurationError` vs `ArgumentError`:**

| Error | When |
|-------|------|
| `ConfigurationError` | DSL/API definition errors (user configured wrong) |
| `ArgumentError` | Runtime method call with wrong argument type (programming error) |

DSL methods (`model`, `representation`, `resource_serializer`, etc.) always use `ConfigurationError`.

---

## Bug Fixing

**Fix root cause, not symptoms.**

When fixing a bug, ask: "Why does this happen?" not "How can I work around it?"

| Symptom Fix | Root Cause Fix |
|-------------|----------------|
| Add special case in consumer | Fix the producer |
| Patch specific feature to create missing state | Fix why state is missing |
| Add nil check where value is used | Ensure value is never nil |
| Rely on specific capability existing | Fix core behavior to work independently |

### Example

Problem: Unknown query params pass validation when no `include` type exists.

```ruby
# BAD — symptom fix in Including capability
# Relies on this specific capability existing
def register(context)
  context.actions.each_key do |action_name|
    context.registrar.action(action_name) do
      request do
        query  # Force query shape to exist
      end
    end
  end
end

# GOOD — root cause fix in Request
# Consistent with Action#request pattern
def query(&block)
  @query ||= Object.new(@contract_class, action_name: @action_name)
  @query.instance_eval(&block) if block
  @query
end
```

**Principle:** If `Action#request` always returns an object, `Request#query` should too. Fix the inconsistency, not the consumer.

### Questions to ask

1. Why is this value nil/missing/wrong?
2. Where should this value be set?
3. What pattern do similar methods follow?
4. Would this fix work if that specific feature didn't exist?

If your fix depends on a specific feature, capability, or configuration existing — it's a symptom fix.

---

## YARD

See `.claude/YARD.md` for complete YARD documentation rules.

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
