---
order: 8
---

# Serialization

The standard adapter serializes responses and deserializes requests using [representation](../../representations/serialization.md) transformers.

## Response Serialization

The adapter serializes records according to the representation when `expose` is called:

```ruby
def show
  invoice = Invoice.find(params[:id])
  expose invoice
end
```

The adapter:

1. Loads the record with eager-loaded associations (based on `?include`)
2. Serializes attributes using `encode` transformers
3. Wraps the result in the representation's root key

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
3. **Coerce** — [Convert strings to typed values](../../types/types.md#type-coercion)
4. **Validate** — Check against [contract definitions](../../contracts/)
5. **Decode** — Apply `Representation.deserialize()` which runs decode transformers

::: info
The adapter uses `Representation.deserialize()` for decoding. Nested associations are deserialized recursively using the same transformers.
:::

```ruby
# Incoming JSON:
{ "invoice": { "amount": "99.99", "issued_on": "2024-01-15" } }

# After deserialization:
{ amount: BigDecimal("99.99"), issued_on: Date.new(2024, 1, 15) }
```

See [Encode & Decode Transformers](../../representations/serialization.md#encode-decode-transformers) for customizing value transformations.

For nested write operations (create, update, delete), see [Writing](./writing.md).

## Custom Adapters

To customize request or response transformation, create [capability transformers](../custom-adapters/capabilities/transformers.md). Request transformers run before or after validation. Response transformers modify outgoing data.

#### See also

- [Adapter::Base reference](../../../reference/adapter/base.md) — creating custom adapters
