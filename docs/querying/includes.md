# Includes (Eager Loading)

Include associated records in your response and prevent N+1 queries automatically. Mark associations as `serializable: true` and use `include` params to control what gets loaded.

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

## The solution: Eager loading

```bash
GET /posts?include[comments]=true
```

Apiwork automatically uses `.includes()`:

**Generated SQL**:
```sql
SELECT * FROM posts                              -- 1 query
SELECT * FROM comments WHERE post_id IN (1,2,3)  -- 1 query
```

Only **2 queries total**, regardless of how many posts.

## Basic syntax

```bash
GET /posts?include[association_name]=true
```

**Format**: `include[association_name]=true|false`

Set to `true` to include the association, `false` or omit to exclude.

## Marking associations as serializable

Associations must be marked `serializable: true` in your schema:

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :title
  attribute :body

  # Without serializable: comments won't appear in response
  has_many :comments, schema: CommentSchema

  # With serializable: can be included via include params
  has_many :comments, schema: CommentSchema, serializable: true
end
```

Now comments can be included:

```bash
GET /posts?include[comments]=true
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

Include associations of associations:

```bash
# Include comments, and include the user for each comment
GET /posts?include[comments][user]=true
```

**Schema setup**:
```ruby
class PostSchema < Apiwork::Schema::Base
  has_many :comments, schema: CommentSchema, serializable: true
end

class CommentSchema < Apiwork::Schema::Base
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

**Generated SQL**:
```sql
SELECT * FROM posts
SELECT * FROM comments WHERE post_id IN (...)
SELECT * FROM users WHERE id IN (...)
```

Only 3 queries for the entire nested structure.

## Deep nesting

```bash
# Include comments → users → posts
GET /posts?include[comments][user][posts]=true
```

Works with any depth, as long as all associations are marked `serializable: true`.

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

## Excluding associations

By default, associations are **not** included unless:
1. Explicitly requested via `include` params
2. Or schema has `auto_include_associations = true`

```bash
# Don't include comments
GET /posts
GET /posts?include[comments]=false
```

Both return posts without comments.

## Auto-including associations

Force associations to always be included:

```ruby
class PostSchema < Apiwork::Schema::Base
  self.auto_include_associations = true

  has_many :comments, schema: CommentSchema, serializable: true
end
```

Now comments are **always** included, even without `include` params:

```bash
GET /posts
# Comments are included automatically
```

You can still exclude them explicitly:

```bash
GET /posts?include[comments]=false
# Comments are excluded
```

**Use cases**:
- Critical associations that are always needed
- Small associations with minimal overhead
- APIs where you control the frontend and always need the data

**Warning**: Auto-including large associations can hurt performance.

## Combining with filters

```bash
# Published posts with their comments
GET /posts?filter[published][equal]=true&include[comments]=true
```

Filtering applies to the main collection, includes apply to associations:

```sql
SELECT * FROM posts WHERE published = true
SELECT * FROM comments WHERE post_id IN (...)
```

**Important**: The filter does NOT apply to the included comments. All comments for filtered posts are loaded.

If you want to filter comments, use association filtering (see [Filtering](filtering.md#association-filtering)).

## Combining with sorting

```bash
# Sort posts by title, include comments
GET /posts?sort[title]=asc&include[comments]=true
```

Sorting applies to the main collection, not to included associations:

```sql
SELECT * FROM posts ORDER BY title ASC
SELECT * FROM comments WHERE post_id IN (...)
```

Comments appear in database order (usually by id).

**To sort included associations**, you'd need to define ordering in the association:

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

## Best practices

1. **Mark only needed associations as serializable** - Don't expose internal data
2. **Include only what you need** - More data = slower response
3. **Combine with pagination** - Limit main collection size
4. **Profile slow queries** - Check SQL logs for inefficient includes
5. **Add database indexes** - Index foreign keys for faster joins
6. **Avoid deep nesting** - Keep includes shallow for performance
7. **Use separate endpoints** - For detailed nested data, consider dedicated routes
8. **Don't auto-include large associations** - Reserve auto-include for small data

## Next steps

- [Filtering](filtering.md) - Filter main and associated records
- [Sorting](sorting.md) - Sort main collection
- [Pagination](pagination.md) - Paginate main collection
- [Combining Queries](combining.md) - Filter + sort + paginate + include
