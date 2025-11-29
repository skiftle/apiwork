# Polymorphic Associations

Schemas support Rails polymorphic associations.

## Basic Setup

```ruby
class CommentSchema < Apiwork::Schema::Base
  attribute :content

  belongs_to :commentable, polymorphic: true
end
```

## How It Works

With a polymorphic association:

```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable
end

class Article < ApplicationRecord
  has_many :comments, as: :commentable
end
```

Apiwork serializes the association based on the actual type:

```json
{
  "comment": {
    "id": 1,
    "content": "Great post!",
    "commentable": {
      "type": "Post",
      "id": 42
    }
  }
}
```

## Including Polymorphic Data

When including the polymorphic association:

```
GET /api/v1/comments/1?include=commentable
```

The response includes the full object based on its type:

```json
{
  "comment": {
    "id": 1,
    "content": "Great post!",
    "commentable": {
      "type": "Post",
      "id": 42,
      "title": "Hello World"
    }
  }
}
```
