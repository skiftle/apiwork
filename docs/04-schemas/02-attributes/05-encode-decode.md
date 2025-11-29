# Encode & Decode

Transform values during serialization (encode) and deserialization (decode).

## Overview

| Option | When | Direction |
|--------|------|-----------|
| `encode` | Response (output) | Database → API |
| `decode` | Request (input) | API → Database |

## Basic Usage

```ruby
attribute :email,
  encode: ->(value) { value&.downcase },
  decode: ->(value) { value&.strip&.downcase }
```

- **encode**: Email is always lowercase in API responses
- **decode**: Email is stripped and lowercased before saving

## Transformer Types

### Lambda / Proc

```ruby
attribute :name, encode: ->(value) { value&.titleize }
attribute :slug, decode: ->(value) { value&.parameterize }
```

### Symbol (Built-in)

```ruby
attribute :bio, encode: :nil_to_empty    # nil → ""
attribute :bio, decode: :blank_to_nil    # "" → nil
```

### Array (Multiple Transformers)

Applied in order:

```ruby
attribute :email,
  encode: [->(v) { v&.downcase }, :nil_to_empty],
  decode: [->(v) { v&.strip }, ->(v) { v&.downcase }, :blank_to_nil]
```

## Built-in Transformers

| Symbol | Effect |
|--------|--------|
| `:nil_to_empty` | Converts `nil` to `""` |
| `:blank_to_nil` | Converts `""` or whitespace to `nil` |

## Practical Examples

### Email Normalization

Store lowercase, display lowercase:

```ruby
attribute :email,
  writable: true,
  encode: ->(v) { v&.downcase },
  decode: ->(v) { v&.strip&.downcase }
```

### Phone Formatting

Store digits only, display formatted:

```ruby
attribute :phone,
  writable: true,
  encode: ->(v) { v&.gsub(/\D/, '')&.gsub(/(\d{3})(\d{3})(\d{4})/, '(\1) \2-\3') },
  decode: ->(v) { v&.gsub(/\D/, '') }
```

Request: `"(555) 123-4567"` → Database: `"5551234567"` → Response: `"(555) 123-4567"`

### Currency Display

Store cents, display dollars:

```ruby
attribute :price_cents
attribute :price,
  type: :string,
  encode: ->(v) { v ? "$#{(v / 100.0).round(2)}" : nil }

def price
  object.price_cents
end
```

### JSON Field

Serialize/deserialize JSON:

```ruby
attribute :settings,
  encode: ->(v) { v.is_a?(String) ? JSON.parse(v) : v },
  decode: ->(v) { v.is_a?(Hash) ? v.to_json : v }
```

## Lifecycle

```
┌─────────────────────────────────────────────────────────┐
│                      REQUEST                            │
│  Client → JSON body → decode transformer → Model.save   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                      RESPONSE                           │
│  Model.attribute → encode transformer → JSON → Client   │
└─────────────────────────────────────────────────────────┘
```

## With Enums

Encode runs after enum validation:

```ruby
attribute :status,
  encode: ->(v) { v&.upcase }  # "draft" → "DRAFT"
```

## See Also

- [Empty & Nullable](./06-empty-nullable.md) - The `empty` option uses encode/decode internally
