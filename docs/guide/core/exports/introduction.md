---
order: 1
---

# Introduction

Exports describe your API in formats understood by external tools.

Built-in exports include OpenAPI, TypeScript, and Zod, but exports are a general mechanism that can be extended with [custom exports](./custom-exports.md).

Exports are generated from [introspection](../introspection/introduction.md) — the unified representation of your API definitions, contracts, and representations. Instead of maintaining separate specification files, exports are derived directly from this structure and always reflect the current API.

When your API changes, its exports change with it.

## Declaration

Declare which exports to enable:

```ruby
Apiwork::API.define '/api/v1' do
  export :openapi
  export :typescript
  export :zod
end
```

Once declared, exports can be generated via endpoints, rake tasks, or code.

## Generating Exports

Three ways to generate declared exports:

| Method       | Best For    |
| ------------ | ----------- |
| Endpoints    | Development |
| Rake Tasks   | Production  |
| Programmatic | Custom      |

### Endpoints

By default, endpoints are mounted in development only:

| Format     | Endpoint                  |
| ---------- | ------------------------- |
| OpenAPI    | `GET /api/v1/.openapi`    |
| TypeScript | `GET /api/v1/.typescript` |
| Zod        | `GET /api/v1/.zod`        |

Endpoints generate on each request — convenient for development, but not ideal for production traffic.

#### Query Parameters

Pass options as query parameters:

```bash
curl http://localhost:3000/api/v1/.openapi?format=yaml
curl http://localhost:3000/api/v1/.typescript?key_format=camel
```

**Universal options** (available for all exports):

| Parameter    | Values                                 | Default          |
| ------------ | -------------------------------------- | ---------------- |
| `key_format` | `keep`, `camel`, `kebab`, `underscore` | API's key_format |
| `locale`     | Any locale symbol                      | —                |

**Serialization** (hash exports only):

| Parameter | Values         | Default |
| --------- | -------------- | ------- |
| `format`  | `json`, `yaml` | `json`  |

Each export may define additional options — see [OpenAPI](./openapi.md), [TypeScript](./typescript.md), [Zod](./zod.md).

Custom exports can define their own options — see [Custom Exports](./custom-exports.md).

#### Option Precedence

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

### Rake Tasks

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

#### Options

| Option        | Description                    | Example          |
| ------------- | ------------------------------ | ---------------- |
| `OUTPUT`      | Output path (required)         | `public/exports` |
| `API_PATH`    | Generate for specific API only | `/api/v1`        |
| `EXPORT_NAME` | Generate specific format only  | `openapi`        |
| `KEY_FORMAT`  | Transform keys                 | `camel`          |
| `LOCALE`      | Use specific locale            | `sv`             |

Examples:

```bash
# All declared exports for all APIs
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

#### Cleaning Generated Files

Remove generated files:

```bash
rake apiwork:export:clean OUTPUT=public/exports
```

### Programmatic

For custom workflows, generate exports in code:

```ruby
content = Apiwork::Export.generate(:openapi, '/api/v1')
content = Apiwork::Export.generate(:openapi, '/api/v1', format: :yaml)
content = Apiwork::Export.generate(:typescript, '/api/v1', key_format: :camel)
```

Universal options (`key_format`, `locale`, `format`) work for all exports. Each export may define additional options — see [OpenAPI](./openapi.md), [TypeScript](./typescript.md), [Zod](./zod.md).

## Endpoint Configuration

Control endpoint behavior with the `endpoint` block:

```ruby
export :openapi do
  endpoint do
    mode :always
    path '/openapi.json'
  end
end
```

### Mode

| Mode      | Behavior                              |
| --------- | ------------------------------------- |
| `:auto`   | Development only (default)            |
| `:always` | Always mount endpoint                 |
| `:never`  | Never mount endpoint (rake/code only) |

```ruby
export :openapi do
  endpoint do
    mode :auto  # Only in development (default)
  end
end

export :typescript do
  endpoint do
    mode :never  # Generate via rake task only
  end
end
```

### Custom Path

```ruby
export :openapi do
  endpoint do
    path '/openapi.json'  # Instead of /.openapi
  end
end
```

### Production Considerations

Endpoints generate on each request, which is slow for production traffic. Recommended approaches:

**Generate at build time** (recommended):

```bash
# In CI/CD pipeline
rake apiwork:export:write OUTPUT=public/exports
```

Serve the static files from your CDN or web server.

**Disable endpoints entirely**:

```ruby
export :openapi do
  endpoint do
    mode :never
  end
end
```

**If you need runtime endpoints in production**:

```ruby
export :openapi do
  endpoint do
    mode :always
  end
end
```

Consider caching the response at the HTTP level (Rack middleware, reverse proxy, or CDN).

#### See also

- [Custom Exports](./custom-exports.md) — creating your own export formats
- [Export reference](../../../reference/export/base) — programmatic generation API
