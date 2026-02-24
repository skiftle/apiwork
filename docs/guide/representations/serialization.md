---
order: 5
---

# Serialization

Representations serialize records into plain Ruby hashes.

```ruby
PostRepresentation.serialize(post)
# => { id: 1, title: "Hello", body: "..." }
```

This is the base shape. The [adapter](../adapters/) uses it internally and transforms it for HTTP responses (adding root keys, pagination, key formatting).

`serialize` can be used directly for audit logs, webhooks, event streams, or anywhere a stable representation of the data is needed.

Collections return an array:

```ruby
PostRepresentation.serialize(posts)
# => [{ id: 1, ... }, { id: 2, ... }]
```

## Including Associations

Specific associations can be requested:

```ruby
PostRepresentation.serialize(post, include: [:comments])
PostRepresentation.serialize(post, include: [:author, :comments])
```

## Context

Context data can be passed to serialization:

```ruby
PostRepresentation.serialize(post, context: { current_user: current_user })
```

Context is accessible in computed attributes:

```ruby
class PostRepresentation < Apiwork::Representation::Base
  attribute :can_edit, type: :boolean

  def can_edit
    context[:current_user]&.can_edit?(record)
  end
end
```

The `context` and `record` accessors are available in all representation methods.

## Deserialization

The opposite of `serialize` — transforms incoming data using decode transformers:

```ruby
InvoiceRepresentation.deserialize(params[:invoice])
# => { email: "user@example.com", notes: nil }
```

Use this for processing request payloads, webhooks, imports, or any external data that needs normalization before use.

Collections work the same way:

```ruby
InvoiceRepresentation.deserialize(params[:invoices])
# => [{ email: "user@example.com" }, { email: "other@example.com" }]
```

## Nested Associations

Deserialization handles nested writes recursively:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :number, type: :string
  attribute :email, decode: ->(v) { v.downcase.strip }
  has_many :lines, representation: LineRepresentation
end

class LineRepresentation < Apiwork::Representation::Base
  attribute :amount, decode: ->(v) { BigDecimal(v.to_s) }
end
```

```ruby
InvoiceRepresentation.deserialize({
  number: 'INV-001',
  email: '  USER@EXAMPLE.COM  ',
  lines: [{ amount: '99.99' }]
})
# => { number: 'INV-001', email: 'user@example.com', lines: [{ amount: BigDecimal('99.99') }] }
```

Both `has_one` and `has_many` associations are deserialized using their representation's decode transformers.

::: info
`Representation.deserialize()` applies decode transformers. The built-in adapter's transformation of nested payload attributes (`lines` to `lines_attributes`) is part of the adapter pipeline and is not included in `deserialize`.
:::

## Encode & Decode Transformers

Define transformers on attributes to customize serialization and deserialization. See [Encode & Decode](attributes/encode-decode.md) and [Empty & Nullable](attributes/encode-decode.md#empty-nullable) for details.

#### See also

- [Representation::Base reference](../../reference/representation/base.md) — `serialize` and `deserialize` methods
