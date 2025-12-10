---
order: 4
---

# Zod

Generates Zod validation schemas for runtime validation.

## Configuration

```ruby
Apiwork::API.draw '/api/v1' do
  spec :zod
end
```

## Options

```ruby
spec :zod,
     path: '/schemas.ts',       # Custom endpoint path
     key_format: :camel      # Transform keys to camelCase
```

## Output

The generated output includes:

- Zod import
- Enum schemas
- Custom type schemas
- Request/response schemas per action
- Inferred TypeScript types

```typescript
import { z } from 'zod';

// Enums
export const StatusSchema = z.enum(['draft', 'published', 'archived']);

// Custom types
export const AddressSchema = z.object({
  street: z.string(),
  city: z.string(),
  country: z.string()
});

// Resource schemas
export const PostSchema = z.object({
  id: z.number(),
  title: z.string(),
  body: z.string(),
  status: StatusSchema,
  createdAt: z.string()
});

// Request schemas
export const PostCreateRequestSchema = z.object({
  post: z.object({
    title: z.string(),
    body: z.string().optional(),
    status: StatusSchema.optional()
  })
});

// Inferred types
export type Status = z.infer<typeof StatusSchema>;
export type Post = z.infer<typeof PostSchema>;
```

## Usage

```typescript
import { PostCreateRequestSchema, PostSchema } from './api/schemas';

// Validate request before sending
const validated = PostCreateRequestSchema.parse(formData);

// Validate response from API
const post = PostSchema.parse(await response.json());
```

## Version

Supports Zod v3 and v4. Default is v4.
