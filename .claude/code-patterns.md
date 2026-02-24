# Code Patterns

Patterns for specific situations.

For core style rules, see `CLAUDE.md`.

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

## Singleton Class Naming

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

---

## Cross-module Naming

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
