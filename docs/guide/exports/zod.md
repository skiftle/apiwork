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
export const StatusSchema = z.enum(["draft", "sent", "paid"]);

// Resource schema
export const InvoiceSchema = z.object({
  id: z.string(),
  number: z.string(),
  status: StatusSchema.nullable(),
  issuedOn: z.iso.date().nullable(),
  createdAt: z.iso.datetime(),
});

// Payload schema (inner fields)
export const InvoiceCreatePayloadSchema = z.object({
  number: z.string(),
  status: StatusSchema.nullable().optional(),
  issuedOn: z.iso.date().nullable().optional(),
});

// Request body schema (with root key wrapper)
export const InvoicesCreateRequestBodySchema = z.object({
  invoice: InvoiceCreatePayloadSchema,
});

// Response body schema (success or error)
export const InvoiceCreateSuccessResponseBodySchema = z.object({
  invoice: InvoiceSchema,
});

export const InvoicesCreateResponseBodySchema = z.union([
  InvoiceCreateSuccessResponseBodySchema,
  ErrorResponseBodySchema,
]);

// Inferred types
export type Status = z.infer<typeof StatusSchema>;
export interface Invoice { ... }
```

## Format Validation

When string, integer, or number params have a `format` hint, Zod schemas include built-in validators:

| Format | Zod output |
|--------|------------|
| `:email` | `z.email()` |
| `:uuid` | `z.uuid()` |
| `:url` | `z.url()` |
| `:ipv4` | `z.ipv4()` |
| `:ipv6` | `z.ipv6()` |
| `:date` | `z.iso.date()` |
| `:datetime` | `z.iso.datetime()` |
| `:int32`, `:int64` | `z.number().int()` |
| `:float`, `:double` | `z.number()` |
| `:password`, `:hostname` | `z.string()` |

Formats are set in your type definitions. See [Format Hints](../types/types.md#format-hints).

## Ordering

Schemas are sorted in topological order so dependencies come first.

For recursive schemas, Apiwork uses `z.lazy()`:

```typescript
export const CategorySchema: z.ZodType<Category> = z.lazy(() =>
  z.object({
    name: z.string(),
    children: z.array(CategorySchema),
  })
);
```

Apiwork generates explicit TypeScript interfaces because `z.infer` returns `unknown` for `z.lazy()` schemas.

#### See also

- [Export reference](../../reference/export/base) — programmatic generation API
