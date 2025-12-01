---
order: 4
---

# Serialization

Schemas serialize model objects to JSON.

## Basic Usage

```ruby
PostSchema.serialize(post)
# => { id: 1, title: "Hello", body: "..." }

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

## Response Structure

Single object:

```json
{
  "post": {
    "id": 1,
    "title": "Hello"
  }
}
```

Collection:

```json
{
  "posts": [
    { "id": 1, "title": "Hello" },
    { "id": 2, "title": "World" }
  ]
}
```

## Key Transformation

When `key_format: :camel` is set in the API:

```json
{
  "post": {
    "id": 1,
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```
