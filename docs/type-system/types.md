---
order: 6
---

# Types

Primitive types form the foundation of the type system. Every param and attribute uses one of these types.

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

See [Unions](./unions.md) and [Custom Types](./custom-types.md).

## Usage

```ruby
param :title, type: :string
param :count, type: :integer
param :price, type: :decimal
param :active, type: :boolean
param :published_at, type: :datetime
param :birth_date, type: :date
param :start_time, type: :time
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

## Introspection

```json
{
  "title": { "type": "string", "required": true },
  "count": { "type": "integer", "required": false },
  "price": { "type": "decimal", "required": true },
  "active": { "type": "boolean", "required": false },
  "published_at": { "type": "datetime", "required": false }
}
```
