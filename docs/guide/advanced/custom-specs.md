---
order: 3
---

# Custom Specs

Create your own spec generators.

## Creating a Custom Spec

```ruby
class MySpec < Apiwork::Spec::Base
  identifier :my_spec
  content_type 'application/json'

  option :key_format, type: :symbol, default: :keep

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

The `@data` object contains the full introspection output. For details on the format, field types, and properties, see [Introspection](./introspection.md#field-types).

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

## Registering Your Spec

Register your spec so Apiwork can find it:

```ruby
# config/initializers/apiwork.rb
Apiwork::Spec.register(MySpec)
```

## Using Your Spec

Once registered, enable it in your [API definition](/guide/core/api-definitions/introduction):

```ruby
Apiwork::API.define '/api/v1' do
  spec :my_spec
end
```

With options:

```ruby
Apiwork::API.define '/api/v1' do
  spec :my_spec do
    key_format :camel
  end
end
```

Served at `GET /api/v1/.spec/my_spec`.

With query parameters:

```
GET /api/v1/.spec/my_spec?key_format=camel
GET /api/v1/.spec/my_spec?locale=sv
```

Generate to file:

```bash
rake apiwork:spec:write IDENTIFIER=my_spec OUTPUT=public/specs
rake apiwork:spec:write IDENTIFIER=my_spec KEY_FORMAT=camel OUTPUT=public/specs
```

## Defining Options

Make your spec configurable with `option`:

```ruby
class MySpec < Apiwork::Spec::Base
  identifier :my_spec

  option :key_format, type: :symbol, default: :keep
  option :include_deprecated, type: :boolean, default: false
end
```

### Option Types

| Type | Description |
|------|-------------|
| `:string` | String value |
| `:integer` | Integer value |
| `:symbol` | Symbol value |
| `:boolean` | Boolean value |
| `:hash` | Nested options (use block) |

### Accessing Options

Options are available as methods in your `generate` method:

```ruby
def generate
  format = key_format
  include_deprecated = include_deprecated
  # ...
end
```
