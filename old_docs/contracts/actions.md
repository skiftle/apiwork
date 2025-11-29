# Actions

Actions are the building blocks of contracts. Each one defines inputs and outputs for a controller method.

## Auto-generated actions

When you link a schema, five actions generate automatically:

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema
end
```

This gives you `index`, `show`, `create`, `update`, and `destroy` - all based on your schema's capabilities.

## Defining actions explicitly

Override auto-generated actions or add custom ones:

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema  # Auto-generates standard CRUD

  # Override create
  action :create do
    input do
      param :title, type: :string, required: true
      param :body, type: :string, required: true
      param :tags, type: :array, of: :string
    end
  end

  # Custom action
  action :publish do
    output do
      param :id, type: :integer, required: true
      param :published, type: :boolean, required: true
      param :published_at, type: :datetime, required: true
    end
  end
end
```

## Action blocks

Actions have two sections:

```ruby
action :create do
  input do
    # Request validation
  end

  output do
    # Response validation
  end
end
```

Both sections are optional:

```ruby
# No input, only output
action :show do
  output do
    param :id, type: :integer, required: true
    param :title, type: :string, required: true
  end
end

# Only input
action :create do
  input do
    param :title, type: :string, required: true
  end
end

# Neither (just declares the action exists)
action :publish
```

## Input blocks

Define request parameters:

```ruby
action :create do
  input do
    param :title, type: :string, required: true
    param :body, type: :string, required: true
    param :published, type: :boolean, default: false
  end
end
```

See [Parameters](./parameters.md) for all param options.

## Output blocks

Define response structure:

```ruby
action :show do
  output do
    param :id, type: :integer, required: true
    param :title, type: :string, required: true
    param :body, type: :string, required: true
    param :created_at, type: :datetime, required: true
  end
end
```

Apiwork validates your responses against this schema in development/test.

## Root keys

By default, inputs expect a root key matching the resource name:

```ruby
action :create do
  input do
    param :title, type: :string
  end
end
```

Expects:
```json
{
  "post": {
    "title": "My Post"
  }
}
```

This is configured globally:

```ruby
# config/initializers/apiwork.rb
Apiwork.configure do |config|
  config.require_root_key = false  # Allow flat inputs globally
end
```

Now expects:
```json
{
  "title": "My Post"
}
```

**Note:** Root key behavior can only be configured globally, not per-action.

## Strict mode

By default, actions reject unknown parameters:

```ruby
action :create do
  input do
    param :title, type: :string
  end
end
```

Request:
```json
{
  "post": {
    "title": "My Post",
    "extra": "field"  ← Rejected!
  }
}
```

Returns 422 error with `field_unknown` code.

This is Apiwork's default behavior and cannot be disabled per-action. All contracts are strict by default.

## Member vs collection actions

Actions map to routes:

```ruby
# Member actions - operate on one resource (have :id)
action :show      # GET /posts/:id
action :update    # PATCH /posts/:id
action :destroy   # DELETE /posts/:id
action :publish   # PATCH /posts/:id/publish

# Collection actions - operate on collection (no :id)
action :index        # GET /posts
action :create       # POST /posts
action :bulk_create  # POST /posts/bulk_create
```

No difference in contract syntax - just how they're routed in your API definition.

## Nested parameters

Define nested objects with blocks:

```ruby
action :create do
  input do
    param :title, type: :string, required: true

    param :settings, type: :object, required: true do
      param :theme, type: :string, enum: ['light', 'dark']
      param :notifications, type: :boolean, default: true
    end
  end
end
```

Request:
```json
{
  "post": {
    "title": "My Post",
    "settings": {
      "theme": "dark",
      "notifications": false
    }
  }
}
```

## Array parameters

Define arrays with `of:`:

```ruby
action :create do
  input do
    param :title, type: :string, required: true

    # Simple array
    param :tags, type: :array, of: :string, max_items: 10

    # Array of objects
    param :authors, type: :array, of: :object do
      param :name, type: :string, required: true
      param :email, type: :string
    end
  end
end
```

Request:
```json
{
  "post": {
    "title": "My Post",
    "tags": ["ruby", "rails"],
    "authors": [
      { "name": "Alice", "email": "alice@example.com" },
      { "name": "Bob" }
    ]
  }
}
```

**Available array options:**
- `max_items` - Maximum number of items allowed

**Not supported:**
- ❌ `min_items` - Not implemented

## Custom types

Define reusable types within actions:

```ruby
action :create do
  # Define custom type
  type :address do
    param :street, type: :string, required: true
    param :city, type: :string, required: true
    param :zip, type: :string, required: true
  end

  input do
    param :title, type: :string, required: true
    param :shipping_address, type: :address, required: true
    param :billing_address, type: :address, required: false
  end
end
```

Custom types can also be defined at contract level (outside actions) and reused across multiple actions.

See [Types](./types.md) for more details.

## Inheriting actions

Actions can inherit from base contracts:

```ruby
class BaseContract < Apiwork::Contract::Base
  action :index do
    # Standard index for all resources
  end
end

class Api::V1::PostContract < BaseContract
  schema Api::V1::PostSchema
  # Inherits :index action from BaseContract
end
```

Override inherited actions by redefining them:

```ruby
class Api::V1::PostContract < BaseContract
  schema Api::V1::PostSchema

  # Override inherited index
  action :index do
    input do
      # Custom filtering for posts
    end
  end
end
```

## What Apiwork does NOT support

These action features are **not supported**:

- ❌ `description` / `summary` / `tags` / `deprecated` - Not part of action DSL
- ❌ `root_key false` per-action - Only global configuration
- ❌ `strict false` per-action - All contracts are strict by default
- ❌ `error_output` blocks - Not implemented
- ❌ `controller_action:` option - Action names must match controller method names

## Next steps

- **[Parameters](./parameters.md)** - All parameter options and types
- **[Types](./types.md)** - Custom and union types
- **[Introduction](./introduction.md)** - Back to contracts overview
