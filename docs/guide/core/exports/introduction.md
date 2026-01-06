---
order: 1
---

# Introduction

Exports describe your API in formats understood by external tools — OpenAPI for documentation, TypeScript for type-safe clients, Zod for runtime validation.

Exports are generated from [introspection](../introspection/introduction.md), the single source of truth for your API structure. They always reflect the current state of your contracts and schemas.

---

## Available Formats

Apiwork creates exports in the following formats:

- **OpenAPI** — OpenAPI 3.1 specification
- **TypeScript** — type definitions for frontend consumers
- **Zod** — runtime validation schemas

## Enabling Exports

Enable whichever formats you need in your [API definition](/guide/core/api-definitions/introduction):

```ruby
Apiwork::API.define '/api/v1' do
  export :openapi
  export :typescript
  export :zod
end
```

## Two Approaches

Apiwork offers two ways to access your generated exports:

| Approach            | Best For    | How It Works                                  |
| ------------------- | ----------- | --------------------------------------------- |
| **Endpoints**       | Development | Exports served dynamically at `/.{format}`    |
| **File Generation** | Production  | Exports written to files via rake task        |

In development, endpoints are convenient — you get instant feedback as you change your API. In production, pre-generated files are faster and can be served statically.

## Endpoints (Development)

Once enabled, exports are served at `/.{format}`:

| Format     | Endpoint                       |
| ---------- | ------------------------------ |
| OpenAPI    | `GET /api/v1/.openapi`    |
| TypeScript | `GET /api/v1/.typescript` |
| Zod        | `GET /api/v1/.zod`        |

These endpoints generate exports on each request — convenient for development, but not ideal for production traffic.

::: tip
During development, you can fetch exports directly from your running server:

```bash
curl http://localhost:3000/api/v1/.typescript > src/api/types.ts
```

:::

## File Generation (Production)

For production, generate exports to files and serve them statically:

```bash
rake apiwork:export:write OUTPUT=public/exports
```

This generates all enabled exports for all APIs:

```text
public/exports/
├── api/
│   └── v1/
│       ├── openapi.json
│       ├── typescript.ts
│       └── zod.ts
```

### Options

| Option        | Description                    | Example          |
| ------------- | ------------------------------ | ---------------- |
| `OUTPUT`      | Output path (required)         | `public/exports` |
| `API_PATH`    | Generate for specific API only | `/api/v1`        |
| `EXPORT_NAME` | Generate specific format only  | `openapi`        |
| `KEY_FORMAT`  | Transform keys                 | `camel`          |
| `LOCALE`      | Use specific locale            | `sv`             |

Examples:

```bash
# All exports for all APIs
rake apiwork:export:write OUTPUT=public/exports

# Only OpenAPI for /api/v1
rake apiwork:export:write API_PATH=/api/v1 EXPORT_NAME=openapi OUTPUT=public/exports

# Single file output
rake apiwork:export:write API_PATH=/api/v1 EXPORT_NAME=openapi OUTPUT=public/openapi.json

# With camelCase keys
rake apiwork:export:write EXPORT_NAME=typescript KEY_FORMAT=camel OUTPUT=public/exports

# With locale
rake apiwork:export:write OUTPUT=public/exports LOCALE=sv
```

### Cleaning Generated Files

Remove generated files:

```bash
rake apiwork:export:clean OUTPUT=public/exports
```

## Disabling Endpoints in Production

If you only use file generation in production, disable the endpoints:

```ruby
Apiwork::API.define '/api/v1' do
  if Rails.env.development?
    export :openapi
    export :typescript
    export :zod
  end
end
```

The rake tasks work regardless — they generate exports directly from your contracts without needing the endpoints enabled.

## Programmatic Generation

For custom workflows, generate exports in code:

```ruby
# Generate a single export
content = Apiwork::Export.generate(:openapi, '/api/v1')

# Write all exports to files
Apiwork::Export::Pipeline.write(output: 'public/exports')

# Write specific export
Apiwork::Export::Pipeline.write(
  api_path: '/api/v1',
  export_name: :typescript,
  output: 'public/exports',
  key_format: :camel
)
```

## Custom Path

Override the default endpoint path:

```ruby
export :openapi do
  path '/openapi.json'
end
```

Now served at `GET /api/v1/openapi.json` instead of `/.openapi`.

## Key Transformation

Transform keys in the output:

```ruby
export :openapi do
  key_format :camel
end
```

Options:

- `:keep` — No transformation
- `:camel` — `created_at` becomes `createdAt`
- `:kebab` — `created_at` becomes `created-at` (JSON:API style)
- `:underscore` — All keys use snake_case

If not specified, inherits from the [API definition](/guide/core/api-definitions/introduction).
