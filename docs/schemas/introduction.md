# Schemas

Schemas describe your data. What fields it has, what types they are, and what you can do with them.

Think of them as the blueprint for your API resources.

## What is a schema?

A schema is a Ruby class that describes one of your models:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id, filterable: true, sortable: true
  attribute :title, filterable: true, sortable: true, writable: true
  attribute :body, writable: true
  attribute :published, filterable: true, writable: true
  attribute :created_at, sortable: true
  attribute :updated_at, sortable: true
end
```

This schema says:
- It represents the `Post` model
- It has 6 attributes
- Some can be filtered, some sorted, some written

From this, Apiwork knows how to:
- Serialize posts to JSON
- Parse filter queries
- Apply sorting
- Validate input for create/update

## Schemas inherit from your database

Your database already knows about types:

```ruby
# db/migrate/xxx_create_posts.rb
create_table :posts do |t|
  t.string :title, null: false           # String, required
  t.text :body, null: false              # Text (string), required
  t.boolean :published, default: false   # Boolean, optional
  t.integer :view_count, default: 0      # Integer, optional
  t.timestamps
end
```

Apiwork reads these column definitions:

```ruby
attribute :title
# Apiwork knows:
# - type: string (from database column)
# - required: true (from null: false) when writable: true
# - max_length: 255 (default string limit)

attribute :published
# Apiwork knows:
# - type: boolean
# - required: false (has default value)
# - default: false

attribute :view_count
# Apiwork knows:
# - type: integer
# - required: false (has default value)
# - default: 0
```

You don't repeat yourself. The database is the single source of truth.

## What can attributes do?

Each attribute has flags that control its behavior:

### filterable

Users can filter by this field:

```ruby
attribute :published, filterable: true
```

Enables:
```
GET /api/v1/posts?filter[published]=true
```

The filter operators available depend on the attribute type:
- **Boolean**: `equal`
- **String**: `equal`, `not_equal`, `contains`, `starts_with`, `ends_with`, `in`, `not_in`
- **Integer**: `equal`, `not_equal`, `greater_than`, `greater_than_or_equal`, `less_than`, `less_than_or_equal`, `in`, `not_in`
- **Date/DateTime**: `equal`, `not_equal`, `greater_than`, `greater_than_or_equal`, `less_than`, `less_than_or_equal`, `between`

See [Querying: Filtering](../querying/filtering.md) for all operators.

### sortable

Users can sort by this field:

```ruby
attribute :created_at, sortable: true
```

Enables:
```
GET /api/v1/posts?sort[created_at]=desc
```

Can sort ascending (`asc`) or descending (`desc`).

### writable

Users can set this field when creating or updating:

```ruby
attribute :title, writable: true
```

Makes `title` available in create/update inputs:
```
POST /api/v1/posts
{
  "post": {
    "title": "My Post"  ← Allowed because writable: true
  }
}
```

If not writable, the field is read-only:
```ruby
attribute :id  # Not writable
attribute :created_at  # Not writable
```

Users can see these fields in responses but can't set them.

### Combining flags

Most attributes combine multiple flags:

```ruby
# Can filter, sort, and write
attribute :title, filterable: true, sortable: true, writable: true

# Can filter but not write (read-only)
attribute :published, filterable: true

# Just for display
attribute :id
```

Common patterns:

```ruby
# IDs - filter and sort only
attribute :id, filterable: true, sortable: true

# User input - write, filter, sort
attribute :title, filterable: true, sortable: true, writable: true

# Timestamps - sort only
attribute :created_at, sortable: true
attribute :updated_at, sortable: true

# Booleans - filter and write
attribute :published, filterable: true, writable: true

# Computed/derived - display only
attribute :full_name
```

## Serialization

Schemas control what appears in JSON responses:

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title
  attribute :body
  attribute :published
  attribute :created_at
  attribute :updated_at
end
```

When you `respond_with` a post:

```ruby
def show
  post = Post.find(params[:id])
  respond_with post
end
```

You get:

```json
{
  "ok": true,
  "post": {
    "id": 1,
    "title": "My Post",
    "body": "Content here",
    "published": false,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

Notice:
- Only attributes declared in the schema appear
- Keys are transformed to camelCase (configurable)
- Timestamps are ISO 8601 formatted

## Associations

Schemas can include related resources:

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title
  attribute :body

  # Include author
  belongs_to :author, schema: Api::V1::UserSchema

  # Include comments
  has_many :comments, schema: Api::V1::CommentSchema
end
```

Now responses include nested data:

```json
{
  "post": {
    "id": 1,
    "title": "My Post",
    "author": {
      "id": 5,
      "name": "Alice"
    },
    "comments": [
      { "id": 10, "body": "Great post!" },
      { "id": 11, "body": "Thanks!" }
    ]
  }
}
```

And you can filter by associations:

```
GET /api/v1/posts?filter[author][name]=Alice
```

See [Schemas: Associations](./associations.md) for details.

## Type inference

Apiwork infers types from your database columns:

| Database Type | Schema Type | Notes |
|---------------|-------------|-------|
| `string`, `text` | `:string` | Uses column limit if present |
| `integer`, `bigint` | `:integer` | |
| `float`, `decimal` | `:float` | Decimal becomes float in JSON |
| `boolean` | `:boolean` | |
| `date` | `:date` | ISO 8601 format |
| `datetime`, `timestamp` | `:datetime` | ISO 8601 with timezone |
| `json`, `jsonb` | `:object` | Preserved as-is |
| `array` | `:array` | PostgreSQL arrays |

You can override types if needed:

```ruby
# Database column: text (unlimited)
# But you want to enforce a limit in the API
attribute :body, type: :string, max_length: 10_000
```

See [Schemas: Types](./types.md) for all available types.

## Required fields

When an attribute is `writable: true`, Apiwork checks if it's required based on your database:

```ruby
# Migration
t.string :title, null: false     # Required
t.string :subtitle               # Optional (null: true is default)
t.boolean :published, default: false  # Optional (has default)
```

Schema:

```ruby
attribute :title, writable: true
# → required: true in create action (null: false in DB)

attribute :subtitle, writable: true
# → required: false in create/update (null: true in DB)

attribute :published, writable: true
# → required: false (has default value)
```

This happens automatically. Change your migration, the API adapts.

You can override if needed:

```ruby
attribute :title, writable: true, required: false
```

But usually, you shouldn't. Let the database be the source of truth.

## Virtual attributes

Add attributes that aren't database columns:

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title

  # Virtual attribute
  attribute :word_count, type: :integer

  def word_count
    object.body.split.size
  end
end
```

Now responses include:

```json
{
  "post": {
    "id": 1,
    "title": "My Post",
    "wordCount": 42
  }
}
```

The `word_count` method is called on the schema instance, with `object` being the Post record.

See [Schemas: Virtual Attributes](./virtual-attributes.md) for details.

## Nested attributes (writable associations)

Make associations writable so users can create/update nested records:

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
  accepts_nested_attributes_for :comments, allow_destroy: true
end
```

Now you can POST:

```json
{
  "post": {
    "title": "My Post",
    "comments": [
      { "body": "First comment" },
      { "body": "Second comment" }
    ]
  }
}
```

Apiwork transforms `comments` to `comments_attributes` internally and lets Rails handle the rest.

See [Schemas: Writable Associations](./writable-associations.md).

## Schema organization

Organize schemas by API version:

```
app/schemas/
  api/
    v1/
      post_schema.rb
      user_schema.rb
      comment_schema.rb
    v2/
      post_schema.rb
      article_schema.rb
```

Each version has independent schemas. V2 can completely redefine what a post looks like without affecting V1.

## What schemas don't do

Schemas are for **description**, not **validation**.

Validation lives in contracts:

```ruby
# Schema - describes what exists
class PostSchema < Apiwork::Schema::Base
  attribute :title, writable: true
end

# Contract - validates inputs
class PostContract < Apiwork::Contract::Base
  schema PostSchema

  action :create do
    input do
      param :title, type: :string, required: true, min_length: 5
    end
  end
end
```

But often, you don't need explicit validation. `schema PostSchema` auto-generates validation based on writable attributes and database constraints.

## Next steps

- **[Attributes](./attributes.md)** - Deep dive into attribute options
- **[Associations](./associations.md)** - belongs_to, has_many, has_one
- **[Types](./types.md)** - All available types and their behavior
- **[Virtual Attributes](./virtual-attributes.md)** - Computed fields
- **[Writable Associations](./writable-associations.md)** - Nested creates/updates
