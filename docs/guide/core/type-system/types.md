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
| `:float` | `Float` | `number` | `z.number()` |
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

### `json` vs `object`

Both handle structured data, but serve different purposes:

| Type | Use when | Output |
|------|----------|--------|
| `:object` | Structure is known and defined | Typed interface with specific fields |
| `:json` | Structure is arbitrary or unknown | `Record<string, any>` |

Use `object` when you know the fields:

```ruby
object :settings do
  string :theme
  boolean :notifications
end
```

Use `json` when structure is dynamic or unknown:

```ruby
json :metadata  # Could be anything
```

## Structure Types

| Type | Purpose |
|------|---------|
| `:object` | Nested object with shape |
| `:array` | Array of items |
| `:union` | One of several types |

### Inline vs Named

Structure types can be defined inline or as named definitions:

```ruby
# Inline object — defined in place
object :address do
  string :street
end

# Named object — defined once, referenced by name
object :address do
  string :street
end
reference :shipping, to: :address
```

[Objects](./objects.md) shows how to define reusable named objects. [Unions](./unions.md) covers discriminated and simple unions.

## Semantic Precision

Some types produce identical runtime output but carry distinct meaning. This metadata is preserved in exports that support it.

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
string :title
integer :count
decimal :price
boolean :active
datetime :published_at
date :birth_date
uuid :id
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
literal :type, value: 'text'
```

```typescript
// TypeScript
type: 'text'

// Zod
type: z.literal('text')
```

## Type Coercion

Query parameters and form data arrive as strings. Apiwork coerces them to their declared types before validation:

| Type | Input | Output |
|------|-------|--------|
| `:integer` | `"123"` | `123` |
| `:float` | `"3.14"` | `3.14` |
| `:boolean` | `"true"`, `"1"`, `"yes"` | `true` |
| `:boolean` | `"false"`, `"0"`, `"no"` | `false` |
| `:date` | `"2024-01-15"` | `Date` |
| `:datetime` | `"2024-01-15T10:00:00Z"` | `Time` |
| `:decimal` | `"99.99"` | `BigDecimal` |

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

#### See also

- [Contract::Object reference](../../../reference/contract-object.md) — all param options
