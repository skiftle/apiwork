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

See [Execution Layer](../../getting-started/execution-layer.md) for all options.

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

See [Spec Generation](../spec-generation/introduction.md) for configuration options.

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

See [Type System](../type-system/introduction.md) for details.

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
