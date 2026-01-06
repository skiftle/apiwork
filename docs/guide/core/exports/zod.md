---
order: 4
---

# Zod

Generates Zod validation schemas for runtime validation.

## Configuration

```ruby
Apiwork::API.define '/api/v1' do
  export :zod
end
```

## Options

```ruby
export :zod do
  path '/schemas.ts'        # Custom endpoint path
  key_format :camel         # Transform keys to camelCase
end
```

## Output

The generated output includes:

- Zod import
- Enum schemas
- Custom type schemas
- Request/response schemas per action
- Inferred TypeScript types

```typescript
import { z } from "zod";

// Enums
export const StatusSchema = z.enum(["draft", "published", "archived"]);

// Custom types
export const AddressSchema = z.object({
  street: z.string(),
  city: z.string(),
  country: z.string(),
});

// Resource schemas
export const PostSchema = z.object({
  id: z.number(),
  title: z.string(),
  body: z.string(),
  status: StatusSchema,
  createdAt: z.string(),
});

// Request schemas
export const PostCreateRequestSchema = z.object({
  post: z.object({
    title: z.string(),
    body: z.string().optional(),
    status: StatusSchema.optional(),
  }),
});

// Inferred types
export type Status = z.infer<typeof StatusSchema>;
export type Post = z.infer<typeof PostSchema>;
```

## Usage

```typescript
import { PostCreateRequestSchema, PostSchema } from "./api/schemas";

// Validate request before sending
const validated = PostCreateRequestSchema.parse(formData);

// Validate response from API
const post = PostSchema.parse(await response.json());
```

## Version

Generates schemas compatible with **Zod v4**.

## Type Ordering

Types are sorted in topological order so dependencies come first.

For recursive types (types that reference themselves), Apiwork uses `z.lazy()`:

```typescript
export const CategorySchema: z.ZodType<Category> = z.lazy(() =>
  z.object({
    name: z.string(),
    children: z.array(CategorySchema),
  })
);
```

This is also why Apiwork generates explicit TypeScript interfaces instead of relying on `z.infer`. Zod's type inference doesn't work correctly with `z.lazy()` for recursive types — the inferred type becomes `unknown`. By generating separate interfaces, you get proper types for all schemas.
