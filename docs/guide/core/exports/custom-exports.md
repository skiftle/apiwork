---
order: 6
---

# Custom Exports

Create your own exports.

## Creating a Custom Export

```ruby
class MyExport < Apiwork::Export::Base
  export_name :my_export
  output :hash
  file_extension '.json'

  def generate
    # Build and return your export
    {
      resources: build_resources,
      types: build_types
    }
  end

  private

  def build_resources
    result = {}
    api.resources.each do |name, resource|
      result[name] = process_resource(resource)
    end
    result
  end

  def build_types
    types.transform_values { |t| process_type(t) }
  end
end
```

## Output Type

Set the output type for your export:

```ruby
output :hash    # Returns a Hash — serialized to JSON or YAML by the framework
output :string  # Returns a String — written as-is (use for TypeScript, Zod, etc.)
```

For `:hash` exports, the framework handles serialization to JSON or YAML based on the requested format. For `:string` exports, set `file_extension` to control the file type (e.g., `.ts`).

## Base Class Helpers

The `Apiwork::Export::Base` class provides:

### API Access

```ruby
api            # Full introspection data (Introspection::API)
types          # All registered types
enums          # All registered enums
metadata       # API metadata (info, etc.)
path           # API mount path
```

The `api` object contains the full introspection output. For details on the format, field types, and properties, see [Introspection](../introspection/).

### Iteration

```ruby
api.resources.each_value do |resource|
  resource.actions.each_value do |action|
    # Called for each action in a resource
  end
end
```

### Options

```ruby
option :my_option, type: :string, default: 'value'

# Access in generate:
my_option  # Returns the configured value
```

## Registering Your Export

Register your export so Apiwork can find it:

```ruby
# config/initializers/apiwork.rb
Apiwork::Export.register(MyExport)
```

## Using Your Export

Once registered, enable it in your [API definition](/guide/core/api-definitions/introduction):

```ruby
Apiwork::API.define '/api/v1' do
  export :my_export
end
```

With options:

```ruby
Apiwork::API.define '/api/v1' do
  export :my_export do
    key_format :camel
  end
end
```

Served at `GET /api/v1/.my_export`.

With query parameters (any defined option works):

```
GET /api/v1/.my_export?key_format=camel
GET /api/v1/.my_export?locale=sv
GET /api/v1/.my_export?include_deprecated=true
```

Generate to file (use uppercase ENV vars):

```bash
rake apiwork:export:write EXPORT_NAME=my_export OUTPUT=public/exports
rake apiwork:export:write EXPORT_NAME=my_export KEY_FORMAT=camel OUTPUT=public/exports
rake apiwork:export:write EXPORT_NAME=my_export INCLUDE_DEPRECATED=true OUTPUT=public/exports
```

## Defining Options

Make your export configurable with `option`:

```ruby
class MyExport < Apiwork::Export::Base
  export_name :my_export

  option :include_deprecated, type: :boolean, default: false
  option :max_depth, type: :integer, default: 3
end
```

::: tip Built-in Options
`key_format` and `locale` are always available — you don't need to define them. They're inherited from the API definition and can be overridden via query params or ENV vars.
:::

### Option Types

| Type       | Description                |
| ---------- | -------------------------- |
| `:string`  | String value               |
| `:integer` | Integer value              |
| `:symbol`  | Symbol value               |
| `:boolean` | Boolean value              |
| `:hash`    | Nested options (use block) |

### Accessing Options

Options are available as methods in your `generate` method:

```ruby
def generate
  return {} unless include_deprecated || has_content?
  # ...
end
```
