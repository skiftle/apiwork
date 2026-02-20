---
order: 5
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

| Option    | Values | Default |
| --------- | ------ | ------- |
| `version` | `4`    | `4`     |

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
export const PostRepresentation = z.object({
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
export type Post = z.infer<typeof PostRepresentation>;
```

## Usage

```typescript
import { PostCreateRequestSchema, PostRepresentation } from "./api/schemas";

// Validate request before sending
const validated = PostCreateRequestSchema.parse(formData);

// Validate response from API
const post = PostRepresentation.parse(await response.json());
```

## Ordering

Schemas are sorted in topological order so dependencies come first.

For recursive schemas, Apiwork uses `z.lazy()`:

```typescript
export const CategoryRepresentation: z.ZodType<Category> = z.lazy(() =>
  z.object({
    name: z.string(),
    children: z.array(CategoryRepresentation),
  })
);
```

Apiwork generates explicit TypeScript interfaces because `z.infer` returns `unknown` for `z.lazy()` schemas.

#### See also

- [Export reference](../../../reference/export/base) — programmatic generation API
