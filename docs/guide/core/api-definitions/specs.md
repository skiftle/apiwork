---
order: 4
---

# Spec Endpoints

Apiwork can expose your API specifications directly from your Rails application. Enable spec endpoints to let clients fetch OpenAPI documents, TypeScript types, and Zod schemas.

## Enabling Specs

In your API definition:

```ruby
Apiwork::API.define '/api/v1' do
  spec :openapi
  spec :typescript
  spec :zod
end
```

## Generated Endpoints

Each spec declaration creates an endpoint:

| Declaration        | Endpoint                       |
| ------------------ | ------------------------------ |
| `spec :openapi`    | `GET /api/v1/.spec/openapi`    |
| `spec :typescript` | `GET /api/v1/.spec/typescript` |
| `spec :zod`        | `GET /api/v1/.spec/zod`        |

## Custom Paths

Override the default path using a block:

```ruby
spec :openapi do
  path '/openapi.json'
end

spec :typescript do
  path '/types.ts'
end

spec :zod do
  path '/schemas.ts'
end
```

Now served at:

- `GET /api/v1/openapi.json`
- `GET /api/v1/types.ts`
- `GET /api/v1/schemas.ts`

## Key Format

Specs inherit `key_format` from the API definition by default:

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel  # All specs will use camelCase

  spec :openapi      # Inherits :camel
  spec :typescript   # Inherits :camel
  spec :zod          # Inherits :camel
end
```

Override per spec using a block:

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel

  spec :openapi      # Inherits :camel
  spec :zod do
    key_format :keep # Override to no transformation
  end
end
```

Options:

- `:keep` — No transformation (default)
- `:camel` — `created_at` becomes `createdAt`
- `:kebab` — `created_at` becomes `created-at` (JSON:API style)
- `:underscore` — All keys use snake_case

Query parameter override:

```http
GET /api/v1/.spec/openapi?key_format=camel
```

::: info Keeping Rails conventions while generating camelCase specs
If you prefer Rails conventions at runtime (snake_case keys), you can keep the API's `key_format` at `:keep` or `:underscore` and override only for specs. This is useful when your frontend transforms keys to camelCase anyway.

```ruby
Apiwork::API.define '/api/v1' do
  # Omit key_format to use :keep (default)

  spec :typescript do
    key_format :camel  # Generated types use camelCase
  end
end
```
:::

## Spec Generation

For detailed information about each spec format:

- [OpenAPI](../specs/openapi.md)
- [TypeScript](../specs/typescript.md)
- [Zod](../specs/zod.md)

## Programmatic Generation

Generate specs directly from Ruby code:

```ruby
Apiwork::Spec.generate(:openapi, '/api/v1')
Apiwork::Spec.generate(:typescript, '/api/v1')
Apiwork::Spec.generate(:zod, '/api/v1')

# With options
Apiwork::Spec.generate(:typescript, '/api/v1', key_format: :camel)
```

::: tip When to use programmatic generation
- CI pipelines that commit generated types
- Static file generation for CDN hosting
- Build processes that bundle specs with frontend code
:::
