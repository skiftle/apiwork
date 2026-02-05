---
order: 4
---

# API Builders

API builders run once per API at initialization time. They register shared [types](../../../types/introduction.md) used across all contracts. API builders inherit from [`Adapter::Capability::API::Base`](/reference/adapter-capability-api-base).

```ruby
class APIBuilder < Adapter::Capability::API::Base
  def build
    return unless scope.has_index_actions?

    object(:offset_pagination) do |object|
      object.integer(:current)
      object.integer?(:next, nullable: true)
      object.integer?(:prev, nullable: true)
      object.integer(:total)
    end
  end
end
```

## Registering API Builders

In your capability:

```ruby
class Pagination < Adapter::Capability::Base
  capability_name :pagination

  api_builder APIBuilder
end
```

Or with an inline block:

```ruby
api_builder do
  object(:pagination_info) do |object|
    object.integer(:total)
  end
end
```

## Available Methods

### Type Registration

| Method | Purpose |
|--------|---------|
| `object(name, &block)` | Define an object type |
| `enum(name, values:)` | Define an enum type |
| `union(name, &block)` | Define a union type |
| `type?(name)` | Check if type exists |
| `enum?(name)` | Check if enum exists |

### Scope Queries

The [`scope`](/reference/adapter-capability-api-scope) attribute provides access to aggregated data across all representations:

| Method | Description |
|--------|-------------|
| `scope.has_index_actions?` | Whether any resource has index actions |
| `scope.filterable?` | Whether any representation has filterable attributes |
| `scope.sortable?` | Whether any representation has sortable attributes |
| `scope.filter_types` | Set of filterable attribute types |
| `scope.nullable_filter_types` | Filterable types that can be null |

### Configuration Queries

The `configured(key)` method returns all unique values for a configuration option across all representations:

```ruby
if configured(:strategy).include?(:cursor)
  # At least one representation uses cursor pagination
  object(:cursor_pagination) do |object|
    object.string?(:next, nullable: true)
    object.string?(:prev, nullable: true)
  end
end
```

### Options Access

The `options` attribute provides capability configuration:

```ruby
def build
  if options.include_totals
    # ...
  end
end
```

## Example: Pagination API Builder

Registers pagination types based on which strategies are configured:

```ruby
class APIBuilder < Adapter::Capability::API::Base
  def build
    return unless scope.has_index_actions?

    if configured(:strategy).include?(:offset)
      object(:offset_pagination) do |object|
        object.integer(:current)
        object.integer?(:next, nullable: true)
        object.integer?(:prev, nullable: true)
        object.integer(:total)
        object.integer(:items)
      end
    end

    if configured(:strategy).include?(:cursor)
      object(:cursor_pagination) do |object|
        object.string?(:next, nullable: true)
        object.string?(:prev, nullable: true)
      end
    end
  end
end
```

## Example: Filter Types Builder

Registers filter types based on filterable attributes:

```ruby
class APIBuilder < Adapter::Capability::API::Base
  def build
    return unless scope.filterable?

    scope.filter_types.each do |type|
      object(:"#{type}_filter") do |object|
        object.public_send(type, :eq) if supports_eq?(type)
        object.public_send(type, :neq) if supports_neq?(type)
        object.public_send(type, :gt) if supports_comparison?(type)
        object.public_send(type, :lt) if supports_comparison?(type)
      end
    end
  end

  private

  def supports_eq?(type)
    %i[string integer boolean].include?(type)
  end

  def supports_neq?(type)
    %i[string integer].include?(type)
  end

  def supports_comparison?(type)
    %i[integer decimal date datetime].include?(type)
  end
end
```

#### See also

- [Capability::API::Base reference](/reference/adapter-capability-api-base)
- [Capability::API::Scope reference](/reference/adapter-capability-api-scope)
- [Types](../../../types/introduction.md)
