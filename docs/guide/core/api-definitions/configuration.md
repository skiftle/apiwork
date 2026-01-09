---
order: 3
---

# Configuration

API-level configuration applies to all resources within the API.

## Info Block

Metadata for documentation and export generation:

```ruby
Apiwork::API.define '/api/v1' do
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
  deprecated
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

  server do
    url 'https://api.example.com'
    description 'Production'
  end
  server do
    url 'https://staging-api.example.com'
    description 'Staging'
  end

  tags 'Posts', 'Comments', 'Users'
end
```

## Raises

Declare which errors all endpoints can raise:

```ruby
Apiwork::API.define '/api/v1' do
  raises :bad_request, :unauthorized, :forbidden, :not_found, :internal_server_error
end
```

These appear in generated OpenAPI exports as possible responses for all endpoints.

## Key Format

Control how JSON keys are transformed:

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel
end
```

Options:

- `:keep` - no transformation (default)
- `:camel` - `created_at` becomes `createdAt` in responses, `createdAt` becomes `created_at` in requests
- `:kebab` - `created_at` becomes `created-at` (JSON:API style)
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

This is usually desired. To preserve original keys in a JSON column, use `encode:`:

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

## Path Format

Control how URL path segments are formatted:

```ruby
Apiwork::API.define '/api/v1' do
  path_format :kebab

  resources :recurring_invoices
  # Routes: GET /api/v1/recurring-invoices
end
```

Options:

| Option            | Example Input         | URL Path             |
| ----------------- | --------------------- | -------------------- |
| `:keep` (default) | `:recurring_invoices` | `recurring_invoices` |
| `:kebab`          | `:recurring_invoices` | `recurring-invoices` |
| `:camel`          | `:recurring_invoices` | `recurringInvoices`  |
| `:underscore`     | `:recurring_invoices` | `recurring_invoices` |

::: info Path Segments Only
`path_format` transforms resource and action names. It does not affect:

- Route parameters (`:id`, `:post_id`)
- Query parameters
- Request/response payload keys (use [key_format](#key-format) for those)
  :::

### Custom Member and Collection Actions

Custom actions are also transformed:

```ruby
Apiwork::API.define '/api/v1' do
  path_format :kebab

  resources :invoices do
    member do
      patch :mark_as_paid      # PATCH /invoices/:id/mark-as-paid
    end
    collection do
      get :past_due            # GET /invoices/past-due
    end
  end
end
```

### Explicit Path Override

Bypass formatting with explicit `path:`:

```ruby
resources :recurring_invoices, path: 'invoices'
# Routes: GET /api/v1/invoices (ignores path_format)
```

### With Key Format

`path_format` and `key_format` are independent:

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel        # Payload keys: createdAt
  path_format :kebab       # URL paths: recurring-invoices
end
```

## Adapter Configuration

Configure the built-in adapter:

```ruby
Apiwork::API.define '/api/v1' do
  adapter do
    pagination do
      default_size 20
      max_size 100
    end
  end
end
```

[Execution Engine](../execution-engine/introduction.md) covers pagination strategies, filtering operators, and sorting options.

## Export Endpoints

Enable generated export endpoints:

```ruby
Apiwork::API.define '/api/v1' do
  export :openapi
  export :zod
  export :typescript
end
```

Generates endpoints at `/.openapi`, `/.zod`, `/.typescript`.

Custom paths:

```ruby
export :openapi do
  path '/openapi.json'
end
```

[Export Generation](../exports/introduction.md) covers format options, custom paths, and per-export configuration.

## Global Types and Enums

Define types and anums available to all contracts in this API:

```ruby
Apiwork::API.define '/api/v1' do
  object :address do
    param :street, type: :string
    param :city, type: :string
    param :country, type: :string
  end

  enum :status, values: %w[pending active archived]
end
```

[Type System](../type-system/introduction.md) covers types, enums, and scoping rules.

#### See also

- [API::Base reference](../../../reference/api-base.md) — all configuration methods and options
