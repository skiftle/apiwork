---
order: 5
---

# Serialization

Call `serialize` with a record to get a plain Ruby hash:

```ruby
PostRepresentation.serialize(post)
# => { id: 1, title: "Hello", body: "..." }
```

This is the base format. The [adapter](../adapters/introduction.md) uses it internally and transforms it for HTTP responses (adding root keys, pagination, key formatting).

You can use `serialize` directly for audit logs, webhooks, event streams, or anywhere you need a stable representation of your data.

Collections return an array:

```ruby
PostRepresentation.serialize(posts)
# => [{ id: 1, ... }, { id: 2, ... }]
```

## Including Associations

Request specific associations:

```ruby
PostRepresentation.serialize(post, include: [:comments])
PostRepresentation.serialize(post, include: [:author, :comments])
```

## Context

Pass context data to serialization:

```ruby
PostRepresentation.serialize(post, context: { current_user: current_user })
```

Access context in computed attributes:

```ruby
class PostRepresentation < Apiwork::Representation::Base
  attribute :can_edit, type: :boolean

  def can_edit
    context[:current_user]&.can_edit?(record)
  end
end
```

The `context` and `object` accessors are available in all representation methods.

## Deserialization

The inverse of `serialize` — transforms incoming data using decode transformers:

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

Deserialization handles nested data recursively:

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

::: info Adapter-Level Transformations
`Representation.deserialize()` only applies decode transformers. The built-in adapter's transformation of nested payload attributes (`lines` to `lines_attributes`) is not applied at this level — that requires going through the execution engine and adapter pipeline.
:::

## Encode & Decode Transformers

Define transformers on attributes to customize serialization and deserialization. See [Encode & Decode](attributes/encode-decode.md) and [Empty & Nullable](attributes/encode-decode.md#empty-nullable) for details.

#### See also

- [Representation::Base reference](../../../reference/representation/base.md) — `serialize` and `deserialize` methods
