---
order: 3
---

# Configuration

API-level configuration applies to all resources within the API.

## Info Block

Metadata for documentation and spec generation:

```ruby
Apiwork::API.draw '/api/v1' do
  info do
    title 'My API'
    version '1.0.0'
    description 'Public API for my application'
  end
end
```

Available options:

```ruby
info do
  title 'My API'
  version '1.0.0'
  description 'Full description'
  summary 'Short summary'
  deprecated true
  internal true
  terms_of_service 'https://example.com/tos'

  contact do
    name 'API Support'
    email 'api@example.com'
    url 'https://example.com/support'
  end

  license do
    name 'MIT'
    url 'https://opensource.org/licenses/MIT'
  end

  server url: 'https://api.example.com', description: 'Production'
  server url: 'https://staging-api.example.com', description: 'Staging'

  tags 'Posts', 'Comments', 'Users'
end
```

## Raises

Declare which errors all endpoints can raise:

```ruby
Apiwork::API.draw '/api/v1' do
  raises :bad_request, :unauthorized, :forbidden, :not_found, :internal_server_error
end
```

These appear in generated OpenAPI specs as possible responses for all endpoints.

## Key Format

Control how JSON keys are transformed:

```ruby
Apiwork::API.draw '/api/v1' do
  key_format :camel
end
```

Options:
- `:keep` - no transformation (default)
- `:camel` - `created_at` → `createdAt` in responses, `createdAt` → `created_at` in requests
- `:underscore` - all keys use snake_case

### JSON Columns

Key transformation applies recursively to the entire response, including data from JSON/JSONB columns:

```ruby
# If a model has a JSON column:
class User < ApplicationRecord
  # metadata is a JSON column storing: { "first_name": "John", "last_login": "2024-01-15" }
end

# With key_format :camel, the response will be:
{
  "id": 1,
  "metadata": {
    "firstName": "John",    # Keys inside JSON are also transformed
    "lastLogin": "2024-01-15"
  }
}
```

This is usually the desired behavior. However, if your JSON column stores data with intentional key formats (like external API responses or user-defined schemas), you may need to preserve the original keys.

To prevent transformation of specific JSON columns, use `encode:` to preserve the original structure:

```ruby
class UserSchema < Apiwork::Schema
  attribute :id
  attribute :metadata, type: :json, encode: ->(v) { v.deep_stringify_keys }
end
```

### Custom Transformation

Key transformation happens via two methods on the API class:

- `transform_request(hash)` — transforms incoming request parameters
- `transform_response(hash)` — transforms outgoing response data

Override these for custom behavior:

```ruby
class Api::V1 < Apiwork::API::Base
  mount '/api/v1'

  def self.transform_response(hash)
    result = super  # Apply key_format transformation first
    result[:_generated_at] = Time.current.iso8601
    result
  end
end
```

To completely replace the default transformation:

```ruby
class Api::V1 < Apiwork::API::Base
  mount '/api/v1'

  def self.transform_request(hash)
    # Custom logic without calling super
    hash.deep_transform_keys { |k| k.to_s.downcase.to_sym }
  end
end
```

For more advanced customization, consider [creating a custom adapter](../../advanced/custom-adapters.md).

## Adapter Configuration

Configure the built-in adapter:

```ruby
Apiwork::API.draw '/api/v1' do
  adapter do
    pagination do
      default_size 20
      max_size 100
    end
  end
end
```

[Execution Layer](../../getting-started/execution-layer.md) covers pagination strategies, filtering operators, and sorting options.

## Spec Endpoints

Enable generated spec endpoints:

```ruby
Apiwork::API.draw '/api/v1' do
  spec :openapi
  spec :zod
  spec :typescript
end
```

Generates endpoints at `/.spec/openapi`, `/.spec/zod`, `/.spec/typescript`.

Custom paths:

```ruby
spec :openapi do
  path '/openapi.json'
end
```

[Spec Generation](../spec-generation/introduction.md) covers format options, custom paths, and per-spec configuration.

## Global Types and Enums

Define types available to all contracts in this API:

```ruby
Apiwork::API.draw '/api/v1' do
  type :address do
    param :street, type: :string
    param :city, type: :string
    param :country, type: :string
  end

  enum :status, values: %w[pending active archived]
end
```

[Type System](../type-system/introduction.md) covers type definitions, enums, unions, and scoping rules.

## with_options

Apply options to multiple resources:

```ruby
Apiwork::API.draw '/api/v1' do
  with_options only: [:index, :show] do
    resources :posts
    resources :comments
    resources :users
  end
end
```

Equivalent to:

```ruby
resources :posts, only: [:index, :show]
resources :comments, only: [:index, :show]
resources :users, only: [:index, :show]
```
