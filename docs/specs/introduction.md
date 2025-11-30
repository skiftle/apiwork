---
order: 1
---

# Spec Generation

Apiwork generates API specifications from your definitions.

## Available Formats

- **OpenAPI** - OpenAPI 3.1 specification
- **TypeScript** - TypeScript type definitions
- **Zod** - Zod validation schemas

## Enabling Specs

In your API definition:

```ruby
Apiwork::API.draw '/api/v1' do
  spec :openapi
  spec :typescript
  spec :zod
end
```

## Endpoints

Specs are served at `/.spec/{format}`:

| Format | Endpoint |
|--------|----------|
| OpenAPI | `GET /api/v1/.spec/openapi` |
| TypeScript | `GET /api/v1/.spec/typescript` |
| Zod | `GET /api/v1/.spec/zod` |

## Custom Path

```ruby
spec :openapi, path: '/openapi.json'
```

Now served at `GET /api/v1/openapi.json`.

## Key Transformation

Transform JSON keys in the output:

```ruby
spec :openapi, key_transform: :camel
```

Options:
- `:keep` - No transformation (default)
- `:camel` - `created_at` becomes `createdAt`
- `:underscore` - All keys use snake_case

## Programmatic Generation

```ruby
# Generate OpenAPI spec
Apiwork::Spec::Openapi.generate(path: '/api/v1')

# Generate TypeScript
Apiwork::Spec::Typescript.generate(path: '/api/v1')

# Generate Zod
Apiwork::Spec::Zod.generate(path: '/api/v1')
```
