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
| `:time` | `Time` | `string` | `z.iso.time()` |
| `:uuid` | `String` (UUID format) | `string` | `z.uuid()` |

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

## Semantic Precision

Some types produce identical runtime output but carry distinct meaning. This metadata is preserved in specs that support it.

| Type | Runtime | Purpose | OpenAPI |
|------|---------|---------|---------|
| `:float` | `number` | IEEE 754 floating-point | `format: double` |
| `:decimal` | `number` | Arbitrary precision | — |
| `:binary` | `string` | Base64-encoded bytes | `format: byte` |

**When to use which:**

- `:decimal` for money, percentages, and values where precision matters
- `:float` for scientific calculations, coordinates, and approximate values
- `:binary` for file uploads, images, and encoded payloads

The semantic distinction exists even when the generated code is identical. OpenAPI consumers can use format hints for validation, documentation, and code generation. TypeScript and Zod treat these as equivalent at runtime.

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
| `:time` | `HH:MM:SS` | `"10:30:00"` |

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
  "title": {
    "type": "string"
  },
  "count": {
    "type": "integer"
  },
  "price": {
    "type": "decimal"
  },
  "active": {
    "type": "boolean"
  },
  "published_at": {
    "type": "datetime"
  },
  "birth_date": {
    "type": "date"
  },
  "id": {
    "type": "uuid"
  }
}
```

### TypeScript

```typescript
export interface Example {
  title: string;
  count: number;
  price: number;
  active: boolean;
  publishedAt: string;
  birthDate: string;
  id: string;
}
```

### Zod

```typescript
export const ExampleSchema = z.object({
  title: z.string(),
  count: z.number().int(),
  price: z.number(),
  active: z.boolean(),
  publishedAt: z.iso.datetime(),
  birthDate: z.iso.date(),
  id: z.uuid(),
});
```

### OpenAPI

```yaml
Example:
  type: object
  required:
    - title
    - count
    - price
    - active
    - publishedAt
    - birthDate
    - id
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
    birthDate:
      type: string
      format: date
    id:
      type: string
      format: uuid
```
