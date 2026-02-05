---
order: 2
---

# Options

Capabilities can define configuration options that control their behavior. Options cascade from API definitions to representations, allowing global defaults with per-representation overrides.

## Defining Options

Use the `option` method to define configuration:

```ruby
class Pagination < Adapter::Capability::Base
  capability_name :pagination

  option :strategy, type: :symbol, default: :offset, enum: %i[offset cursor]
  option :default_size, type: :integer, default: 20
  option :max_size, type: :integer, default: 100
end
```

### Option Parameters

| Parameter | Description |
|-----------|-------------|
| `name` | Option name (Symbol) |
| `type` | `:symbol`, `:string`, `:integer`, `:boolean`, or `:hash` |
| `default` | Default value |
| `enum` | Allowed values (validates input) |

### Nested Options

Use `type: :hash` with a block for deeper nesting:

```ruby
class Filtering < Adapter::Capability::Base
  capability_name :filtering

  option :case_sensitive, type: :boolean, default: false
  option :operators, type: :hash do
    option :string, type: :symbol, default: :all, enum: %i[all basic]
    option :number, type: :symbol, default: :all, enum: %i[all basic]
  end
end
```

## External vs Internal Access

Options are automatically namespaced under `capability_name` in API and representation configuration, but accessed directly inside the capability.

### External: Namespaced Under capability_name

In [API definitions](../../../api-definitions/configuration.md), configure under the capability name:

```ruby
Apiwork::API.define '/api/v1' do
  adapter do
    pagination do          # <- capability_name
      strategy :cursor     # <- options defined in capability
      default_size 50
    end
  end
end
```

In [representations](../../../representations/configuration.md):

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  adapter do
    pagination do          # <- capability_name
      strategy :offset
      default_size 25
    end
  end
end
```

### Internal: Direct Access

Inside the capability (operations, builders), access options directly:

```ruby
class Operation < Adapter::Capability::Operation::Base
  def apply
    strategy = options.strategy       # Direct, not options.pagination.strategy
    page_size = options.default_size
    # ...
  end
end
```

For nested options defined with `type: :hash`:

```ruby
options.operators.string  # Access nested hash options
```

## Configuration Cascading

Options flow from API to representation, with more specific values overriding general ones:

1. **Capability defaults** - defined in the capability class
2. **API configuration** - set in the API definition
3. **Representation configuration** - set per representation

Each level can override individual options. Unspecified options inherit from the previous level.

## Example: Configurable Filtering

Capability definition:

```ruby
class Filtering < Adapter::Capability::Base
  capability_name :filtering

  option :case_sensitive, type: :boolean, default: false
  option :operators, type: :hash do
    option :string, type: :symbol, default: :all, enum: %i[all basic]
    option :number, type: :symbol, default: :all, enum: %i[all basic]
  end

  operation Operation
end
```

API configuration:

```ruby
adapter do
  filtering do
    operators do
      string :basic
    end
  end
end
```

Representation override:

```ruby
adapter do
  filtering do
    operators do
      string :all  # Override for this representation only
    end
  end
end
```

Operation access:

```ruby
class Operation < Adapter::Capability::Operation::Base
  def apply
    case_sensitive = options.case_sensitive
    string_operators = options.operators.string
    # Apply filtering based on configuration
  end
end
```

#### See also

- [API Configuration](../../../api-definitions/configuration.md)
- [Representation Configuration](../../../representations/configuration.md)
- [Capability::Base reference](/reference/adapter-capability-base)
