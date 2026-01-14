# Naming Audit

Instructions for reviewing and correcting naming in the codebase.

---

## Core Rule

**Variables should be named after their class.**

```ruby
# Good
type_definition = TypeDefinition.new
attribute = Attribute.new
type = Introspection::Type.new
param = Introspection::Param.build(dump)

# Bad
definition = TypeDefinition.new
attr = Attribute.new
data = Introspection::Type.new
```

---

## Exceptions and Special Cases

### Shape types

`Contract::Object`, `Contract::Union`, `API::Object` → use `shape`

```ruby
shape = Contract::Object.new
shape = Union.new(discriminator: :type)
```

### Hash from iteration

| Source | Variable name |
|--------|---------------|
| `.params.each { \|name, ???\| }` | `param_options` |
| `.variants.each { \|???\| }` | `variant` |

```ruby
type_definition.params.each do |param_name, param_options|
  # param_options is a Hash, not a Param object
end

union.variants.each do |variant|
  # variant is a Hash with :tag, :type, :shape, etc.
end
```

### ActiveRecord vs Apiwork

| Class | Variable name |
|-------|---------------|
| `ActiveRecord::Reflection::AssociationReflection` | `reflection` |
| `Apiwork::...::Association` | `association` |

```ruby
reflection = model_class.reflect_on_association(name)
association = Association.new(name, reflection)
```

### Context-aware naming

Don't repeat context that's already clear from the class/module name:

```ruby
# Inside TypeRegistry - context is clear
class TypeRegistry
  def find(name)
    definition = @store[name]  # Good - we know it's a type definition
  end
end

# Inside EnumRegistry - context is clear
class EnumRegistry
  def find(name)
    definition = @store[name]  # Good - we know it's an enum definition
  end
end

# Outside any registry - context needed
type_definition = type_registry.find(name)
enum_definition = enum_registry.find(name)
```

### Symbol collections

Follow the `*_names` pattern for collections of symbols:

| Contents | Variable name |
|----------|---------------|
| Type symbols (`:address`, `:invoice`) | `type_names` |
| Enum symbols (`:status`, `:currency`) | `enum_names` |
| Reference symbols | `reference_names` |

```ruby
type_names = Set.new
reference_names = []

reference_names.each do |reference_name|
  type_names << reference_name
end
```

---

## Method Names

### Match the parameter

Method names should describe what they receive:

```ruby
# Good - takes Param, named map_param
def map_param(param)
end

# Bad - takes param but named map_type_definition
def map_type_definition(param)
end
```

### Avoid unnecessary indirection

Work with objects directly instead of converting to Hash:

```ruby
# Bad - unnecessary conversion
def process_types(types)
  types.each_value do |type|
    process_type_data(type.to_h)
  end
end

# Good - use the object's interface
def process_types(types)
  types.each_value do |type|
    process_type(type)
  end
end
```

---

## Forbidden Patterns

### Abbreviations

| Forbidden | Correct |
|-----------|---------|
| `refs` | `reference_names` |
| `ref` (in loop) | `reference_name` |
| `opts` | `options` |
| `cfg` | `config` |
| `attr` | `attribute` |
| `def` | `definition` |

### Generic names

| Forbidden | Replace with |
|-----------|--------------|
| `data` | Specific: `type_data`, `param_options` |
| `item` | Specific: `type`, `param`, `variant` |
| `definition` (outside context) | Specific: `type_definition`, `enum_definition` |

Note: `definition` is OK inside `TypeRegistry`, `EnumRegistry`, etc. where context is clear.

### `_data` suffix without reason

If you have `type_data` - ask: can I work with `type` directly instead?

---

## Search Commands

Find potential issues:

```bash
# Find generic "definition" variables
grep -r "definition\s*=" lib/

# Find _data suffix
grep -r "_data" lib/

# Find abbreviations
grep -rE "\brefs?\b" lib/
grep -rE "\bopts?\b" lib/

# Find Hash iteration with bad names
grep -rE "\.each.*\|.*data\|" lib/
grep -rE "\.each.*\|.*definition\|" lib/
```

---

## Verification

After changes:

```bash
bundle exec rspec
bundle exec rubocop -A
```
