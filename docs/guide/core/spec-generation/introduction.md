---
order: 1
---

# Introduction

Your contracts and schemas already describe your API completely — Apiwork can generate specifications from them automatically.

## Available Formats

Three formats out of the box:

- **OpenAPI** — OpenAPI 3.1 specification
- **TypeScript** — type definitions for your frontend
- **Zod** — runtime validation schemas

## Enabling Specs

Enable whichever formats you need in your [API definition](/guide/core/api-definitions/introduction):

```ruby
Apiwork::API.define '/api/v1' do
  spec :openapi
  spec :typescript
  spec :zod
end
```

## Two Approaches

Apiwork offers two ways to access your generated specs:

| Approach | Best For | How It Works |
|----------|----------|--------------|
| **Endpoints** | Development | Specs served dynamically at `/.spec/{format}` |
| **File Generation** | Production | Specs written to files via rake task |

In development, endpoints are convenient — you get instant feedback as you change your API. In production, pre-generated files are faster and can be served statically.

## Endpoints (Development)

Once enabled, specs are served at `/.spec/{format}`:

| Format | Endpoint |
|--------|----------|
| OpenAPI | `GET /api/v1/.spec/openapi` |
| TypeScript | `GET /api/v1/.spec/typescript` |
| Zod | `GET /api/v1/.spec/zod` |

These endpoints generate specs on each request. Great for development where you want to see changes immediately, but not ideal for production traffic.

::: tip
During development, you can fetch specs directly from your running server:
```bash
curl http://localhost:3000/api/v1/.spec/typescript > src/api/types.ts
```
:::

## File Generation (Production)

For production, generate specs to files and serve them statically:

```bash
rake apiwork:spec:write OUTPUT=public/specs
```

This generates all enabled specs for all APIs:

```text
public/specs/
├── api/
│   └── v1/
│       ├── openapi.json
│       ├── typescript.ts
│       └── zod.ts
```

### Options

| Option | Description | Example |
|--------|-------------|---------|
| `OUTPUT` | Output path (required) | `public/specs` |
| `API_PATH` | Generate for specific API only | `/api/v1` |
| `SPEC_NAME` | Generate specific format only | `openapi` |
| `KEY_FORMAT` | Transform keys | `camel` |
| `LOCALE` | Use specific locale | `sv` |

Examples:

```bash
# All specs for all APIs
rake apiwork:spec:write OUTPUT=public/specs

# Only OpenAPI for /api/v1
rake apiwork:spec:write API_PATH=/api/v1 SPEC_NAME=openapi OUTPUT=public/specs

# Single file output
rake apiwork:spec:write API_PATH=/api/v1 SPEC_NAME=openapi OUTPUT=public/openapi.json

# With camelCase keys
rake apiwork:spec:write SPEC_NAME=typescript KEY_FORMAT=camel OUTPUT=public/specs

# With Swedish locale
rake apiwork:spec:write OUTPUT=public/specs LOCALE=sv
```

### Cleaning Generated Files

Remove generated files:

```bash
rake apiwork:spec:clean OUTPUT=public/specs
```

## Disabling Endpoints in Production

If you only use file generation in production, disable the endpoints:

```ruby
Apiwork::API.define '/api/v1' do
  if Rails.env.development?
    spec :openapi
    spec :typescript
    spec :zod
  end
end
```

The rake tasks work regardless — they generate specs directly from your contracts without needing the endpoints enabled.

## Programmatic Generation

For custom workflows, generate specs in code:

```ruby
# Generate a single spec
content = Apiwork::Spec.generate(:openapi, '/api/v1')

# Write all specs to files
Apiwork::Spec::Pipeline.write(output: 'public/specs')

# Write specific spec
Apiwork::Spec::Pipeline.write(
  api_path: '/api/v1',
  spec_name: :typescript,
  output: 'public/specs',
  key_format: :camel
)
```

## Custom Path

Override the default endpoint path:

```ruby
spec :openapi do
  path '/openapi.json'
end
```

Now served at `GET /api/v1/openapi.json` instead of `/.spec/openapi`.

## Key Transformation

Transform keys in the output:

```ruby
spec :openapi do
  key_format :camel
end
```

Options:
- `:keep` — No transformation
- `:camel` — `created_at` becomes `createdAt`
- `:underscore` — All keys use snake_case

If not specified, inherits from the [API definition](/guide/core/api-definitions/introduction).
