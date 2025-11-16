# Attributes

Attributes are the building blocks of schemas. Each one represents a field in your data.

## Basic syntax

```ruby
attribute :name
```

That's it. Apiwork pulls the type from your database column.

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title
  attribute :body
  attribute :published
  attribute :created_at
end
```

## Options

### type

Override the inferred type:

```ruby
attribute :body, type: :string
```

Available types:
- `:string` - Text data
- `:integer` - Whole numbers
- `:float` - Decimal numbers
- `:boolean` - true/false
- `:date` - Date without time
- `:datetime` - Date with time
- `:object` - JSON objects
- `:array` - Arrays

See [Types](./types.md) for complete type reference.

### filterable

Make the attribute filterable:

```ruby
attribute :title, filterable: true
```

Enables:
```
GET /api/v1/posts?filter[title]=Hello
GET /api/v1/posts?filter[title][contains]=world
```

The available filter operators depend on the type:

**String:**
```
filter[title][equal]=Hello
filter[title][not_equal]=Goodbye
filter[title][contains]=world
filter[title][starts_with]=Hello
filter[title][ends_with]=world
filter[title][in][]=Hello&filter[title][in][]=Goodbye
```

**Integer:**
```
filter[view_count][equal]=100
filter[view_count][greater_than]=50
filter[view_count][less_than]=200
filter[view_count][between][]=50&filter[view_count][between][]=200
filter[view_count][in][]=10&filter[view_count][in][]=20
```

**Boolean:**
```
filter[published][equal]=true
filter[published]=true  # Shorthand
```

**Date/DateTime:**
```
filter[created_at][greater_than]=2024-01-01
filter[created_at][less_than]=2024-12-31
filter[created_at][between][]=2024-01-01&filter[created_at][between][]=2024-12-31
```

See [Querying: Filtering](../querying/filtering.md) for all operators.

### sortable

Make the attribute sortable:

```ruby
attribute :created_at, sortable: true
```

Enables:
```
GET /api/v1/posts?sort[created_at]=desc
GET /api/v1/posts?sort[created_at]=asc
```

Multiple sorts:
```
GET /api/v1/posts?sort[published]=desc&sort[created_at]=desc
```

### writable

Make the attribute writable (can be set by users):

```ruby
attribute :title, writable: true
```

Makes `title` available in create/update actions:

```json
POST /api/v1/posts
{
  "post": {
    "title": "My Post"
  }
}
```

When `writable: true`, Apiwork checks your database to determine if it's required:

```ruby
# Migration: t.string :title, null: false
attribute :title, writable: true
# → required: true in create action

# Migration: t.string :subtitle
attribute :subtitle, writable: true
# → required: false (null: true)

# Migration: t.boolean :published, default: false
attribute :published, writable: true
# → required: false (has default)
```

You can specify which actions make it writable:

```ruby
attribute :title, writable: { on: [:create] }  # Only writable on create
attribute :status, writable: { on: [:update] }  # Only writable on update
```

### required

Override the auto-detected required flag:

```ruby
attribute :title, writable: true, required: false
```

Now `title` is optional even if the database has `null: false`.

You'd do this if you want to set a default in your controller:

```ruby
def create
  params = action_params
  params[:title] ||= "Untitled"
  post = Post.create(params)
  respond_with post, status: :created
end
```

But usually, let the database be the source of truth. Don't override `required` unless you have a good reason.

### enum

Restrict values to a specific set:

```ruby
attribute :status, writable: true, enum: ['draft', 'published', 'archived']
```

For Rails enums, this is auto-detected:

```ruby
# Model
class Post < ApplicationRecord
  enum status: { draft: 0, published: 1, archived: 2 }
end

# Schema - enum values auto-detected
attribute :status, filterable: true, writable: true
# Automatically gets enum: ['draft', 'published', 'archived']
```

### serialize / deserialize

Custom serialization/deserialization transformers:

```ruby
attribute :title, serialize: ->(value) { value.upcase }
attribute :tags, deserialize: ->(value) { value.map(&:downcase) }
```

Built-in transformers:

```ruby
attribute :bio, empty: true
# Converts nil → '' on serialize, '' → nil on deserialize
```

The `empty` option only works on string/text attributes.

## Common patterns

### Read-only ID

```ruby
attribute :id, filterable: true, sortable: true
```

Users can filter and sort by ID, but can't set it (not writable).

### User-editable content

```ruby
attribute :title, filterable: true, sortable: true, writable: true
attribute :body, writable: true
```

Users can read, write, filter, and sort the title. They can write the body but not filter/sort it (too large).

### Timestamps

```ruby
attribute :created_at, sortable: true
attribute :updated_at, sortable: true
```

Read-only, but sortable.

### Booleans

```ruby
attribute :published, filterable: true, writable: true
```

Users can filter published posts and toggle the flag.

### Enums

```ruby
# Model
class Post < ApplicationRecord
  enum status: { draft: 0, published: 1, archived: 2 }
end

# Schema
attribute :status, filterable: true, writable: true
# enum values auto-detected from model
```

Apiwork serializes enums as strings:

```json
{
  "post": {
    "status": "published"
  }
}
```

And accepts them as strings:

```json
POST /api/v1/posts
{
  "post": {
    "status": "draft"
  }
}
```

### Computed fields (virtual attributes)

```ruby
attribute :word_count, type: :integer

def word_count
  object.body.to_s.split.size
end
```

Not in the database, computed on the fly.

See [Virtual Attributes](./virtual-attributes.md).

## Type inference

If you don't specify `type`, Apiwork infers it from your database:

```ruby
# Migration
t.string :title
t.text :body
t.integer :view_count
t.boolean :published
t.datetime :published_at
t.json :metadata

# Schema - types inferred automatically
attribute :title        # → type: :string
attribute :body         # → type: :string (text becomes string)
attribute :view_count   # → type: :integer
attribute :published    # → type: :boolean
attribute :published_at # → type: :datetime
attribute :metadata     # → type: :object (json becomes object)
```

Override if needed:

```ruby
attribute :metadata, type: :string  # Serialize JSON as string
```

## Attribute order

Attributes appear in JSON in the order you define them:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :id
  attribute :title
  attribute :body
end
```

Output:
```json
{
  "post": {
    "id": 1,
    "title": "...",
    "body": "..."
  }
}
```

Reorder in the schema to change JSON order.

## Excluding attributes

Don't include attributes you don't want to expose:

```ruby
class UserSchema < Apiwork::Schema::Base
  model User

  attribute :id
  attribute :name
  attribute :email
  # Don't include:
  # - password_digest
  # - reset_token
  # - internal_notes
end
```

Only declared attributes appear in responses.

## Attribute inheritance

Schemas can inherit attributes:

```ruby
class BaseSchema < Apiwork::Schema::Base
  attribute :id, filterable: true, sortable: true
  attribute :created_at, sortable: true
  attribute :updated_at, sortable: true
end

class PostSchema < BaseSchema
  model Post

  attribute :title, filterable: true, sortable: true, writable: true
  attribute :body, writable: true
end
```

`PostSchema` now has all attributes from `BaseSchema` plus its own.

Override inherited attributes:

```ruby
class PostSchema < BaseSchema
  attribute :updated_at, sortable: true, filterable: true  # Add filterable
end
```

## Next steps

- **[Associations](./associations.md)** - belongs_to, has_many, has_one
- **[Types](./types.md)** - All available types and their behavior
- **[Virtual Attributes](./virtual-attributes.md)** - Computed fields
- **[Writable Associations](./writable-associations.md)** - Nested creates/updates
