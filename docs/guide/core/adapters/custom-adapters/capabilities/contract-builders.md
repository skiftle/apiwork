---
order: 5
---

# Contract Builders

Contract builders run once per contract-representation pair. They register types specific to that contract and modify [action](../../../contracts/actions.md) definitions. Contract builders inherit from [`Adapter::Capability::Contract::Base`](/reference/apiwork/adapter/capability/contract/base).

```ruby
class ContractBuilder < Adapter::Capability::Contract::Base
  def build
    return unless scope.action?(:index)

    object(:page) do |object|
      object.integer?(:number, min: 1)
      object.integer?(:size, max: options.max_size, min: 1)
    end

    action(:index) do |action|
      action.request do |request|
        request.query do |query|
          query.reference?(:page)
        end
      end
    end
  end
end
```

## Registering Contract Builders

In your capability:

```ruby
class Pagination < Adapter::Capability::Base
  capability_name :pagination

  contract_builder ContractBuilder
end
```

Or with an inline block:

```ruby
contract_builder do
  # ...
end
```

## Available Methods

### Type Registration

| Method | Purpose |
|--------|---------|
| `object(name, &block)` | Define an object type scoped to this contract |
| `enum(name, values:)` | Define an enum type |
| `union(name, &block)` | Define a union type |
| `import(type_name, from:)` | Import a type from another contract |
| `type?(name)` | Check if type exists |
| `scoped_type_name(name)` | Get the fully scoped type name |

### Action Modification

The `action(name)` method returns the action definition for modification:

```ruby
action(:index) do |action|
  action.request do |request|
    request.query do |query|
      query.reference?(:filter)
    end
  end
end
```

### Scope Queries

The [`scope`](/reference/apiwork/adapter/capability/contract/scope) attribute provides access to the [representation](../../../representations/) and actions:

| Method | Description |
|--------|-------------|
| `scope.action?(name)` | Whether the action exists |
| `scope.actions` | All actions for this contract |
| `scope.collection_actions` | Actions that return collections |
| `scope.member_actions` | Actions that return single records |
| `scope.crud_actions` | Standard CRUD actions only |
| `scope.filterable_attributes` | Attributes with `filterable: true` |
| `scope.sortable_attributes` | Attributes with `sortable: true` |
| `scope.writable_attributes` | Attributes with `writable: true` |
| `scope.attributes` | All attributes |
| `scope.associations` | All associations |
| `scope.root_key` | Root key for responses |

### Options Access

The `options` attribute provides merged capability configuration (capability defaults + API config + representation config):

```ruby
def build
  object(:page) do |object|
    object.integer?(:size, max: options.max_size)
  end
end
```

### Representation Access

The `representation_class` attribute provides direct access to the representation class.

## Example: Filtering Contract Builder

Registers filter types based on filterable attributes:

```ruby
class ContractBuilder < Adapter::Capability::Contract::Base
  def build
    return unless scope.action?(:index)
    return if scope.filterable_attributes.empty?

    build_filter_type
    add_filter_to_index
  end

  private

  def build_filter_type
    filterable = scope.filterable_attributes

    object(:filter) do |object|
      filterable.each do |attribute|
        filter_type = :"#{attribute.type}_filter"
        object.reference?(attribute.name, to: filter_type)
      end
    end
  end

  def add_filter_to_index
    action(:index) do |action|
      action.request do |request|
        request.query do |query|
          query.reference?(:filter)
        end
      end
    end
  end
end
```

## Example: Sorting Contract Builder

Registers sort enum based on sortable attributes:

```ruby
class ContractBuilder < Adapter::Capability::Contract::Base
  def build
    return unless scope.action?(:index)
    return if scope.sortable_attributes.empty?

    build_sort_type
    add_sort_to_index
  end

  private

  def build_sort_type
    sortable = scope.sortable_attributes

    object(:sort) do |object|
      sortable.each do |attribute|
        object.reference?(attribute.name, to: :sort_direction)
      end
    end
  end

  def add_sort_to_index
    action(:index) do |action|
      action.request do |request|
        request.query do |query|
          query.reference?(:sort)
        end
      end
    end
  end
end
```

#### See also

- [Capability::Contract::Base reference](/reference/apiwork/adapter/capability/contract/base)
- [Capability::Contract::Scope reference](/reference/apiwork/adapter/capability/contract/scope)
- [Contract Actions](../../../contracts/actions.md)
- [Representations](../../../representations/)
