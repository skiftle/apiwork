---
order: 6
---

# Sorbus

The Sorbus export generates a typed client contract — Zod schemas, TypeScript types, and an endpoint tree in a single file.

Where [TypeScript](./typescript.md) and [Zod](./zod.md) exports produce standalone type definitions and validation schemas, the Sorbus export combines both and adds endpoint metadata: paths, methods, request/response shapes, and error codes. The output is a contract that [Sorbus](https://sorbus.dev) consumes to provide typed API calls.

## Configuration

```ruby
Apiwork::API.define '/api/v1' do
  export :sorbus
end
```

## Options

```ruby
export :sorbus do
  path '/contract.ts'       # Custom endpoint path
  key_format :camel         # Transform keys to camelCase
end
```

## Output

The generated file contains four sections:

1. **Zod schemas** — enums, types, request/response shapes (same as the Zod export)
2. **TypeScript types** — inferred from the Zod schemas (same as the TypeScript export)
3. **Endpoint contract** — `export const contract = { ... } as const;` with every endpoint's path, method, params, and response
4. **Error reference** — the shared error schema name

```typescript
import { z } from 'zod';

// Zod schemas
export const StatusSchema = z.enum(['draft', 'paid', 'sent']);

export const InvoiceSchema = z.object({
  id: z.number().int(),
  number: z.string(),
  status: StatusSchema.nullable(),
  createdAt: z.iso.datetime(),
});

export const InvoiceCreatePayloadSchema = z.object({
  number: z.string(),
  status: StatusSchema.nullable().optional(),
});

// TypeScript types
export type Status = 'draft' | 'paid' | 'sent';
export interface Invoice { ... }

// Endpoint contract
export const contract = {
  endpoints: {
    invoices: {
      index: {
        path: '/invoices',
        method: 'GET',
        request: {
          query: z.object({ ... }),
        },
        response: {
          body: z.object({ invoices: z.array(InvoiceSchema) }),
        },
        errors: [400, 500],
      },
      create: {
        path: '/invoices',
        method: 'POST',
        request: {
          body: z.object({ invoice: InvoiceCreatePayloadSchema }),
        },
        response: {
          body: z.object({ invoice: InvoiceSchema }),
        },
        errors: [400, 422, 500],
      },
      show: {
        path: '/invoices/:id',
        method: 'GET',
        pathParams: z.object({ id: z.string() }),
        response: {
          body: z.object({ invoice: InvoiceSchema }),
        },
        errors: [400, 404, 500],
      },
    },
  },
  error: ErrorSchema,
} as const;
```

Each endpoint includes:

| Field | Description |
| ----- | ----------- |
| `path` | URL path with `:param` placeholders |
| `method` | HTTP method |
| `pathParams` | Zod schema for path parameters (when present) |
| `request.query` | Zod schema for query parameters (when present) |
| `request.body` | Zod schema for the request body (when present) |
| `response.body` | Zod schema for the response body (when present) |
| `errors` | HTTP status codes the endpoint can return |

## Key Difference

The TypeScript and Zod exports produce standalone files — types and schemas that you import and wire up yourself. The Sorbus export produces a **contract**: a single object that maps every endpoint to its typed request and response. [Sorbus](https://sorbus.dev) reads this contract and gives you typed API calls with no additional configuration.

#### See also

- [Export reference](../../reference/export/base) — programmatic generation API
