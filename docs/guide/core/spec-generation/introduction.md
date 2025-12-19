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

Enable whichever formats you need in your API definition:

```ruby
Apiwork::API.define '/api/v1' do
  spec :openapi
  spec :typescript
  spec :zod
end
```

## Endpoints

Once enabled, specs are served at `/.spec/{format}`:

| Format | Endpoint |
|--------|----------|
| OpenAPI | `GET /api/v1/.spec/openapi` |
| TypeScript | `GET /api/v1/.spec/typescript` |
| Zod | `GET /api/v1/.spec/zod` |

## Custom Path

Want a different URL? Override the path:

```ruby
spec :openapi do
  path '/openapi.json'
end
```

Now served at `GET /api/v1/openapi.json`.

## Key Transformation

If your frontend uses camelCase, you can transform keys in the output:

```ruby
spec :openapi do
  key_format :camel
end
```

Options:
- `:keep` — No transformation (default)
- `:camel` — `created_at` becomes `createdAt`
- `:underscore` — All keys use snake_case

## Programmatic Generation

You can also generate specs in code, useful for CI pipelines or build scripts:

```ruby
Apiwork::Spec::Openapi.generate(path: '/api/v1')
Apiwork::Spec::Typescript.generate(path: '/api/v1')
Apiwork::Spec::Zod.generate(path: '/api/v1')
```
