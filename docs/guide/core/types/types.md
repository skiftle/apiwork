---
order: 2
---

# Param Types

Primitive types are the building blocks. Every param uses one of these.

## Scalar Types

| Type | Ruby | TypeScript | Zod |
|------|------|------------|-----|
| `:string` | `String` | `string` | `z.string()` |
| `:integer` | `Integer` | `number` | `z.number().int()` |
| `:number` | `Float` | `number` | `z.number()` |
| `:decimal` | `BigDecimal` | `number` | `z.number()` |
| `:boolean` | `true`, `false` | `boolean` | `z.boolean()` |
| `:date` | `Date` | `string` | `z.iso.date()` |
| `:datetime` | `DateTime`, `Time` | `string` | `z.iso.datetime()` |
| `:time` | `Time` | `string` | `z.iso.time()` |
| `:uuid` | `String` (UUID format) | `string` | `z.uuid()` |

## Special Types

| Type | Purpose | TypeScript | Zod |
|------|---------|------------|-----|
| `:binary` | Base64 encoded | `string` | `z.string()` |
| `:literal` | Exact value | literal type | `z.literal()` |
| `:unknown` | Any value | `unknown` | `z.unknown()` |

### `unknown` vs `object`

| Type | Use when | TypeScript | Zod |
|------|----------|------------|-----|
| `:unknown` | Structure is arbitrary or unknown | `unknown` | `z.unknown()` |
| `:object` | Structure is known and defined | `{ field: type }` | `z.object({...})` |

**`:unknown` — No assumptions**

JSONB columns auto-detect as `:unknown`. This is intentional:

```ruby
# Database: metadata JSONB
attribute :metadata  # type: :unknown
```

Generated TypeScript:
```typescript
metadata: unknown;
```

The client receives no type safety — they must validate at runtime.

**`:object` — Explicit shape**

Define the structure with a block:

```ruby
attribute :metadata do
  object do
    string :version
    array :tags do
      string
    end
  end
end
```

Generated TypeScript:
```typescript
metadata: {
  version: string;
  tags: string[];
};
```

Now the client has full type safety.

**When to use each:**

| Scenario | Type | Reason |
|----------|------|--------|
| User-provided JSON (arbitrary) | `:unknown` | Structure varies |
| Settings/preferences | `:object` block | Known structure |
| Metadata with representation | `:object` block | Documented fields |
| Legacy flexible data | `:unknown` | Can't guarantee structure |

### `unknown` vs `array`

The same principle applies to arrays. A JSONB column containing `["a", "b"]` is still `:unknown`:

| Type | Use when | TypeScript | Zod |
|------|----------|------------|-----|
| `:unknown` | Array structure unknown | `unknown` | `z.unknown()` |
| `:array` | Element type is known | `Type[]` | `z.array(...)` |

**`:unknown` — No assumptions**

```ruby
# Database: tags JSONB (contains ["ruby", "rails"])
attribute :tags  # type: :unknown
```

Generated TypeScript:
```typescript
tags: unknown;  // Not unknown[] — we don't even know it's an array
```

**`:array` — Explicit element type**

```ruby
attribute :tags do
  array do
    string
  end
end
```

Generated TypeScript:
```typescript
tags: string[];
```

**Array of objects:**

```ruby
attribute :line_items do
  array do
    object do
      string :sku
      integer :quantity
      decimal :price
    end
  end
end
```

Generated TypeScript:
```typescript
lineItems: {
  sku: string;
  quantity: number;
  price: number;
}[];
```

**When to use each:**

| Scenario | Type | Reason |
|----------|------|--------|
| Tags, labels, simple lists | `array { string }` | Known element type |
| Line items, addresses | `array { object {...} }` | Known structure |
| User-provided arrays | `:unknown` | Can't guarantee structure |
| Mixed-type arrays | `:unknown` | No single element type |

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
| `:number` | `number` | IEEE 754 floating-point | `format: double` |
| `:decimal` | `number` | Arbitrary precision | — |
| `:binary` | `string` | Base64-encoded bytes | `format: byte` |

**When to use which:**

- `:decimal` for money, percentages, and values where precision matters
- `:number` for scientific calculations, coordinates, and approximate values
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
| `:number` | `"3.14"` | `3.14` |
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

- [Contract::Object reference](../../../reference/contract/object.md) — all param options
