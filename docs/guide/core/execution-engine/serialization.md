---
order: 6
---

# Serialization

Schemas can [serialize objects directly](../schemas/serialization.md) — but within the Execution Engine, the adapter wraps this with additional transformations for requests and responses.

This page covers the adapter's serialization pipeline: how incoming data is coerced and decoded, and how outgoing data is encoded and transformed.

## Response Serialization

When you call `respond`, the adapter serializes your data according to the schema:

```ruby
def show
  invoice = Invoice.find(params[:id])
  respond(invoice)
end
```

The built-in adapter:

1. Loads the record with eager-loaded associations (based on `?include`)
2. Serializes attributes using `encode` transformers
3. Wraps the result in the schema's root key

```json
{
  "invoice": {
    "id": 1,
    "number": "INV-001",
    "customer": { "id": 42, "name": "Acme" }
  }
}
```

For collections, the plural root key is used:

```json
{
  "invoices": [...],
  "pagination": { "page": 1, "size": 20, "total": 100 }
}
```

## Request Deserialization

Incoming requests go through a pipeline:

1. **Transform** — API and adapter transformations (key casing, etc.)
2. **Unwrap** — Extract data from root key wrapper
3. **Coerce** — Convert strings to typed values (`"123"` → `123`)
4. **Decode** — Apply `decode` transformers from attribute definitions

```ruby
# Incoming JSON:
{ "invoice": { "amount": "99.99", "issued_on": "2024-01-15" } }

# After deserialization:
{ amount: BigDecimal("99.99"), issued_on: Date.new(2024, 1, 15) }
```

See [Encode & Decode Transformers](../schemas/serialization.md#encode-decode-transformers) for customizing value transformations.

## Type Coercion

Query parameters and form data arrive as strings. The adapter coerces them based on your type definitions:

| Type | Coercion |
|------|----------|
| `:integer` | `"42"` → `42` |
| `:boolean` | `"true"` → `true`, `"1"` → `true` |
| `:date` | `"2024-01-15"` → `Date` |
| `:datetime` | `"2024-01-15T10:00:00Z"` → `Time` |
| `:decimal` | `"99.99"` → `BigDecimal` |

Coercion happens before validation, so your validators see properly typed values.

## Custom Adapters

Override the serialization pipeline in your adapter:

```ruby
class MyAdapter < Apiwork::Adapter::Base
  def transform_response(json)
    # Wrap in envelope, add metadata, etc.
    { data: json, timestamp: Time.current.iso8601 }
  end

  def transform_request(params)
    # Normalize incoming data
    params.deep_transform_keys { |k| k.to_s.underscore.to_sym }
  end
end
```
