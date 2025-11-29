# Writable Associations

Create and update nested records in a single request. Using Rails' native `accepts_nested_attributes_for`.

## The basics

Make an association writable:

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :title, writable: true
  attribute :body, writable: true

  has_many :comments,
    schema: Api::V1::CommentSchema,
    writable: true
end
```

Your model needs `accepts_nested_attributes_for`:

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments
end
```

Now you can POST:

```json
{
  "post": {
    "title": "My Post",
    "body": "Content here",
    "comments": [
      { "body": "First comment", "author": "Alice" },
      { "body": "Second comment", "author": "Bob" }
    ]
  }
}
```

Apiwork transforms `comments` → `comments_attributes` internally and Rails handles the rest.

## This is Rails native

Apiwork doesn't implement nested attributes. It uses what Rails already gives you.

Your model configuration controls the behavior:

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments,
    allow_destroy: true,
    reject_if: :all_blank,
    limit: 100
end
```

All these options work. Apiwork just validates the input structure and transforms the keys.

## Creating nested records

```json
POST /api/v1/posts
{
  "post": {
    "title": "My Post",
    "comments": [
      { "body": "Comment 1" },
      { "body": "Comment 2" }
    ]
  }
}
```

Rails creates the post and both comments in one transaction.

## Updating nested records

Include the `id` to update existing records:

```json
PATCH /api/v1/posts/1
{
  "post": {
    "comments": [
      { "id": 5, "body": "Updated comment" },
      { "body": "New comment" }
    ]
  }
}
```

This:
- Updates comment 5
- Creates a new comment
- Leaves other existing comments unchanged

## Deleting nested records

Set `_destroy: true`:

```json
PATCH /api/v1/posts/1
{
  "post": {
    "comments": [
      { "id": 5, "_destroy": true }
    ]
  }
}
```

Your model must allow it:

```ruby
accepts_nested_attributes_for :comments, allow_destroy: true
```

And your schema:

```ruby
has_many :comments,
  schema: Api::V1::CommentSchema,
  writable: true,
  allow_destroy: true
```

If not allowed, `_destroy` is rejected with a validation error.

## Replacing all nested records

Send the complete set:

```json
PATCH /api/v1/posts/1
{
  "post": {
    "comments": [
      { "id": 5, "body": "Keep this" },
      { "id": 6, "_destroy": true },
      { "body": "New comment" }
    ]
  }
}
```

Or delete all:

```json
PATCH /api/v1/posts/1
{
  "post": {
    "comments": [
      { "id": 5, "_destroy": true },
      { "id": 6, "_destroy": true }
    ]
  }
}
```

## belongs_to associations

Writable belongs_to associations set the foreign key:

```ruby
class CommentSchema < Apiwork::Schema::Base
  model Comment

  attribute :body, writable: true

  belongs_to :author,
    schema: Api::V1::UserSchema,
    writable: true
end
```

Input:

```json
POST /api/v1/comments
{
  "comment": {
    "body": "Great post!",
    "authorId": 5
  }
}
```

This sets `comment.author_id = 5`.

If you want to create nested belongs_to records, see [Nested belongs_to](#nested-belongs_to) below.

## has_one associations

Works like belongs_to for updates:

```ruby
class UserSchema < Apiwork::Schema::Base
  model User

  attribute :name, writable: true

  has_one :profile,
    schema: Api::V1::ProfileSchema,
    writable: true
end
```

Input:

```json
POST /api/v1/users
{
  "user": {
    "name": "Alice",
    "profile": {
      "bio": "Software developer",
      "location": "Stockholm"
    }
  }
}
```

Or update:

```json
PATCH /api/v1/users/1
{
  "user": {
    "profile": {
      "id": 5,
      "bio": "Updated bio"
    }
  }
}
```

Your model:

```ruby
class User < ApplicationRecord
  has_one :profile
  accepts_nested_attributes_for :profile
end
```

## Validation

Apiwork validates nested attributes:

```ruby
class CommentSchema < Apiwork::Schema::Base
  model Comment

  attribute :body, writable: true, required: true, min_length: 3
  attribute :author, writable: true, required: true
end

class PostSchema < Apiwork::Schema::Base
  has_many :comments,
    schema: Api::V1::CommentSchema,
    writable: true
end
```

Invalid input:

```json
{
  "post": {
    "comments": [
      { "body": "" }  // Too short and missing author
    ]
  }
}
```

Returns validation errors:

```json
{
  "ok": false,
  "issues": [
    {
      "path": "/post/comments/0/body",
      "message": "must be at least 3 characters"
    },
    {
      "path": "/post/comments/0/author",
      "message": "is required"
    }
  ]
}
```

## Limits

Rails supports limits on nested attributes:

```ruby
accepts_nested_attributes_for :comments, limit: 10
```

Apiwork enforces this - more than 10 items returns a validation error.

Set in schema too:

```ruby
has_many :comments,
  schema: Api::V1::CommentSchema,
  writable: true,
  max_items: 10
```

## Reject if

Rails can reject nested attributes:

```ruby
accepts_nested_attributes_for :comments,
  reject_if: :all_blank
```

This is a model-level concern. Apiwork doesn't know about it - Rails just ignores blank records.

You can also use `reject_if` with a proc:

```ruby
accepts_nested_attributes_for :comments,
  reject_if: proc { |attributes| attributes['body'].blank? }
```

## Deeply nested associations

You can nest multiple levels:

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments,
    schema: Api::V1::CommentSchema,
    writable: true
end

class CommentSchema < Apiwork::Schema::Base
  attribute :body, writable: true

  has_many :replies,
    schema: Api::V1::CommentSchema,
    writable: true
end
```

Model:

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments
end

class Comment < ApplicationRecord
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id'
  accepts_nested_attributes_for :replies
end
```

Input:

```json
{
  "post": {
    "title": "My Post",
    "comments": [
      {
        "body": "Top comment",
        "replies": [
          { "body": "Nested reply" }
        ]
      }
    ]
  }
}
```

Be careful with deep nesting - it can get complex quickly.

## Nested belongs_to

To create nested belongs_to records (not just set foreign keys):

```ruby
class CommentSchema < Apiwork::Schema::Base
  attribute :body, writable: true

  belongs_to :author,
    schema: Api::V1::UserSchema,
    writable: true,
    nested: true  # Allow creating nested author
end
```

Model:

```ruby
class Comment < ApplicationRecord
  belongs_to :author, class_name: 'User'
  accepts_nested_attributes_for :author
end
```

Input:

```json
POST /api/v1/comments
{
  "comment": {
    "body": "Great post!",
    "author": {
      "name": "Alice",
      "email": "alice@example.com"
    }
  }
}
```

This creates both the comment and the user.

But usually you don't want this - users already exist. Just use:

```json
{
  "comment": {
    "body": "Great post!",
    "authorId": 5
  }
}
```

## Common patterns

### Creating with associations

```ruby
# Post with comments
POST /api/v1/posts
{
  "post": {
    "title": "My Post",
    "comments": [
      { "body": "Comment 1" },
      { "body": "Comment 2" }
    ]
  }
}
```

### Updating some associations

```ruby
# Update specific comments, leave others unchanged
PATCH /api/v1/posts/1
{
  "post": {
    "title": "Updated title",
    "comments": [
      { "id": 5, "body": "Updated comment" }
    ]
  }
}
```

### Replacing all associations

```ruby
# Delete all existing, create new
PATCH /api/v1/posts/1
{
  "post": {
    "comments": [
      { "id": 5, "_destroy": true },
      { "id": 6, "_destroy": true },
      { "body": "New comment 1" },
      { "body": "New comment 2" }
    ]
  }
}
```

### Adding to associations

```ruby
# Just add new comments
PATCH /api/v1/posts/1
{
  "post": {
    "comments": [
      { "body": "New comment" }
    ]
  }
}
```

## Transactions

Rails wraps nested attributes in a transaction:

```ruby
Post.create(
  title: 'My Post',
  comments_attributes: [
    { body: 'Comment 1' },
    { body: 'Comment 2' }
  ]
)
```

If any record fails validation, the entire transaction rolls back.

## Performance

Creating many nested records can be slow:

```json
{
  "post": {
    "comments": [
      // 1000 comments
    ]
  }
}
```

Consider:
- Setting a `limit` in your model
- Enforcing `max_items` in your schema
- Using bulk endpoints for large creates

## Next steps

- **[Associations](./associations.md)** - Read-only associations
- **[Attributes](./attributes.md)** - Attribute options
- **[Introduction](./introduction.md)** - Back to schemas overview
- **[Contracts](../contracts/introduction.md)** - Contract validation
