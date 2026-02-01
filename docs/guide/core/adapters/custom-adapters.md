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
def register_api(api_class)
  registry = api_class.representation_registry

  # Register pagination types if any resource has index actions
  if api_class.root_resource.has_index_actions?
    api_class.object :my_pagination do |o|
      o.integer :page
      o.integer :total
    end
  end

  # Register filter types based on representation attributes
  if registry.filterable?
    registry.filter_types.each do |type|
      api_class.object :"#{type}_filter" do |o|
        o.param :eq, type: type, optional: true
        o.param :contains, type: type, optional: true
      end
    end
  end
end
```

The `api_class` provides type registration methods:
- `type(name, &block)` — Define a type
- `enum(name, values:)` — Define an enum
- `union(name, &block)` — Define a union type
- `object(name, &block)` — Define an object type

The `api_class.representation_registry` provides:
- `filter_types` — Array of attribute types that are filterable
- `nullable_filter_types` — Array of filterable types that can be null
- `sortable?` — Whether any representation has sortable attributes
- `filterable?` — Whether any representation has filterable attributes
- `options_for(capability, key)` — Get configured options across representations

The `api_class.root_resource` provides:
- `has_index_actions?` — Whether any resource has an index action

### register_contract

Called for each contract. Use this to register types specific to that contract:

```ruby
def register_contract(contract_class, representation_class, actions)
  # actions is a Hash of API::Resource::Action objects
  # Each action has: name, method, type, member?, collection?, crud?

  actions.each do |action_name, action|
    action_definition = contract_class.action(action_name)

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
end
```

The `actions` hash contains `API::Resource::Action` objects with:
- `name` — Action name (:index, :show, :create, :update, :destroy, or custom)
- `method` — HTTP method (:get, :post, :patch, :delete)
- `type` — Action type (:member or :collection)
- `member?` — True if action operates on a single resource
- `collection?` — True if action operates on a collection
- `crud?` — True if this is a standard CRUD action

### ActionDefinition

`action` returns an `ActionDefinition` for configuring request/response:

```ruby
contract_class.action :index do
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
