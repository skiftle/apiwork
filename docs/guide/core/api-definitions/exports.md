---
order: 4
---

# Export Endpoints

Export endpoints serve OpenAPI specs, TypeScript types, and Zod schemas from your API. These are the built-in exports, but `export` works with any registered export generator.

## Enabling Exports

In your API definition:

```ruby
Apiwork::API.define '/api/v1' do
  export :openapi
  export :typescript
  export :zod
end
```

## Generated Endpoints

Each export declaration creates an endpoint at `/.{export_name}`:

| Declaration        | Endpoint                       |
| ------------------ | ------------------------------ |
| `export :openapi`    | `GET /api/v1/.openapi`    |
| `export :typescript` | `GET /api/v1/.typescript` |
| `export :zod`        | `GET /api/v1/.zod`        |

A custom export registered as `:protobuf` becomes `GET /api/v1/.protobuf`.

## Custom Paths

Override the default path using a block:

```ruby
export :openapi do
  path '/openapi.json'
end

export :typescript do
  path '/types.ts'
end

export :zod do
  path '/schemas.ts'
end
```

Now served at:

- `GET /api/v1/openapi.json`
- `GET /api/v1/types.ts`
- `GET /api/v1/schemas.ts`

## Key Format

Exports inherit `key_format` from the API definition by default:

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel  # All exports will use camelCase

  export :openapi      # Inherits :camel
  export :typescript   # Inherits :camel
  export :zod          # Inherits :camel
end
```

Override per export using a block:

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel

  export :openapi      # Inherits :camel
  export :zod do
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
GET /api/v1/.openapi?key_format=camel
```

::: info Runtime snake_case, exports camelCase
Keep `key_format` at `:keep` for runtime and override per export:

```ruby
Apiwork::API.define '/api/v1' do
  # Omit key_format to use :keep (default)

  export :typescript do
    key_format :camel  # Generated types use camelCase
  end
end
```
:::

## Export Formats

Each format has its own guide:

- [OpenAPI](../exports/openapi.md)
- [TypeScript](../exports/typescript.md)
- [Zod](../exports/zod.md)

## Programmatic Generation

Generate exports from Ruby:

```ruby
Apiwork::Export.generate(:openapi, '/api/v1')
Apiwork::Export.generate(:typescript, '/api/v1')
Apiwork::Export.generate(:zod, '/api/v1')

# With options
Apiwork::Export.generate(:typescript, '/api/v1', key_format: :camel)
```

::: tip When to use programmatic generation
- CI pipelines that commit generated types
- Static file generation for CDN hosting
- Build processes that bundle exports with frontend code
:::

## Custom Exports

You can create your own export generators. See [Custom Exports](../../advanced/custom-exports.md) for the full guide.

#### See also

- [Export reference](../../../reference/export.md) — programmatic export generation API
