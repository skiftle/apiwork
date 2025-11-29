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
     key_transform: :camel       # Transform keys to camelCase
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

## Action Metadata

Add OpenAPI-specific metadata:

```ruby
resources :posts do
  describe :publish,
    summary: "Publish a post",
    description: "Changes status from draft to published",
    tags: ["Publishing"],
    operation_id: "publishPost"

  member do
    patch :publish
  end
end
```

## Error Codes

Document possible error responses:

```ruby
action :show do
  error_codes 404, 403
end
```

Appears in the OpenAPI spec as possible responses.
