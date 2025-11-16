# Best Practices

These are patterns we've learned from building production APIs with Apiwork.

## Schema Design

### Always define computed attributes in the schema class

When you have computed attributes (virtual attributes), define them directly in the schema class with an explicit type:

```ruby
class Api::V1::UserSchema < Apiwork::Schema::Base
  model User

  attribute :id
  attribute :first_name
  attribute :last_name

  # Computed attribute - type must be explicit
  attribute :full_name, type: :string

  def full_name
    "#{object.first_name} #{object.last_name}"
  end
end
```

**Why?** It's easier to see the type at a glance. For computed attributes, there's no database column to infer from, so the type must be explicit. Keeping the attribute declaration and implementation together makes the schema easier to understand.

### Declare all attributes explicitly

Always list every attribute in your schema. Don't use mixins or inheritance to hide attributes.

```ruby
# Good - everything is visible
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title
  attribute :body
  attribute :published
  attribute :created_at
  attribute :updated_at
end

# Bad - hidden attributes
class Api::V1::PostSchema < BaseSchema  # What does BaseSchema include?
  model Post

  attribute :title
  attribute :body
  # Where are id, timestamps? Hidden in BaseSchema!
end
```

**Why?** You should be able to read a schema from top to bottom and understand exactly what's available in the API. Hidden attributes make debugging and maintenance harder.

### Be explicit by design

Apiwork is explicit by design. Always specify `sortable: true`, `filterable: true`, `writable: true` for each attribute:

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

**Why?** It's safer. Every capability is an explicit decision. No surprises.

### Use with_options sparingly and logically

If you're brave, you can use `with_options` to reduce repetition. But be careful and group logically:

```ruby
class Api::V1::ShiftSchema < Apiwork::Schema::Base
  model Shift

  # Group 1: Filterable and sortable IDs and timestamps
  with_options filterable: true, sortable: true do
    attribute :id
    attribute :account_id
    attribute :actor_id
    attribute :schedule_id
    attribute :created_at
    attribute :updated_at

    # Group 2: Also writable fields
    with_options writable: true do
      attribute :starts_at
      attribute :ends_at
      attribute :note, empty: true
      attribute :service_id
      attribute :site_id
    end
  end

  # Separate: Serializable association
  with_options filterable: true, sortable: true do
    has_one :series_occurrence,
      schema: Api::V1::SeriesOccurrenceSchema,
      serializable: true
  end
end
```

**Key principles:**
1. **Group logically** - Common characteristics together
2. **Nest thoughtfully** - Inner blocks add more options
3. **Keep associations separate** - They're different from attributes
4. **Don't over-nest** - More than 2 levels becomes hard to read

**When NOT to use `with_options`:**
- Small schemas (< 5 attributes) - explicit is clearer
- Mixed options - if every attribute has different options, don't force grouping
- When it hurts readability - explicit is better than clever

## API Response Design

### Keep responses flat - aggregate in the client

**Rule of thumb:** Only include nested associations if they're updated together (via `accepts_nested_attributes_for`) or trigger a `touch`.

```ruby
# Good - flat response with foreign keys
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title
  attribute :body
  attribute :author_id     # Just the foreign key
  attribute :category_id   # Just the foreign key
end

# Client aggregates separately:
# GET /api/v1/posts/1          → { id: 1, title: "...", author_id: 5 }
# GET /api/v1/users/5          → { id: 5, name: "Alice", ... }
# Client merges: post.author = users[post.author_id]
```

```ruby
# Bad - including belongs_to relations
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title
  attribute :body

  # Don't do this for belongs_to
  belongs_to :author,
    schema: Api::V1::UserSchema,
    serializable: true  # ← Bad: breaks caching, no nested writes anyway

  belongs_to :category,
    schema: Api::V1::CategorySchema,
    serializable: true  # ← Bad: category changes don't touch post

  # Only include if you're updating them together
  has_many :comments,
    schema: Api::V1::CommentSchema,
    serializable: true  # ← Only if accepts_nested_attributes_for :comments
end
```

**When to include associations:**

✅ **DO include** if:
- The association has `accepts_nested_attributes_for` (you're writing nested attributes)
- The association triggers `touch: true` (they update together)
- The data is truly inseparable (e.g., OrderLineItems in an Order)

❌ **DON'T include** if:
- **It's a `belongs_to` relationship** - Just include the foreign key (e.g., `author_id`) and let the client aggregate
- It's a reference to another independent resource (`belongs_to :author`, `belongs_to :category`)
- It's a large collection (`has_many :comments`)
- It changes independently of the parent

**Why?**
1. **Caching works better** - Each resource caches independently
2. **Easier to maintain** - Changes to one model don't affect another's response
3. **More flexible** - Client decides what to fetch and when
4. **Better performance** - No N+1 queries, no overfetching

### Always use stale? or fresh_when for caching

**This is one of the secrets to improving your app's speed.** So easy, yet often overlooked.

In your controllers, always use Rails caching:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def show
    post = Post.find(params[:id])

    # Check if cached
    if stale?(post)
      respond_with post
    end
  end

  def index
    posts = query(Post.all)

    # For collections, use fresh_when with array
    fresh_when posts, public: true
    respond_with posts
  end
end
```

**Why flat responses matter here:**

```ruby
# Good - simple cache key
post.cache_key  # posts/1-20240115103000

# Bad - complex nested cache key
[post, post.author, post.category, post.comments].flatten.map(&:cache_key)
```

With flat responses, caching is simple. The client aggregates data from multiple cached endpoints, each with its own simple cache key.

### Use include parameter for optional associations

When clients DO need associated data, use the `include` parameter:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title

  # Not serialized by default
  has_many :comments,
    schema: Api::V1::CommentSchema,
    serializable: false  # Default
end
```

Client requests it when needed:

```bash
# Without comments
GET /api/v1/posts/1

# With comments (client opts in)
GET /api/v1/posts/1?include[comments]=true
```

Controller handles caching:

```ruby
def show
  post = Post.find(params[:id])

  # Cache key includes included associations
  cache_key = [post]
  cache_key << post.comments.all if params.dig(:include, :comments)

  if stale?(cache_key)
    respond_with post
  end
end
```

**Best of both worlds:**
- Default response is fast and cacheable
- Clients opt into associations when needed
- Cache keys adjust based on included data

## Summary

1. **Schemas should be readable top-to-bottom** - All attributes visible, no hidden mixins
2. **Be explicit by default** - Spell out `filterable`, `sortable`, `writable`
3. **Use `with_options` carefully** - Group logically, don't over-nest
4. **Keep responses flat** - Aggregate in client, not server
5. **Only nest what you write together** - Use `serializable: true` only for `accepts_nested_attributes_for`
6. **Always use caching** - `stale?` or `fresh_when` in every action
7. **Computed attributes in schema class** - With explicit types

These patterns lead to:
- ✅ Faster APIs (better caching)
- ✅ Easier maintenance (clear schemas, independent resources)
- ✅ More flexible clients (aggregate data as needed)
- ✅ Safer APIs (explicit capabilities)
