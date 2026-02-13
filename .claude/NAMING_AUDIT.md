# Naming Audit

Instructions for reviewing and correcting naming in the codebase.

---

## Core Rules

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

---

## Variable Names Match Class Names

Variables should be named after their class:

```ruby
# Good
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
shape = Contract::Object.new

# param_options is a Hash from .params iteration, not a class instance
shape.params.each do |name, param_options|
  # ...
end
```

---

## Variable Names from Methods

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

---

## Context-aware Naming

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

Inside a registry, context is clear:

```ruby
class TypeRegistry
  def find(name)
    definition = @store[name]  # Good - we know it's a type definition
  end
end

# Outside — context needed
type_definition = type_registry.find(name)
enum_definition = enum_registry.find(name)
```

---

## DSL Setters for Class References

DSL setters skip the `_class` suffix. Getters use it:

```ruby
# Setter — no _class suffix
class InvoiceRepresentation < Representation::Base
  model Invoice
end

# Getter — uses _class suffix
representation.model_class
contract.representation_class
```

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

---

## Special Cases

### Shape types

`Contract::Object`, `Contract::Union`, `API::Object` → use `shape`

### Hash from iteration

| Source                           | Variable name   |
| -------------------------------- | --------------- |
| `.params.each { \|name, ???\| }` | `param_options` |
| `.variants.each { \|???\| }`     | `variant`       |

### ActiveRecord vs Apiwork

| Class                                             | Variable name |
| ------------------------------------------------- | ------------- |
| `ActiveRecord::Reflection::AssociationReflection` | `reflection`  |
| `Apiwork::...::Association`                       | `association` |

### Symbol collections

| Contents                              | Variable name     |
| ------------------------------------- | ----------------- |
| Type symbols (`:address`, `:invoice`) | `type_names`      |
| Enum symbols (`:status`, `:currency`) | `enum_names`      |
| Reference symbols                     | `reference_names` |

---

## Forbidden Patterns

| Forbidden       | Correct           |
| --------------- | ----------------- |
| `refs`          | `reference_names` |
| `ref` (in loop) | `reference_name`  |
| `opts`          | `options`         |
| `cfg`           | `config`          |
| `attr`          | `attribute`       |
| `def`           | `definition`      |
| `_data` suffix  | Use object directly |

---

## Verification

```bash
bundle exec rspec
bundle exec rubocop -A
```
