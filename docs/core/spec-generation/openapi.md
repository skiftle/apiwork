---
order: 2
---

# OpenAPI

Generates OpenAPI 3.1 specifications.

## Configuration

```ruby
Apiwork::API.draw '/api/v1' do
  spec :openapi
end
```

## Options

```ruby
spec :openapi,
     path: '/openapi.json',      # Custom endpoint path
     key_format: :camel       # Transform keys to camelCase
```

## API Metadata

Provide metadata in the `info` block:

```ruby
Apiwork::API.draw '/api/v1' do
  info do
    title 'My API'
    version '1.0.0'
    description 'Public API'
  end

  spec :openapi
end
```

## Output Structure

```json
{
  "openapi": "3.1.0",
  "info": {
    "title": "My API",
    "version": "1.0.0",
    "description": "Public API"
  },
  "paths": {
    "/posts": {
      "get": { ... },
      "post": { ... }
    },
    "/posts/{id}": {
      "get": { ... },
      "patch": { ... },
      "delete": { ... }
    }
  },
  "components": {
    "schemas": { ... }
  }
}
```

## Error Codes

Document possible error responses:

```ruby
action :show do
  error_codes :not_found, :forbidden
end
```

Appears in the OpenAPI spec as possible responses.

See [Contracts: Actions](../contracts/actions.md#metadata) for how to add metadata like `summary`, `description`, and `tags`.
