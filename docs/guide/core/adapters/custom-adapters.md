---
order: 3
---

# Custom Adapters

The [standard adapter](./standard-adapter/introduction.md) handles filtering, sorting, pagination, and serialization for ActiveRecord models. Custom adapters let you change *how* these are done — different pagination formats, custom response structures, specialized filtering logic, or alternative serialization strategies.

::: info
Representations require ActiveRecord models for type inference and association discovery. Custom adapters customize behavior, not the underlying data layer.
:::

## Creating an Adapter

Here's the basic structure:

```ruby
class MyAdapter < Apiwork::Adapter::Base
  adapter_name :my_adapter

  option :my_option, type: :string, default: 'value'

  def render_collection(collection, representation_class, action_data)
    # Load and transform collection
    # Return hash with data and metadata
    {
      representation_class.root_key.plural => serialized_data,
      pagination: pagination_metadata
    }
  end

  def render_record(record, representation_class, action_data)
    # Load and transform single record
    {
      representation_class.root_key.singular => serialized_data
    }
  end

  def render_error(issues, action_data)
    # Format error response
    { errors: issues.map(&:to_h) }
  end
end
```

## Required Methods

You need to implement three methods:

### render_collection

Called for index and collection actions:

```ruby
def render_collection(collection, representation_class, action_data)
  # collection - The base query/collection
  # representation_class - The representation class for serialization
  # action_data - Request context (query params, etc.)
end
```

### render_record

Called for show, create, update, destroy:

```ruby
def render_record(record, representation_class, action_data)
  # record - The record being serialized
  # representation_class - The representation class for serialization
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

## Type Registration

These hooks let your adapter register types based on schema metadata. This is how the built-in adapter automatically generates filter types, pagination types, and response shapes from your representations.

### register_api

Called once when the API is loaded. Use this to register global types shared across all contracts:

```ruby
def register_api(registrar, schema_data)
  # Register pagination types
  registrar.type :my_pagination do
    integer :page
    integer :total
  end

  # Register error type
  registrar.type :error do
    string :code
    string :message
  end

  # Register filter types based on schema attributes
  if schema_data.filterable_types.include?(:string)
    registrar.type :string_filter do
      string? :eq
      string? :contains
    end
  end
end
```

The `registrar` provides:
- `type(name, &block)` — Define a type
- `enum(name, values:)` — Define an enum
- `union(name, &block)` — Define a union type

The `schema_data` provides information about all schemas in the API:
- `filterable_types` — Array of attribute types that are filterable
- `nullable_filterable_types` — Array of filterable types that can be null
- `sortable?` — Whether any schema has sortable attributes
- `has_resources?` — Whether the API has any resources
- `has_index_actions?` — Whether any resource has an index action
- `uses_offset_pagination?` — Whether any schema uses offset pagination
- `uses_cursor_pagination?` — Whether any schema uses cursor pagination

### register_contract

Called for each contract. Use this to register types specific to that contract:

```ruby
def register_contract(registrar, representation_class, actions)
  # Register enums from representation attributes
  representation_class.attribute_definitions.each do |name, attr|
    if attr.enum&.any?
      registrar.enum(name, values: attr.enum)
    end
  end

  # Define action contracts
  actions.each do |action_name, action_metadata|
    # Get or create action definition, then work with it directly
    action_definition = registrar.action(action_name)

    # Build request/response based on action type
    case action_name
    when :index
      action_definition.request do
        query do
          integer? :page
        end
      end
      action_definition.response do
        body do
          array :items do
            reference :item
          end
        end
      end
    when :show
      action_definition.response do
        body do
          object :item
        end
      end
    end
  end

  # Register response type
  root_key = representation_class.root_key.singular.to_sym
  registrar.type(root_key, representation_class: representation_class) do
    representation_class.attribute_definitions.each do |name, attr|
      send(attr.type, name, nullable: attr.nullable?)
    end
  end
end
```

The `registrar` provides:
- `type(name, &block)` — Define a type
- `enum(name, values:)` — Define an enum
- `union(name, &block)` — Define a union type
- `action(name, &block)` — Define an action (returns `ActionDefinition`)
- `import(contract, as:)` — Import types from another contract

### ActionDefinition

`action` returns an `ActionDefinition` for configuring request/response:

```ruby
registrar.action :index do
  request do
    query { integer? :page }
  end
  response do
    body do
      array :items do
        reference :item
      end
    end
  end
end
```

Or capture and build incrementally:

```ruby
action = registrar.action(:index)
action.request do
  query do
    integer :page
  end
end
action.response do
  body do
    array :items do
      reference :item
    end
  end
end
```

`ActionDefinition` provides:
- `request(&block)` — Define query params and body (returns `RequestDefinition`)
- `response(&block)` — Define response body (returns `ResponseDefinition`)
- `summary(text)` — Set operation summary
- `description(text)` — Set operation description
- `tags(*names)` — Set operation tags
- `deprecated(bool)` — Mark as deprecated
- `raises(*error_codes)` — Declare possible error codes

The `representation_class` is the representation associated with the contract, giving you access to:
- `attribute_definitions` — All attributes with their types, options, and constraints
- `association_definitions` — All associations
- `root_key` — The root key for responses (singular/plural forms)

## Registering Your Adapter

Register your adapter so Apiwork can find it:

```ruby
# config/initializers/apiwork.rb
Apiwork::Adapter.register(MyAdapter)
```

## Using Your Adapter

Once registered, use it in your [API definition](/guide/core/api-definitions/introduction):

```ruby
Apiwork::API.define '/api/v1' do
  adapter :my_adapter
end
```

With options:

```ruby
Apiwork::API.define '/api/v1' do
  adapter :my_adapter do
    my_option 'custom_value'
  end
end
```

## Defining Options

Make your adapter configurable with `option`:

```ruby
class MyAdapter < Apiwork::Adapter::Base
  adapter_name :my_adapter

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

Read option values with `adapter_config`:

```ruby
def render_collection(collection, representation_class, action_data)
  timeout = representation_class.adapter_config.timeout
  cache_enabled = representation_class.adapter_config.cache.enabled
  # ...
end
```

For nested options, chain method calls.
