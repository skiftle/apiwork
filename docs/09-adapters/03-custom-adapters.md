# Custom Adapters

Create your own adapter for custom data sources.

## Creating an Adapter

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

```ruby
Apiwork::API.draw '/api/v1' do
  adapter :myadapter do
    my_option 'custom_value'
  end
end
```
