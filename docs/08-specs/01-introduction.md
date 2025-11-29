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
api_class = Apiwork::API::Registry.find('/api/v1')

# Generate OpenAPI spec
openapi = Apiwork::Spec::Openapi.new(api_class)
openapi.generate  # Returns JSON

# Generate TypeScript
typescript = Apiwork::Spec::Typescript.new(api_class)
typescript.generate  # Returns TypeScript code

# Generate Zod
zod = Apiwork::Spec::Zod.new(api_class)
zod.generate  # Returns Zod schemas
```
