---
order: 3
---

# Custom Specs

Create your own spec generators.

## Creating a Custom Spec

```ruby
class MySpec < Apiwork::Spec::Base
  identifier :myspec
  content_type 'application/json'

  option :key_transform, type: :symbol, default: :keep

  def self.file_extension
    '.json'
  end

  def generate
    # Build and return your spec
    {
      resources: build_resources,
      types: build_types
    }
  end

  private

  def build_resources
    result = {}
    each_resource do |name, data, parent|
      result[name] = process_resource(data)
    end
    result
  end

  def build_types
    types.transform_values { |t| process_type(t) }
  end
end
```

## Base Class Helpers

The `Apiwork::Spec::Base` class provides:

### Data Access

```ruby
@data          # Full introspection data
types          # All registered types
enums          # All registered enums
metadata       # API metadata (info, etc.)
path           # API mount path
```

### Iteration

```ruby
each_resource do |resource_name, resource_data, parent_path|
  # Called for each resource
end

each_action(resource_data) do |action_name, action_data|
  # Called for each action in a resource
end
```

### Options

```ruby
option :my_option, type: :string, default: 'value'

# Access in generate:
my_option  # Returns the configured value
```

## Registering

The spec is automatically available when the class is loaded. Use in your API:

```ruby
Apiwork::API.draw '/api/v1' do
  spec :myspec
end
```

Served at `GET /api/v1/.spec/myspec`.
