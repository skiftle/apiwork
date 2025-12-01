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

## Options

### key_transform

Transform keys in the output:

```ruby
spec :openapi, key_transform: :camel
```

Options:
- `:keep` — No transformation (default)
- `:camel` — `created_at` becomes `createdAt`
- `:underscore` — All keys use snake_case

## Describe Actions

Add metadata to actions for richer spec output:

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts do
    describe :publish,
      summary: "Publish a post",
      description: "Changes the post status from draft to published",
      tags: ["Publishing"],
      operation_id: "publishPost"

    member do
      patch :publish
    end
  end
end
```

### Available Options

| Option | Description |
|--------|-------------|
| `summary` | Short description (appears in endpoint list) |
| `description` | Detailed description |
| `tags` | OpenAPI tags for grouping |
| `operation_id` | Unique identifier for the operation |
| `deprecated` | Mark action as deprecated |

## Multiple Descriptions

Describe multiple actions:

```ruby
resources :posts do
  describe :index,
    summary: "List posts",
    tags: ["Posts"]

  describe :create,
    summary: "Create a post",
    tags: ["Posts"]

  describe :publish,
    summary: "Publish a post",
    tags: ["Publishing"]
end
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
