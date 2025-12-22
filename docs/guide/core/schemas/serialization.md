---
order: 5
---

# Serialization

Calling `serialize` on a schema returns a plain Ruby hash:

```ruby
PostSchema.serialize(post)
# => { id: 1, title: "Hello", body: "..." }
```

This is the canonical format. The Execution Engine uses it internally, and adapters may transform it further for HTTP responses (adding root keys, pagination, key formatting).

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
