---
order: 5
---

# Encode & Decode

Transform values during serialization and handle nil/empty conversion.

## Transforms

Transform values during serialization (`encode`) and deserialization (`decode`). Use for presentation transforms — case changes, formatting, normalization.

| Option | When | Direction |
|--------|------|-----------|
| `encode` | Response (output) | Database to API |
| `decode` | Request (input) | API to Database |

::: info Serialization-only
These transformations must preserve the attribute's type. They operate at the serialization layer and are not passed to adapters — invisible to generated TypeScript, Zod, and OpenAPI exports.
:::

```ruby
# Case normalization: "Invoice" becomes "invoice"
attribute :subjectable_type, encode: ->(v) { v&.underscore }

# Consistent enum format: "pending" becomes "PENDING"
attribute :status,
  encode: ->(v) { v&.upcase },
  decode: ->(v) { v&.downcase }
```

For null/empty string conversion, use [`empty: true`](#empty-nullable) instead — it affects generated types.

### Prefer ActiveRecord Normalizes

For data integrity, use Rails' built-in `normalizes` instead — it applies everywhere, not just through the API:

```ruby
class Customer < ApplicationRecord
  normalizes :email, with: ->(v) { v&.strip&.downcase }
end
```

## Empty & Nullable

Two options for handling null and empty values.

| Option           | Accepts `null` | Accepts `""` | Stores | Returns |
| ---------------- | -------------- | ------------ | ------ | ------- |
| Default          | No             | Yes          | As-is  | As-is   |
| `nullable: true` | Yes            | Yes          | As-is  | As-is   |
| `empty: true`    | No             | Yes          | `nil`  | `""`    |

### nullable: true

Allow null values in requests and responses:

```ruby
attribute :bio, nullable: true, writable: true
```

```json
// Request - both valid:
{ "customer": { "bio": "Hello" } }
{ "customer": { "bio": null } }

// Response - returns as stored:
{ "customer": { "bio": null } }
```

### empty: true

Convert between `nil` (database) and `""` (API):

```ruby
attribute :name, empty: true, writable: true
```

```json
// Request with empty string:
{ "customer": { "name": "" } }
// Stored as: nil

// Database has nil:
// Response returns:
{ "customer": { "name": "" } }
```

Your database stores `NULL` for missing values, but your frontend expects empty strings. `empty: true` handles the conversion.

## Examples

- [Encode/Decode/Empty](/examples/encode-decode-empty.md) — Transform values during serialization and handle nil/empty conversion
