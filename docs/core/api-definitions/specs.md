---
order: 4
---

# Spec Endpoints

Apiwork can expose your API specifications directly from your Rails application. Enable spec endpoints to let clients fetch OpenAPI documents, TypeScript types, and Zod schemas.

## Enabling Specs

In your API definition:

```ruby
Apiwork::API.draw '/api/v1' do
  spec :openapi
  spec :typescript
  spec :zod
end
```

## Generated Endpoints

Each spec declaration creates an endpoint:

| Declaration | Endpoint |
|-------------|----------|
| `spec :openapi` | `GET /api/v1/.spec/openapi` |
| `spec :typescript` | `GET /api/v1/.spec/typescript` |
| `spec :zod` | `GET /api/v1/.spec/zod` |

## Custom Paths

Override the default path:

```ruby
spec :openapi, path: '/openapi.json'
spec :typescript, path: '/types.ts'
spec :zod, path: '/schemas.ts'
```

Now served at:
- `GET /api/v1/openapi.json`
- `GET /api/v1/types.ts`
- `GET /api/v1/schemas.ts`

## Key Format

Specs inherit `key_format` from the API definition by default:

```ruby
Apiwork::API.draw '/api/v1' do
  key_format :camel  # All specs will use camelCase

  spec :openapi      # Inherits :camel
  spec :typescript   # Inherits :camel
  spec :zod          # Inherits :camel
end
```

Override per spec using a block:

```ruby
Apiwork::API.draw '/api/v1' do
  key_format :camel

  spec :openapi      # Inherits :camel
  spec :zod do
    key_format :keep # Override to snake_case
  end
end
```

Options:
- `:keep` — No transformation (default)
- `:camel` — `created_at` becomes `createdAt`
- `:underscore` — All keys use snake_case

Query parameter override:

```
GET /api/v1/.spec/openapi?key_format=camel
```

## Spec Generation

For detailed information about each spec format:

- [OpenAPI](../spec-generation/openapi.md)
- [TypeScript](../spec-generation/typescript.md)
- [Zod](../spec-generation/zod.md)

## Programmatic Generation

Generate specs without HTTP endpoints:

```ruby
# Generate OpenAPI spec
Apiwork::Spec::Openapi.generate(path: '/api/v1')

# Generate TypeScript
Apiwork::Spec::Typescript.generate(path: '/api/v1')

# Generate Zod
Apiwork::Spec::Zod.generate(path: '/api/v1')
```

Useful for CI pipelines, static file generation, or build processes.
