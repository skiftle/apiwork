# Associations

Schemas can include related resources. Just like your ActiveRecord associations.

## Important: Associations are NOT included by default

By default, associations are **not** serialized in responses. You must either:

1. Mark them `include: :always` to include them automatically
2. Request them explicitly with `include` param

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title

  # NOT included by default
  belongs_to :author, schema: Api::V1::UserSchema

  # Included by default
  has_many :comments, schema: Api::V1::CommentSchema, include: :always
end
```

Default response (without `include`):

```json
{
  "post": {
    "id": 1,
    "title": "My Post",
    "comments": [
      { "id": 10, "body": "Great post!" }
    ]
    // No "author" - include: :optional by default
  }
}
```

To include `author`, request it:

```
GET /api/v1/posts/1?include[author]=true
```

Response:

```json
{
  "post": {
    "id": 1,
    "title": "My Post",
    "author": {
      "id": 5,
      "name": "Alice"
    },
    "comments": [...]
  }
}
```

## belongs_to

A post belongs to an author:

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title

  # NOT included by default - use include param to get it
  belongs_to :author, schema: Api::V1::UserSchema

  # OR make it always included
  belongs_to :author, schema: Api::V1::UserSchema, include: :always
end
```

With `include: :always`, author always appears:

```json
{
  "post": {
    "id": 1,
    "title": "My Post",
    "author": {
      "id": 5,
      "name": "Alice",
      "email": "alice@example.com"
    }
  }
}
```

Without `include: :always`, use include param:

```
GET /api/v1/posts/1?include[author]=true
```

### Options

**schema** (required) - Which schema to use for serialization:

```ruby
belongs_to :author, schema: Api::V1::UserSchema
```

**include** - Control association inclusion in responses:

```ruby
belongs_to :author, schema: Api::V1::UserSchema, include: :always
```

Default: `:optional`. Clients must request with `include[author]=true`.

**filterable** - Allow filtering by association:

```ruby
belongs_to :author, schema: Api::V1::UserSchema, filterable: true
```

Enables:
```
GET /api/v1/posts?filter[author][name]=Alice
GET /api/v1/posts?filter[author][id]=5
```

You can filter by any filterable attribute in the associated schema.

**sortable** - Allow sorting by association attribute:

```ruby
belongs_to :author, schema: Api::V1::UserSchema, sortable: true
```

Enables:
```
GET /api/v1/posts?sort[author][name]=asc
```

**writable** - Allow setting the association on create/update:

```ruby
belongs_to :author, schema: Api::V1::UserSchema, writable: true
```

Enables:
```json
POST /api/v1/posts
{
  "post": {
    "title": "My Post",
    "authorId": 5
  }
}
```

Note: You set the foreign key (`authorId`), not the nested object. To set nested attributes, see [Writable Associations](./writable-associations.md).

**nullable** - Allow null association:

```ruby
belongs_to :author,
  schema: Api::V1::UserSchema,
  writable: true,
  nullable: true
```

By default, Apiwork checks your database foreign key:
- If `null: false` → required
- If `null: true` → optional

Override with `nullable: true/false` if needed.

## has_many

A post has many comments:

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title

  # NOT included by default
  has_many :comments, schema: Api::V1::CommentSchema

  # OR make it always included
  has_many :comments, schema: Api::V1::CommentSchema, include: :always
end
```

With `include: :always`, comments array always appears:

```json
{
  "post": {
    "id": 1,
    "title": "My Post",
    "comments": [
      { "id": 10, "body": "Great post!", "author": "Alice" },
      { "id": 11, "body": "Thanks!", "author": "Bob" }
    ]
  }
}
```

Without `include: :always`, use include param:

```
GET /api/v1/posts/1?include[comments]=true
```

### Options

**schema** (required):

```ruby
has_many :comments, schema: Api::V1::CommentSchema
```

**include** - Control association inclusion in responses:

```ruby
has_many :comments, schema: Api::V1::CommentSchema, include: :always
```

Default: `:optional`. Clients must request with `include[comments]=true`.

**filterable** - Filter by associated records:

```ruby
has_many :comments, schema: Api::V1::CommentSchema, filterable: true
```

Enables:
```
GET /api/v1/posts?filter[comments][body][contains]=important
GET /api/v1/posts?filter[comments][author]=Alice
```

Finds posts where at least one comment matches the filter.

**sortable** - Sort by association attributes:

```ruby
has_many :comments, schema: Api::V1::CommentSchema, sortable: true
```

**writable** - Accept nested attributes:

```ruby
has_many :comments,
  schema: Api::V1::CommentSchema,
  writable: true
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

See [Writable Associations](./writable-associations.md) for details.

**allow_destroy** - Allow deleting nested records:

```ruby
has_many :comments,
  schema: Api::V1::CommentSchema,
  writable: true,
  allow_destroy: true
```

Must also be set in the model:

```ruby
accepts_nested_attributes_for :comments, allow_destroy: true
```

Enables:
```json
PATCH /api/v1/posts/1
{
  "post": {
    "comments": [
      { "id": 10, "_destroy": true }
    ]
  }
}
```

## has_one

A user has one profile:

```ruby
class UserSchema < Apiwork::Schema::Base
  model User

  attribute :id
  attribute :name

  # NOT included by default
  has_one :profile, schema: Api::V1::ProfileSchema

  # OR make it always included
  has_one :profile, schema: Api::V1::ProfileSchema, include: :always
end
```

With `include: :always`:

```json
{
  "user": {
    "id": 1,
    "name": "Alice",
    "profile": {
      "id": 5,
      "bio": "Software developer",
      "location": "Stockholm"
    }
  }
}
```

Without, use include param:

```
GET /api/v1/users/1?include[profile]=true
```

### Options

Same as `has_many`:
- `schema` (required)
- `include` (default: false)
- `filterable`
- `sortable`
- `writable`
- `allow_destroy`

## The include parameter

Request associations dynamically:

```
# Include one association
GET /api/v1/posts/1?include[author]=true

# Include multiple
GET /api/v1/posts/1?include[author]=true&include[comments]=true

# Include nested associations
GET /api/v1/posts/1?include[comments]=true&include[comments][author]=true
```

This only works for associations declared in the schema. You can't include arbitrary relationships.

## Eager loading

Apiwork automatically eager loads associations when they're included (either via `include: :always` or `include` param):

```ruby
has_many :comments, schema: Api::V1::CommentSchema, include: :always
```

When serializing posts, Apiwork runs:
```ruby
Post.includes(:comments)
```

For nested associations:

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: Api::V1::CommentSchema, include: :always
end

class CommentSchema < Apiwork::Schema::Base
  belongs_to :author, schema: Api::V1::UserSchema, include: :always
end
```

Apiwork runs:
```ruby
Post.includes(comments: :author)
```

Automatically. No N+1 queries.

## Filtering by associations

When `filterable: true`:

```ruby
class PostSchema < Apiwork::Schema::Base
  belongs_to :author, schema: Api::V1::UserSchema, filterable: true
  has_many :comments, schema: Api::V1::CommentSchema, filterable: true
end
```

You can filter:

```
# Posts by author name
GET /api/v1/posts?filter[author][name]=Alice

# Posts by author ID
GET /api/v1/posts?filter[author][id]=5

# Posts with comments containing "important"
GET /api/v1/posts?filter[comments][body][contains]=important

# Posts with approved comments
GET /api/v1/posts?filter[comments][approved]=true
```

Apiwork generates the SQL joins automatically.

Note: `filterable` is independent of `include`. You can filter by associations that aren't included in the response.

## Association serialization

You can customize how associations are serialized by defining a method:

```ruby
has_many :comments, schema: Api::V1::CommentSchema, include: :always

def comments
  # Custom logic - return last 5 comments, newest first
  object.comments.order(created_at: :desc).limit(5)
end
```

Or computed associations:

```ruby
has_many :recent_comments, schema: Api::V1::CommentSchema, include: :always

def recent_comments
  object.comments.where('created_at > ?', 7.days.ago)
end
```

## Zod schemas and optional associations

When generating Zod schemas for TypeScript, associations without `include: :always` become optional/undefined:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title

  belongs_to :author, schema: Api::V1::UserSchema  # include: :optional (default)
  has_many :comments, schema: Api::V1::CommentSchema, include: :always
end
```

Generated Zod schema:

```typescript
export const PostSchema = z.object({
  title: z.string(),
  author: UserSchema.optional(),  // Optional - might not be included
  comments: z.array(CommentSchema)  // Always present
});
```

This is because we don't know if the client requested `include[author]=true` or not. The association might or might not be there.

If `include: :always`, it's always present (not optional).

## Nested schemas

Associations can be deeply nested:

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: Api::V1::CommentSchema, include: :always
end

class CommentSchema < Apiwork::Schema::Base
  belongs_to :author, schema: Api::V1::UserSchema, include: :always
  has_many :replies, schema: Api::V1::CommentSchema  # Self-reference
end
```

Response (with all include: :always associations):

```json
{
  "post": {
    "id": 1,
    "title": "My Post",
    "comments": [
      {
        "id": 10,
        "body": "Great!",
        "author": {
          "id": 5,
          "name": "Alice"
        }
        // "replies" not included unless requested
      }
    ]
  }
}
```

Request nested include:

```
GET /api/v1/posts/1?include[comments][replies]=true
```

Be careful with deep nesting - it can impact performance.

## Common patterns

### Always include small associations

```ruby
belongs_to :author, schema: Api::V1::UserSchema, include: :always
has_one :profile, schema: Api::V1::ProfileSchema, include: :always
```

Use `include: :always` for associations that:
- Are small (few fields)
- Are almost always needed
- Don't cause performance issues

### Opt-in for large associations

```ruby
has_many :comments, schema: Api::V1::CommentSchema  # include: :optional (default)
```

Don't use `include: :always` for associations that:
- Have many records
- Might cause N+1 queries
- Are only sometimes needed

Let clients request with `include[comments]=true`.

### Filterable without include: :always

```ruby
belongs_to :author, schema: Api::V1::UserSchema, filterable: true
# No include: :always
```

Clients can filter by author without always including author data:

```
GET /api/v1/posts?filter[author][name]=Alice
```

Response doesn't include author (unless requested with `include[author]=true`).

## Next steps

- **[Writable Associations](./writable-associations.md)** - Nested creates/updates with `accepts_nested_attributes_for`
- **[Virtual Attributes](./virtual-attributes.md)** - Computed fields
- **[Querying: Filtering](../querying/filtering.md)** - Filtering by associations
