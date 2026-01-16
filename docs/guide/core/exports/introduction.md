---
order: 1
---

# Introduction

Exports describe your API in formats understood by external tools.

Built-in exports include OpenAPI, TypeScript, and Zod, but exports are a general mechanism that can be extended with [custom formats](../../advanced/custom-exports.md).

Exports are generated from [introspection](../introspection/introduction.md) — the unified representation of your API definitions, contracts, and schemas. Instead of maintaining separate specification files, exports are derived directly from this structure and always reflect the current API.

When your API changes, its exports change with it.

## Generating Exports

Three ways to generate exports:

| Method         | Best For    | Requires Declaration |
| -------------- | ----------- | -------------------- |
| Endpoints      | Development | Yes                  |
| Rake Tasks     | Production  | No                   |
| Programmatic   | Custom      | No                   |

### Endpoints

Expose exports as runtime endpoints:

```ruby
Apiwork::API.define '/api/v1' do
  export :openapi
  export :typescript
  export :zod
end
```

This creates endpoints at `/.openapi`, `/.typescript`, and `/.zod`:

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

| Parameter    | Values                                 | Default          | Applies To |
| ------------ | -------------------------------------- | ---------------- | ---------- |
| `key_format` | `keep`, `camel`, `kebab`, `underscore` | API's key_format | All        |
| `locale`     | Any locale symbol                      | —                | All        |
| `format`     | `json`, `yaml`                         | `json`           | OpenAPI    |
| `version`    | See below                              | Export default   | Per export |

Export versions:

| Export     | Versions | Default |
| ---------- | -------- | ------- |
| OpenAPI    | `3.1.0`  | `3.1.0` |
| TypeScript | `4`, `5` | `5`     |
| Zod        | `4`      | `4`     |

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

Endpoints support custom paths — see [Exports](../api-definitions/exports.md).

### Rake Tasks

Generate exports to files:

```bash
rake apiwork:export:write OUTPUT=public/exports
```

This generates all formats (OpenAPI, TypeScript, Zod) for all APIs:

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

#### Cleaning Generated Files

Remove generated files:

```bash
rake apiwork:export:clean OUTPUT=public/exports
```

### Programmatic

For custom workflows, generate exports in code:

```ruby
content = Apiwork::Export.generate(:openapi, '/api/v1')
content = Apiwork::Export.generate(:typescript, '/api/v1', key_format: :camel)
```

#### See also

- [Custom Exports](../../advanced/custom-exports.md) — creating your own export formats
- [Export reference](../../../reference/export.md) — programmatic generation API
