# Associations

Associations define relationships between schemas.

## has_many

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: CommentSchema
end
```

## has_one

```ruby
class PostSchema < Apiwork::Schema::Base
  has_one :author, schema: UserSchema
end
```

## belongs_to

```ruby
class CommentSchema < Apiwork::Schema::Base
  belongs_to :post, schema: PostSchema
end
```

## Options

### schema

The schema class for the association (required):

```ruby
has_many :comments, schema: CommentSchema
```

### include

Control when the association is included:

```ruby
# Client must request it (default)
has_many :comments, schema: CommentSchema, include: :optional

# Always included
has_many :comments, schema: CommentSchema, include: :always
```

### writable

Allow nested attributes in create/update:

```ruby
has_many :comments, schema: CommentSchema, writable: true
```

### filterable

Enable filtering on the association:

```ruby
has_many :comments, schema: CommentSchema, filterable: true
```

### sortable

Enable sorting on the association:

```ruby
has_many :comments, schema: CommentSchema, sortable: true
```

## Including Associations

By default, associations with `include: :optional` are not included.

Client requests them via query parameter:

```
GET /api/v1/posts?include=comments
GET /api/v1/posts?include=author,comments
```

See [Serialization](./04-serialization.md).
