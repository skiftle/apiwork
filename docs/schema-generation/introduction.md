# Schema Generation

Apiwork automatically generates frontend-ready schemas from your contracts and schemas. Generate OpenAPI specs, TypeScript interfaces, and Zod validation schemas with zero configuration.

## What gets generated

From your contracts and schemas, Apiwork generates:

1. **OpenAPI 3.1.0** - Industry-standard API documentation (JSON)
2. **Transport** - TypeScript interfaces and types (`.ts`)
3. **Zod** - TypeScript runtime validation schemas (`.ts`)

All three are generated automatically from your existing code. No manual schema writing needed.

## Enabling schema endpoints

Add schema generation endpoints to your API definition:

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  schema :openapi   # GET /api/v1/.schema/openapi
  schema :transport # GET /api/v1/.schema/transport
  schema :zod       # GET /api/v1/.schema/zod

  resources :posts
  resources :comments
end
```

Now your API exposes three schema endpoints that your frontend can fetch.

## The three schemas

### OpenAPI

**Format:** JSON
**Use case:** API documentation, Swagger UI, Postman, code generation tools

```bash
GET /api/v1/.schema/openapi
```

Returns OpenAPI 3.1.0 specification with all endpoints, request/response schemas, and metadata.

### Transport

**Format:** TypeScript (`.ts`)
**Use case:** TypeScript types for your API client

```bash
GET /api/v1/.schema/transport
```

Returns TypeScript interfaces, Zod schemas, and type-safe API client contracts.

### Zod

**Format:** TypeScript (`.ts`)
**Use case:** Runtime validation in your frontend

```bash
GET /api/v1/.schema/zod
```

Returns Zod validation schemas for all resources, including create/update payloads and query parameters.

## Quick example

**Backend:**
```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  schema :transport
  resources :posts
end

# app/schemas/api/v1/post_schema.rb
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title, writable: true
  attribute :body, writable: true
  attribute :published, writable: true
  attribute :created_at
end

# app/contracts/api/v1/post_contract.rb
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema
end
```

**Frontend:**
```bash
# Fetch generated schemas
curl http://localhost:3000/api/v1/.schema/transport > api-contract.ts
```

**Generated TypeScript:**
```typescript
// Automatically generated - DO NOT EDIT
import { z } from 'zod';

export const PostSchema = z.object({
  id: z.number().int(),
  title: z.string(),
  body: z.string(),
  published: z.boolean(),
  createdAt: z.string().datetime()
});

export const PostCreatePayloadSchema = z.object({
  post: z.object({
    title: z.string(),
    body: z.string(),
    published: z.boolean().optional()
  })
});

export type Post = z.infer<typeof PostSchema>;
export type PostCreatePayload = z.infer<typeof PostCreatePayloadSchema>;

// API contract with type-safe methods
export const contract = {
  posts: {
    index: async (query?: PostQueryParams): Promise<{ ok: true, posts: Post[], meta: PaginationMeta }> => { /* ... */ },
    show: async (id: number): Promise<{ ok: true, post: Post }> => { /* ... */ },
    create: async (payload: PostCreatePayload): Promise<{ ok: true, post: Post }> => { /* ... */ },
    // ...
  }
};
```

Use in your frontend:
```typescript
import { contract, type Post, PostCreatePayloadSchema } from './api-contract';

// Type-safe API calls
const result = await contract.posts.index({ filter: { published: true } });
const posts: Post[] = result.posts;

// Runtime validation
const payload = PostCreatePayloadSchema.parse({
  post: {
    title: "My Post",
    body: "Content here",
    published: true
  }
});

await contract.posts.create(payload);
```

## How it works

Apiwork introspects your contracts, schemas, and routes to generate schemas:

1. **Routes** - From `Apiwork::API.draw` definitions
2. **Contracts** - From action input/output definitions
3. **Schemas** - From attribute and association definitions
4. **Models** - From database schema (types, nullability, enums)

Everything is inferred automatically.

## Key transformation

Control how keys are transformed in generated schemas:

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  schema :transport, key_transform: :camel       # camelCase (default)
  schema :openapi, key_transform: :underscore   # snake_case
end
```

Options:
- `:camel` - `createdAt` (camelCase, default for TypeScript)
- `:underscore` - `created_at` (snake_case)
- `:keep` - Keep keys unchanged

## Multiple API versions

Each API version has its own schemas:

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  schema :transport
  resources :posts
end

# config/apis/v2.rb
Apiwork::API.draw '/api/v2' do
  schema :transport
  resources :posts
  resources :articles  # New in v2
end
```

Fetch separately:
```bash
curl http://localhost:3000/api/v1/.schema/transport > v1-contract.ts
curl http://localhost:3000/api/v2/.schema/transport > v2-contract.ts
```

## Recommended workflow

**Development:**
1. Write your schemas, contracts, and controllers
2. Apiwork exposes `.schema` endpoints automatically
3. Fetch schemas during frontend development

**CI/CD:**
1. Run Rails server in test mode
2. Fetch schemas via HTTP
3. Generate API client from schemas
4. Use in frontend with full type safety

**Example script:**
```bash
#!/bin/bash
# scripts/generate-api-client.sh

# Start Rails in test mode
RAILS_ENV=test rails server -p 3001 -d

# Wait for server
sleep 2

# Fetch schemas
curl http://localhost:3001/api/v1/.schema/transport > frontend/src/api/contract.ts

# Stop server
kill $(cat tmp/pids/server.pid)

echo "API contract generated!"
```

Run in CI:
```yaml
# .github/workflows/frontend.yml
- name: Generate API client
  run: ./scripts/generate-api-client.sh
- name: Build frontend
  run: cd frontend && npm run build
```

## What's included

### OpenAPI

- Complete API specification (OpenAPI 3.1.0)
- All endpoints with HTTP methods
- Request/response schemas
- Query parameters (filter, sort, page)
- API metadata (title, version, description)

### Transport

- TypeScript interfaces for all resources
- Zod validation schemas
- Type-safe API contract with methods
- Query parameter types (filter, sort, page)
- Pagination metadata types
- Error response types

### Zod

- Zod schemas for all resources
- Create/update payload schemas
- Query parameter schemas (filter, sort, page)
- Enum schemas
- Type inference helpers

## Production considerations

**Disable in production:**
```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  # Only expose schemas in development
  schema :transport if Rails.env.development?
  schema :openapi if Rails.env.development?

  resources :posts
end
```

Or use authentication:
```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  schema :transport, controller: 'schema', action: 'transport'
  resources :posts
end

# app/controllers/schema_controller.rb
class SchemaController < ApplicationController
  before_action :authenticate_admin!

  def transport
    # Schema generation handled by Apiwork
  end
end
```

## Next steps

- **[OpenAPI](./openapi.md)** - OpenAPI 3.1.0 generation details
- **[Transport](./transport.md)** - TypeScript contract generation
- **[Zod](./zod.md)** - Zod validation schema generation
