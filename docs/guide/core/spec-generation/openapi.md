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
    summary 'Short summary'
    description 'Longer description of the API'
    terms_of_service 'https://example.com/terms'

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
    server url: 'https://staging.example.com', description: 'Staging'
  end

  spec :openapi
end
```

All fields are optional. If `title` is not provided, it defaults to the API path. If `version` is not provided, it defaults to `"1.0.0"`.

## Output Structure

```json
{
  "openapi": "3.1.0",
  "info": {
    "title": "My API",
    "version": "1.0.0",
    "summary": "Short summary",
    "description": "Longer description of the API",
    "termsOfService": "https://example.com/terms",
    "contact": {
      "name": "API Support",
      "email": "api@example.com",
      "url": "https://example.com/support"
    },
    "license": {
      "name": "MIT",
      "url": "https://opensource.org/licenses/MIT"
    }
  },
  "servers": [
    {
      "url": "https://api.example.com",
      "description": "Production"
    },
    {
      "url": "https://staging.example.com",
      "description": "Staging"
    }
  ],
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

## Raises

Document possible error responses:

```ruby
action :show do
  raises :not_found, :forbidden
end
```

Appears in the OpenAPI spec as possible responses.

[Contracts: Actions](../contracts/actions.md#metadata) shows how to add `summary`, `description`, `tags`, and `operation_id` to your actions.
