# Includes (Eager Loading)

Apiwork **automatically prevents N+1 queries**. You don't need to think about eager loading - the system figures out what associations to load based on:

1. **`serializable: true` associations** - Always included in responses
2. **Filter/sort params** - Associations used in queries
3. **Explicit `include` params** - Manual control when needed

Mark associations as `serializable: true` to include them in responses, and Apiwork handles the rest.

## The N+1 problem

Without includes, loading associations creates N+1 queries:

```ruby
# Controller
def index
  respond_with Post.all
end
```

```ruby
# Schema serialization iterates posts
posts.each do |post|
  post.comments  # Each iteration hits the database!
end
```

**Generated SQL**:
```sql
SELECT * FROM posts                       -- 1 query
SELECT * FROM comments WHERE post_id = 1  -- N queries (one per post)
SELECT * FROM comments WHERE post_id = 2
SELECT * FROM comments WHERE post_id = 3
...
```

For 100 posts, that's **101 queries**. This kills performance.

## The solution: Smart automatic eager loading

Apiwork **automatically** eager loads associations in three scenarios:

### 1. `serializable: true` associations (always)

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: CommentSchema, serializable: true
end
```

```bash
GET /posts
# → Auto eager-loads comments (they're in the response)
# → No include param needed!
```

**SQL**:
```sql
SELECT * FROM posts
SELECT * FROM comments WHERE post_id IN (...)  -- Auto-included!
```

### 2. Associations used in filter/sort (automatic)

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :tags, schema: TagSchema, filterable: true  # serializable: false
end
```

```bash
GET /posts?filter[tags][name]=ruby
# → Auto eager-loads tags (used in filter JOIN)
# → No N+1 even though serializable: false!
```

**SQL**:
```sql
SELECT * FROM posts
INNER JOIN tags ON tags.post_id = posts.id WHERE tags.name = 'ruby'
SELECT * FROM tags WHERE post_id IN (...)  -- Auto-included!
```

Same for sorting:

```bash
GET /posts?sort[tags][name]=asc
# → Auto eager-loads tags (used in ORDER BY)
```

### 3. Explicit include params (manual control)

```bash
GET /posts?include[author]=true
# → Include author even if serializable: false
```

## Smart eager loading in action

**No configuration needed** - it just works:

```ruby
# Schema
class PostSchema < Apiwork::Schema::Base
  has_many :comments, serializable: true   # Always in response
  has_many :tags, filterable: true         # Not in response by default
  belongs_to :author                        # Not in response by default
end
```

**Example 1: Simple GET**
```bash
GET /posts
# Auto eager-loads: { comments: {} }
# Only comments in response (serializable: true)
```

**Example 2: Filter on non-serializable**
```bash
GET /posts?filter[tags][name]=ruby
# Auto eager-loads: { comments: {}, tags: {} }
# Comments in response (serializable: true)
# Tags NOT in response but eager-loaded (prevents N+1 from JOIN)
```

**Example 3: Explicit include**
```bash
GET /posts?include[author]=true
# Auto eager-loads: { comments: {}, author: {} }
# Both comments and author in response
```

**Example 4: Opt-out with false**
```bash
GET /posts?include[comments]=false
# Auto eager-loads: {}
# Skip comments even though serializable: true
```

## Marking associations as serializable

`serializable: true` means "this association is part of the default response":

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  # Always in response + auto eager-loaded
  has_many :comments, schema: CommentSchema, serializable: true

  # Not in response unless include[tags]=true
  # But still eager-loaded if used in filter/sort!
  has_many :tags, schema: TagSchema, filterable: true
end
```

## Single association

```bash
# Include comments with posts
GET /posts?include[comments]=true
```

**Response**:
```json
{
  "ok": true,
  "posts": [
    {
      "id": 1,
      "title": "Rails Guide",
      "body": "...",
      "comments": [
        { "id": 1, "content": "Great post!" },
        { "id": 2, "content": "Thanks!" }
      ]
    },
    {
      "id": 2,
      "title": "Elixir Guide",
      "body": "...",
      "comments": []
    }
  ]
}
```

## Multiple associations

```bash
# Include both comments and tags
GET /posts?include[comments]=true&include[tags]=true
```

**Schema**:
```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: CommentSchema, serializable: true
  has_many :tags, schema: TagSchema, serializable: true
end
```

**Response**:
```json
{
  "ok": true,
  "posts": [
    {
      "id": 1,
      "title": "Rails Guide",
      "comments": [...],
      "tags": [
        { "id": 1, "name": "ruby" },
        { "id": 2, "name": "rails" }
      ]
    }
  ]
}
```

## Nested includes

Nested `serializable: true` associations are **automatically** eager-loaded:

**Schema setup**:
```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: CommentSchema, serializable: true
end

class CommentSchema < Apiwork::Schema::Base
  belongs_to :user, schema: UserSchema, serializable: true
end
```

```bash
GET /posts
# → Auto eager-loads: { comments: { user: {} } }
# → Comments AND users both auto-included (nested serializable)
```

**Generated SQL**:
```sql
SELECT * FROM posts
SELECT * FROM comments WHERE post_id IN (...)
SELECT * FROM users WHERE id IN (...)  -- Auto-included!
```

Only 3 queries for the entire nested structure - **completely automatic**.

**Response**:
```json
{
  "ok": true,
  "posts": [
    {
      "id": 1,
      "title": "Rails Guide",
      "comments": [
        {
          "id": 1,
          "content": "Great post!",
          "user": {
            "id": 1,
            "name": "Alice"
          }
        }
      ]
    }
  ]
}
```

You can also manually control nested includes:

```bash
# Override: include comments but NOT users
GET /posts?include[comments][user]=false
```

## Deep nesting

```bash
# Include comments → users → posts
GET /posts?include[comments][user][posts]=true
```

Works with any depth for any association defined in the schema (has_many, has_one, belongs_to).

**Note**: Associations with `serializable: true` are **automatically** included at all nesting levels without needing explicit include params. Associations with `serializable: false` (the default) can still be included but require explicit include params.

**Warning**: Deep nesting loads a lot of data. Use sparingly.

## Belongs_to associations

```bash
# Include the user who wrote each post
GET /posts?include[user]=true
```

**Schema**:
```ruby
class PostSchema < Apiwork::Schema::Base
  belongs_to :user, schema: UserSchema, serializable: true
end
```

**Response**:
```json
{
  "ok": true,
  "posts": [
    {
      "id": 1,
      "title": "Rails Guide",
      "user": {
        "id": 1,
        "name": "Alice"
      }
    }
  ]
}
```

## Has_one associations

```bash
# Include the featured image for each post
GET /posts?include[featured_image]=true
```

**Schema**:
```ruby
class PostSchema < Apiwork::Schema::Base
  has_one :featured_image, schema: ImageSchema, serializable: true
end
```

Works the same as `belongs_to` and `has_many`.

## Excluding associations with `include[foo]=false`

Use `include[association]=false` to opt-out of automatic includes:

### Skip `serializable: true` associations

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, serializable: true  # Auto-included by default
end
```

```bash
GET /posts?include[comments]=false
# → Skips comments (even though serializable: true)
# → Performance optimization when you don't need them
```

### Skip filter/sort auto-includes

```bash
GET /posts?filter[tags][name]=ruby&include[tags]=false
# → Uses tags for filtering (JOIN)
# → But doesn't eager-load them
# → Useful when tags aren't serializable anyway
```

**When to use `false`:**
- Performance optimization for expensive associations
- You need to filter/sort but don't need the data
- Reduce response payload size

**Default behavior without `false`:**
- `serializable: true` → Always eager-loaded and in response
- `serializable: false` + used in filter/sort → Eager-loaded but NOT in response
- `serializable: false` + not used → Not eager-loaded

## Combining with filters

**Smart auto-detection prevents N+1:**

```bash
# Filter on association - auto eager-loads!
GET /posts?filter[tags][name]=ruby
# → Auto eager-loads tags (prevents N+1 from JOIN)
# → No manual include needed!
```

**SQL**:
```sql
SELECT * FROM posts
INNER JOIN tags ON tags.post_id = posts.id WHERE tags.name = 'ruby'
SELECT * FROM tags WHERE post_id IN (...)  -- Auto-included!
```

**Important**: The filter does NOT apply to eager-loaded tags. All tags for matching posts are loaded. The filter only determines which posts match.

## Combining with sorting

**Smart auto-detection for sorts too:**

```bash
# Sort by association - auto eager-loads!
GET /posts?sort[comments][created_at]=desc
# → Auto eager-loads comments (prevents N+1 from JOIN)
```

**SQL**:
```sql
SELECT * FROM posts
LEFT JOIN comments ON comments.post_id = posts.id
ORDER BY comments.created_at DESC
SELECT * FROM comments WHERE post_id IN (...)  -- Auto-included!
```

**To sort included associations**, define ordering in the model:

```ruby
class Post < ApplicationRecord
  has_many :comments, -> { order(created_at: :desc) }
end
```

Apiwork respects ActiveRecord's default scopes and ordering.

## Combining with pagination

```bash
# Page 1 with 10 posts, include comments for those 10 posts
GET /posts?page[number]=1&page[size]=10&include[comments]=true
```

Pagination applies to the main collection, then includes load associations for that page:

```sql
SELECT * FROM posts LIMIT 10 OFFSET 0
SELECT * FROM comments WHERE post_id IN (1,2,3,4,5,6,7,8,9,10)
```

Only comments for the current page of posts are loaded.

## Performance

### When includes are efficient

```bash
GET /posts?include[user]=true
```

**Efficient** - Each post has one user:
```sql
SELECT * FROM posts              -- 100 rows
SELECT * FROM users WHERE id IN (...)  -- ~100 rows (or fewer if users repeat)
```

### When includes can be expensive

```bash
GET /posts?include[comments]=true
```

**Potentially expensive** - Each post can have many comments:
```sql
SELECT * FROM posts                    -- 100 rows
SELECT * FROM comments WHERE post_id IN (...)  -- Could be 10,000 rows!
```

If posts have 100 comments each, you're loading 10,000 comment records.

### Memory considerations

Eager loading loads all data into memory. For large associations:

```bash
# Bad: Could load millions of comments
GET /posts?page[size]=100&include[comments]=true
```

If 100 posts each have 1000 comments, that's **100,000 comment records** in memory.

**Best practices**:
- Paginate both main and nested collections (not yet supported in Apiwork)
- Limit page size when including large associations
- Only include associations you actually need
- Consider separate endpoints for detailed nested data

## Polymorphic associations

Polymorphic associations are **not supported** for includes:

```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class CommentSchema < Apiwork::Schema::Base
  # This won't work with includes
  belongs_to :commentable, polymorphic: true
end
```

Apiwork skips polymorphic associations during eager loading to avoid ambiguity.

**Workaround**: Load polymorphic associations separately in the serializer.

## Circular dependencies

Apiwork detects circular dependencies and prevents infinite loops:

```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: CommentSchema, serializable: true
end

class CommentSchema < Apiwork::Schema::Base
  belongs_to :post, schema: PostSchema, serializable: true
end
```

If you try to auto-include both directions:

```ruby
PostSchema.auto_include_associations = true
CommentSchema.auto_include_associations = true
```

Apiwork logs a `ConfigurationError` and stops recursion:

```
Circular dependency detected in CommentSchema, skipping nested includes
```

**Best practice**: Don't auto-include bidirectional associations.

## Frontend usage

### JavaScript

```javascript
// Include comments
const url = new URL('/api/v1/posts');
url.searchParams.append('include[comments]', 'true');

const response = await fetch(url);
const data = await response.json();

data.posts.forEach(post => {
  console.log(post.title);
  console.log(post.comments);  // Included automatically
});
```

### TypeScript

```typescript
// Type-safe with generated client
const response = await api.posts.index({
  include: {
    comments: true,
    tags: true
  }
});

// Response type reflects included associations
type Response = {
  ok: true;
  posts: Array<{
    id: number;
    title: string;
    comments: Comment[];  // Included
    tags: Tag[];          // Included
  }>;
};
```

### Nested includes

```javascript
// Include comments and their users
const url = new URL('/api/v1/posts');
url.searchParams.append('include[comments][user]', 'true');

const response = await fetch(url);
```

Or with the TypeScript client:

```typescript
const response = await api.posts.index({
  include: {
    comments: {
      user: true
    }
  }
});
```

## Conditional includes

Sometimes you only want to include associations for specific queries:

```javascript
// List view: no includes (fast)
const posts = await api.posts.index({
  page: { size: 20 }
});

// Detail view: include everything (slower but complete)
const postWithDetails = await api.posts.index({
  filter: { id: { equal: postId } },
  include: {
    comments: { user: true },
    tags: true,
    category: true
  }
});
```

Different endpoints can request different levels of detail based on need.

## Security

Includes respect your schema's `serializable` flag:

```ruby
class PostSchema < Apiwork::Schema::Base
  # Public association
  has_many :comments, schema: CommentSchema, serializable: true

  # Private association - never appears in responses
  has_many :edit_logs, schema: EditLogSchema, serializable: false
end
```

```bash
# Allowed
GET /posts?include[comments]=true

# Ignored - edit_logs not serializable
GET /posts?include[edit_logs]=true
```

The `edit_logs` param is silently ignored, not an error.

**Authorization**: Includes happen **after** your controller scopes data:

```ruby
def index
  # Only current user's posts
  respond_with current_user.posts
end
```

```bash
GET /posts?include[comments]=true
```

Users can only see comments for their own posts.

## Summary: How Smart Eager Loading Works

Apiwork automatically prevents N+1 queries by eager-loading associations from **three sources**:

### 1. `serializable: true` → Always eager-loaded
```ruby
has_many :comments, serializable: true
# GET /posts → Auto eager-loads comments
```

### 2. Filter/Sort → Auto-detected and eager-loaded
```bash
GET /posts?filter[tags][name]=ruby
# → Auto eager-loads tags (prevents N+1 from JOIN)

GET /posts?sort[category][name]=asc
# → Auto eager-loads category (prevents N+1 from ORDER BY)
```

### 3. Explicit `include` → Manual control
```bash
GET /posts?include[author]=true
# → Include author in response

GET /posts?include[comments]=false
# → Skip comments (opt-out)
```

**The magic:** All three sources are **automatically merged**. You never have to think about N+1 queries - Apiwork figures out what to eager-load based on your query.

## Best practices

1. **Mark response associations as `serializable: true`** - They'll auto eager-load
2. **Mark query associations as `filterable`/`sortable`** - They'll auto eager-load when used
3. **Use `include[foo]=false` sparingly** - Only for performance optimization
4. **Add database indexes** - Index foreign keys and filtered/sorted columns
5. **Combine with pagination** - Limit main collection size
6. **Profile slow queries** - Check SQL logs if performance degrades
7. **Trust the system** - Don't manually add includes unless you have a specific need

## Next steps

- [Filtering](filtering.md) - Filter main and associated records
- [Sorting](sorting.md) - Sort main collection
- [Pagination](pagination.md) - Paginate main collection
- [Combining Queries](combining.md) - Filter + sort + paginate + include
