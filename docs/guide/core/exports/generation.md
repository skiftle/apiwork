---
order: 2
---

# Generation

There are three ways to generate declared exports:

| Method       | Best For    |
| ------------ | ----------- |
| Endpoints    | Development |
| Rake Tasks   | Production  |
| Programmatic | Custom      |

## Endpoints

Each declared export is available as an endpoint at your API's base path:

| Format     | Endpoint                  |
| ---------- | ------------------------- |
| OpenAPI    | `GET /api/v1/.openapi`    |
| TypeScript | `GET /api/v1/.typescript` |
| Zod        | `GET /api/v1/.zod`        |

Endpoints are only available in development by default and generate on each request, so changes to your API definition are reflected immediately.

### Query Parameters

Pass options as query parameters:

```bash
curl http://localhost:3000/api/v1/.openapi?format=yaml
curl http://localhost:3000/api/v1/.typescript?key_format=camel
```

**Universal options** (available for all exports):

| Parameter    | Values                                          | Default          |
| ------------ | ----------------------------------------------- | ---------------- |
| `key_format` | `keep`, `camel`, `pascal`, `kebab`, `underscore` | API's key_format |
| `locale`     | Any locale symbol                      | —                |

**Serialization** (hash exports only):

| Parameter | Values         | Default |
| --------- | -------------- | ------- |
| `format`  | `json`, `yaml` | `json`  |

Each export may define additional options — see [OpenAPI](./openapi.md), [TypeScript](./typescript.md), [Zod](./zod.md).

### Option Precedence

Options resolve in this order (highest priority last):

1. API default (`key_format` from API definition)
2. Export config (`export :openapi do ... end`)
3. Query parameters (override everything)

```ruby
Apiwork::API.define '/api/v1' do
  key_format :underscore  # Default for all exports

  export :openapi do
    key_format :camel     # Override for OpenAPI
  end
end
```

```bash
# Uses :camel (from export config)
curl /api/v1/.openapi

# Uses :kebab (query param overrides config)
curl /api/v1/.openapi?key_format=kebab

# Uses :underscore (API default, no export config)
curl /api/v1/.typescript
```

### Endpoint Configuration

Control endpoint behavior with the `endpoint` block:

```ruby
export :openapi do
  endpoint do
    mode :always
    path '/openapi.json'
  end
end
```

| Mode      | Behavior                              |
| --------- | ------------------------------------- |
| `:auto`   | Development only (default)            |
| `:always` | Always mount endpoint                 |
| `:never`  | Never mount endpoint (rake/code only) |

## Rake Tasks

Generate exports to files:

```bash
rake apiwork:export:write OUTPUT=public/exports
```

This generates declared exports for all APIs:

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

```bash
# Only OpenAPI for /api/v1
rake apiwork:export:write API_PATH=/api/v1 EXPORT_NAME=openapi OUTPUT=public/exports

# With camelCase keys
rake apiwork:export:write EXPORT_NAME=typescript KEY_FORMAT=camel OUTPUT=public/exports
```

### Cleaning Generated Files

```bash
rake apiwork:export:clean OUTPUT=public/exports
```

## Programmatic

For custom workflows, generate exports in code:

```ruby
content = Apiwork::Export.generate(:openapi, '/api/v1')
content = Apiwork::Export.generate(:openapi, '/api/v1', format: :yaml)
content = Apiwork::Export.generate(:typescript, '/api/v1', key_format: :camel)
```

## Production

Endpoints generate on each request, which is slow for production traffic.

**Generate at build time** (recommended):

```bash
rake apiwork:export:write OUTPUT=public/exports
```

Serve the static files from your CDN or web server.

**Disable endpoints entirely:**

```ruby
export :openapi do
  endpoint do
    mode :never
  end
end
```

**If you need runtime endpoints in production**, consider caching at the HTTP level (Rack middleware, reverse proxy, or CDN).

#### See also

- [Custom Exports](./custom-exports.md) — building your own export formats
- [Export reference](../../../reference/apiwork/export/base) — programmatic generation API
