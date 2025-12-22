---
order: 5
---

# Serialization

Calling `serialize` on a schema returns a plain Ruby hash:

```ruby
PostSchema.serialize(post)
# => { id: 1, title: "Hello", body: "..." }
```

This is the canonical format. The [Execution Engine](../execution-engine/introduction.md) uses it internally, and adapters may transform it further for HTTP responses (adding root keys, pagination, key formatting).

You can use `serialize` directly for audit logs, webhooks, event streams, or anywhere you need a stable representation of your data.

Collections return an array:

```ruby
PostSchema.serialize(posts)
# => [{ id: 1, ... }, { id: 2, ... }]
```

## Including Associations

Request specific associations:

```ruby
PostSchema.serialize(post, include: [:comments])
PostSchema.serialize(post, include: [:author, :comments])
```

## Context

Pass context data to serialization:

```ruby
PostSchema.serialize(post, context: { current_user: current_user })
```

Access context in computed attributes:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :can_edit, type: :boolean

  def can_edit
    context[:current_user]&.can_edit?(object)
  end
end
```

The `context` and `object` accessors are available in all schema methods.

## Deserialization

The inverse of `serialize` — transforms incoming data using decode transformers:

```ruby
InvoiceSchema.deserialize(params[:invoice])
# => { email: "user@example.com", notes: nil }
```

Use this for processing request payloads, webhooks, imports, or any external data that needs normalization before use.

Collections work the same way:

```ruby
InvoiceSchema.deserialize(params[:invoices])
# => [{ email: "user@example.com" }, { email: "other@example.com" }]
```

## Encode & Decode Transformers

Transformers customize how values are converted during serialization and deserialization:

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  # encode: Ruby → JSON (applied during serialize)
  attribute :amount, encode: ->(v) { v.to_s }

  # decode: JSON → Ruby (applied during deserialize)
  attribute :email, decode: ->(v) { v.downcase.strip }

  # empty: true handles "" ↔ nil conversion automatically
  attribute :notes, empty: true
end
```

| Option | Direction | Applied in |
|--------|-----------|------------|
| `encode` | Ruby → JSON | `Schema.serialize` |
| `decode` | JSON → Ruby | `Schema.deserialize` |
| `empty: true` | Both | Serializes `nil` → `""`, deserializes `""` → `nil` |

## Nested Associations

Deserialization handles nested data recursively:

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  attribute :number, type: :string
  attribute :email, decode: ->(v) { v.downcase.strip }
  has_many :lines, schema: LineSchema
end

class LineSchema < Apiwork::Schema::Base
  attribute :amount, decode: ->(v) { BigDecimal(v.to_s) }
end
```

```ruby
InvoiceSchema.deserialize({
  number: 'INV-001',
  email: '  USER@EXAMPLE.COM  ',
  lines: [{ amount: '99.99' }]
})
# => { number: 'INV-001', email: 'user@example.com', lines: [{ amount: BigDecimal('99.99') }] }
```

Both `has_one` and `has_many` associations are deserialized using their schema's decode transformers.
