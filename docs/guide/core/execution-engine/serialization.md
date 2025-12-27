---
order: 7
---

# Serialization

Schemas can [serialize objects directly](../schemas/serialization.md). Within the Execution Engine, the adapter adds transformations for requests and responses.

## Response Serialization

When you call `expose`, the adapter serializes your data according to the schema:

```ruby
def show
  invoice = Invoice.find(params[:id])
  expose invoice
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
  "pagination": {
    "current": 1,
    "next": 2,
    "prev": null,
    "total": 5,
    "items": 100
  }
}
```

## Request Deserialization

Incoming requests go through a pipeline:

1. **Transform** — API and adapter transformations (key casing, etc.)
2. **Unwrap** — Extract data from root key wrapper
3. **Coerce** — [Convert strings to typed values](../type-system/types.md#type-coercion)
4. **Validate** — Check against [contract definitions](../contracts/introduction.md)
5. **Decode** — Apply `Schema.deserialize()` which runs decode transformers

::: info Under the Hood
The adapter delegates to `Schema.deserialize()` for the decode step. This means nested associations are automatically deserialized recursively — the same transformers you define on your schemas work both when calling `Schema.deserialize()` directly and when processing API requests.
:::

```ruby
# Incoming JSON:
{ "invoice": { "amount": "99.99", "issued_on": "2024-01-15" } }

# After deserialization:
{ amount: BigDecimal("99.99"), issued_on: Date.new(2024, 1, 15) }
```

See [Encode & Decode Transformers](../schemas/serialization.md#encode-decode-transformers) for customizing value transformations.

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
