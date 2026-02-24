---
order: 3
---

# OpenAPI

The OpenAPI export generates OpenAPI 3.1 specifications.

## Configuration

```ruby
Apiwork::API.define '/api/v1' do
  export :openapi
end
```

## Options

```ruby
export :openapi do
  path '/openapi.json'      # Custom endpoint path
  key_format :camel         # Transform keys to camelCase
end
```

| Option    | Values         | Default |
| --------- | -------------- | ------- |
| `version` | `3.1.0`        | `3.1.0` |
| `format`  | `json`, `yaml` | `json`  |

## API Metadata

Metadata is provided in the `info` block:

```ruby
Apiwork::API.define '/api/v1' do
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

    server do
      url 'https://api.example.com'
      description 'Production'
    end
    server do
      url 'https://staging.example.com'
      description 'Staging'
    end
  end

  export :openapi
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

## Schemas

Named types defined in [Types](../types/types.md) appear in `components/schemas`. This makes the generated export cleaner and more reusable.

Inline types are embedded directly in operations. Named types use `$ref` references:

```json
{
  "components": {
    "schemas": {
      "Address": {
        "type": "object",
        "properties": {
          "street": {
            "type": "string"
          },
          "city": {
            "type": "string"
          }
        }
      }
    }
  }
}
```

## Raises

Possible error responses are documented with `raises`:

```ruby
action :show do
  raises :not_found, :forbidden
end
```

Appears in the OpenAPI export as possible responses.

[Action metadata](../contracts/actions.md#metadata) controls `summary`, `description`, `tags`, and `operation_id` per action.

#### See also

- [Export reference](../../reference/export/base) — programmatic generation API
