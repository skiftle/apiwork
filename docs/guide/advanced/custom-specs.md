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
  file_extension '.json'

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
data           # Full introspection data
types          # All registered types
enums          # All registered enums
metadata       # API metadata (info, etc.)
path           # API mount path
```

The `data` object contains the full introspection output. For details on the format, field types, and properties, see [Introspection](./introspection.md#field-types).

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

### Key Transformation

The `key_format` option is always available, inherited from the API definition. Use the `transform_key` helper to transform property names consistently:

```ruby
def generate
  each_resource do |name, data, parent|
    data[:fields].each do |field_name, field_data|
      transformed = transform_key(field_name)
      # ...
    end
  end
end
```

`transform_key` applies the current `key_format` setting:

| key_format | Input | Output |
|------------|-------|--------|
| `:keep` | `created_at` | `created_at` |
| `:camel` | `created_at` | `createdAt` |
| `:underscore` | `createdAt` | `created_at` |

::: warning Respect key_format
Always use `transform_key` for property names in your output, as long as it makes sense in your spec. This ensures consistency with other specs and respects the API's configuration.

Need a format beyond `keep`, `camel`, or `underscore`? [Open an issue](https://github.com/skiftle/apiwork/issues) — we're happy to add it.
:::

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

With query parameters (any defined option works):

```
GET /api/v1/.spec/my_spec?key_format=camel
GET /api/v1/.spec/my_spec?locale=sv
GET /api/v1/.spec/my_spec?include_deprecated=true
```

Generate to file (use uppercase ENV vars):

```bash
rake apiwork:spec:write IDENTIFIER=my_spec OUTPUT=public/specs
rake apiwork:spec:write IDENTIFIER=my_spec KEY_FORMAT=camel OUTPUT=public/specs
rake apiwork:spec:write IDENTIFIER=my_spec INCLUDE_DEPRECATED=true OUTPUT=public/specs
```

## Defining Options

Make your spec configurable with `option`:

```ruby
class MySpec < Apiwork::Spec::Base
  identifier :my_spec

  option :include_deprecated, type: :boolean, default: false
  option :max_depth, type: :integer, default: 3
end
```

::: tip Built-in Options
`key_format` and `locale` are always available — you don't need to define them. They're inherited from the API definition and can be overridden via query params or ENV vars.
:::

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
  return {} unless include_deprecated || has_content?
  # ...
end
```
