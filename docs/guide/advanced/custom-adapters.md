---
order: 2
---

# Custom Adapters

Apiwork's built-in adapter covers most use cases, but not all. If you have custom data sources, non-ActiveRecord models, or specialized query logic, you can create your own adapter.

## Creating an Adapter

Here's the basic structure:

```ruby
class MyAdapter < Apiwork::Adapter::Base
  identifier :myadapter

  option :my_option, type: :string, default: 'value'

  def render_collection(collection, schema_class, action_data)
    # Load and transform collection
    # Return hash with data and metadata
    {
      schema_class.root_key.plural => serialized_data,
      pagination: pagination_metadata
    }
  end

  def render_record(record, schema_class, action_data)
    # Load and transform single record
    {
      schema_class.root_key.singular => serialized_data
    }
  end

  def render_error(issues, action_data)
    # Format error response
    { issues: issues.map(&:to_h) }
  end
end
```

## Required Methods

You need to implement three methods:

### render_collection

Called for index and collection actions:

```ruby
def render_collection(collection, schema_class, action_data)
  # collection - The base query/collection
  # schema_class - The schema class for serialization
  # action_data - Request context (query params, etc.)
end
```

### render_record

Called for show, create, update, destroy:

```ruby
def render_record(record, schema_class, action_data)
  # record - The model instance
  # schema_class - The schema class for serialization
  # action_data - Request context
end
```

### render_error

Called when validation fails:

```ruby
def render_error(issues, action_data)
  # issues - Array of Apiwork::Issue objects
  # action_data - Request context
end
```

## Optional Methods

These let you hook into the request/response cycle:

### transform_request

Transform incoming request parameters:

```ruby
def transform_request(hash)
  # Transform and return hash
  hash
end
```

### transform_response

Transform outgoing response:

```ruby
def transform_response(hash)
  # Transform and return hash
  hash
end
```

## Using Your Adapter

Once you've defined your adapter, use it in your API definition:

```ruby
Apiwork::API.draw '/api/v1' do
  adapter :myadapter do
    my_option 'custom_value'
  end
end
```

## Defining Options

Make your adapter configurable with `option`:

```ruby
class MyAdapter < Apiwork::Adapter::Base
  identifier :myadapter

  option :timeout, type: :integer, default: 30
  option :format, type: :symbol, default: :json, enum: %i[json xml]

  option :cache, type: :hash do
    option :enabled, type: :boolean, default: false
    option :ttl, type: :integer, default: 3600
  end
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

Read option values with `resolve_option`:

```ruby
def render_collection(collection, schema_class, action_data)
  timeout = resolve_option(:timeout)
  cache_enabled = resolve_option(:cache, :enabled)
  # ...
end
```

For nested options, pass the parent key first, then the child key.
