---
order: 44
prev: false
next: false
---

# Schema::Serialization

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/serialization.rb#L26)

## Class Methods

### .serialize(object_or_collection, context: = {}, include: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/serialization.rb#L26)

Serializes a record or collection using this schema.

Converts ActiveRecord objects to JSON-ready hashes based on
attribute and association definitions.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `object_or_collection` | `Object, Array` | record(s) to serialize |
| `context` | `Hash` | context data available during serialization |
| `include` | `Symbol, Array, Hash` | associations to include |

**Returns**

`Hash, Array<Hash>` — serialized data

**Example: Serialize a single record**

```ruby
InvoiceSchema.serialize(invoice)
```

**Example: Serialize with associations**

```ruby
InvoiceSchema.serialize(invoice, include: [:customer, :line_items])
```

**Example: Serialize a collection**

```ruby
InvoiceSchema.serialize(Invoice.all)
```

---
