---
order: 4
---

# TypeScript

Generates TypeScript type definitions.

## Configuration

```ruby
Apiwork::API.define '/api/v1' do
  export :typescript
end
```

## Options

```ruby
export :typescript do
  path '/types.ts'          # Custom endpoint path
  key_format :camel         # Transform keys to camelCase
end
```

| Option    | Values   | Default |
| --------- | -------- | ------- |
| `version` | `4`, `5` | `5`     |

## Output

The generated output includes:

- Enum types
- Custom types
- Request/response interfaces per action

```typescript
// Enums
export type Status = 'draft' | 'sent' | 'paid';

// Resource type
export interface Invoice {
  id: string;
  number: string;
  status: null | string;
  issuedOn: null | string;
  createdAt: string;
}

// Payload type (inner fields)
export interface InvoiceCreatePayload {
  number: string;
  status?: null | string;
  issuedOn?: null | string;
}

// Request body (with root key wrapper)
export interface InvoicesCreateRequestBody {
  invoice: InvoiceCreatePayload;
}

// Response body (success or error)
export interface InvoiceCreateSuccessResponseBody {
  invoice: Invoice;
}

export type InvoicesCreateResponseBody =
  | InvoiceCreateSuccessResponseBody
  | ErrorResponseBody;
```

## Type Ordering

Types are sorted in topological order so dependencies come first.

Recursive types (types that reference themselves) work naturally in TypeScript interfaces.

## JSDoc Comments

Descriptions from your Ruby code become JSDoc comments in TypeScript.

```ruby
Apiwork::API.define '/api/v1' do
  object :invoice,
         description: 'Represents a customer invoice',
         example: { id: 'inv_123', amount: 99.99 } do
    string :id, description: 'Unique identifier', example: 'inv_123'
    decimal :amount, description: 'Total amount', example: 99.99
  end

  enum :status, values: %w[draft sent paid], description: 'Invoice status'
end
```

Generated TypeScript:

```typescript
/**
 * Represents a customer invoice
 * @example {"id":"inv_123","amount":99.99}
 */
export interface Invoice {
  /**
   * Total amount
   * @example 99.99
   */
  amount: number;
  /**
   * Unique identifier
   * @example "inv_123"
   */
  id: string;
}

/** Invoice status */
export type Status = 'draft' | 'paid' | 'sent';
```

This works for:

- Types and interfaces
- Properties
- Enums

No JSDoc is generated when `description` is missing. Changes to Ruby descriptions appear in the next TypeScript generation.

#### See also

- [Export reference](../../reference/export/base) — programmatic generation API
