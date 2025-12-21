---
order: 2
---

# Types

Primitive types are the building blocks. Every param uses one of these.

## Scalar Types

| Type | Ruby | TypeScript | Zod |
|------|------|------------|-----|
| `:string` | `String` | `string` | `z.string()` |
| `:integer` | `Integer` | `number` | `z.number().int()` |
| `:float` | `Float`, `BigDecimal` | `number` | `z.number()` |
| `:decimal` | `BigDecimal` | `number` | `z.number()` |
| `:boolean` | `true`, `false` | `boolean` | `z.boolean()` |
| `:date` | `Date` | `string` | `z.iso.date()` |
| `:datetime` | `DateTime`, `Time` | `string` | `z.iso.datetime()` |
| `:uuid` | `String` (UUID format) | `string` | `z.uuid()` |

## Aliases

| Type | Alias for |
|------|-----------|
| `:text` | `:string` |
| `:number` | `:float` |

## Special Types

| Type | Purpose | TypeScript | Zod |
|------|---------|------------|-----|
| `:json` | Arbitrary JSON | `Record<string, any>` | `z.record(z.string(), z.any())` |
| `:binary` | Base64 encoded | `string` | `z.string()` |
| `:literal` | Exact value | literal type | `z.literal()` |
| `:unknown` | Any value | `unknown` | `z.unknown()` |

## Structure Types

| Type | Purpose |
|------|---------|
| `:object` | Nested object with shape |
| `:array` | Array of items |
| `:union` | One of several types |

[Unions](./unions.md) covers discriminated and simple unions. [Custom Types](./custom-types.md) shows how to define reusable object types.

## Usage

```ruby
param :title, type: :string
param :count, type: :integer
param :price, type: :decimal
param :active, type: :boolean
param :published_at, type: :datetime
param :birth_date, type: :date
param :id, type: :uuid
```

## Date and Time Formats

Date and time types serialize to ISO 8601 strings:

| Type | Format | Example |
|------|--------|---------|
| `:date` | `YYYY-MM-DD` | `"2024-01-15"` |
| `:datetime` | `YYYY-MM-DDTHH:MM:SSZ` | `"2024-01-15T10:30:00Z"` |

## Literal Type

The `:literal` type constrains a value to an exact match. Used primarily in discriminated unions:

```ruby
param :type, type: :literal, value: 'text'
```

```typescript
// TypeScript
type: 'text'

// Zod
type: z.literal('text')
```

## Type Coercion

Request params are automatically coerced:

| Input | Type | Result |
|-------|------|--------|
| `"123"` | `:integer` | `123` |
| `"3.14"` | `:float` | `3.14` |
| `"true"` | `:boolean` | `true` |
| `"false"` | `:boolean` | `false` |
| `"2024-01-15"` | `:date` | `Date.parse("2024-01-15")` |

## Generated Output

### Introspection

```json
{
  "title": { "type": "string" },
  "count": { "type": "integer", "optional": true },
  "price": { "type": "decimal" },
  "active": { "type": "boolean", "optional": true },
  "published_at": { "type": "datetime", "optional": true }
}
```

### TypeScript

```typescript
interface Example {
  title: string;
  count?: number;
  price: number;
  active?: boolean;
  publishedAt?: string;
}
```

### Zod

```typescript
const ExampleSchema = z.object({
  title: z.string(),
  count: z.number().int().optional(),
  price: z.number(),
  active: z.boolean().optional(),
  publishedAt: z.iso.datetime().optional(),
});
```

### OpenAPI

```yaml
Example:
  type: object
  required: [title, price]
  properties:
    title:
      type: string
    count:
      type: integer
    price:
      type: number
    active:
      type: boolean
    publishedAt:
      type: string
      format: date-time
```
