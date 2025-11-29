# Querying

Apiwork provides automatic filtering, sorting, pagination, and eager loading for your index routes. You don't implement these features - you just mark which fields are queryable in your schema, and Apiwork handles the rest.

**The key insight:** Queries are separate from schemas, but schemas define what's possible through flags like `filterable`, `sortable`, and `include`.

## How it works

### 1. Mark fields as queryable in your schema

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  # These flags enable querying
  attribute :title, filterable: true, sortable: true
  attribute :published, filterable: true, sortable: true
  attribute :created_at, filterable: true, sortable: true

  # Associations can be queryable too
  has_many :comments,
    schema: CommentSchema,
    filterable: true,  # Filter posts by comment fields
    sortable: true,    # Sort posts by comment fields
    include: :always # Include comments in response
end
```

That's it. No query code to write.

### 2. Queries auto-activate for index routes

When someone hits your index endpoint:

```ruby
class PostsController < ApplicationController
  def index
    respond_with Post.all  # Query happens automatically
  end
end
```

Apiwork automatically:
- Validates query params against auto-generated contract
- Applies filters, sorting, pagination
- Prevents N+1 queries with eager loading
- Returns pagination metadata

### 3. Users query via URL parameters

```bash
# Filter published posts containing "Rails"
GET /api/v1/posts?filter[published][equal]=true&filter[title][contains]=Rails

# Sort by title descending
GET /api/v1/posts?sort[title]=desc

# Paginate: page 2, 10 items per page
GET /api/v1/posts?page[number]=2&page[size]=10

# Include associated comments
GET /api/v1/posts?include[comments]=true

# Combine everything
GET /api/v1/posts?filter[published][equal]=true&sort[created_at]=desc&page[number]=1&page[size]=5&include[comments]=true
```

## The complete flow

Here's what happens under the hood:

```
1. Schema defines capabilities
   ├─ attribute :title, filterable: true, sortable: true
   └─ has_many :comments, filterable: true

2. Contract auto-generates query params (index action)
   ├─ param :filter, type: :post_filter
   │  ├─ Validates filter operators per field type
   │  └─ Supports nested association filters
   ├─ param :sort, type: :post_sort
   │  └─ Enum: asc or desc per sortable field
   ├─ param :page, type: :page_params
   │  └─ number and size
   └─ param :include, type: :post_include
      └─ Boolean flags for associations

3. Request comes in
   GET /api/v1/posts?filter[title][contains]=Rails&sort[created_at]=desc

4. Contract validates params
   ✅ Valid: { filter: { title: { contains: 'Rails' } }, sort: { created_at: 'desc' } }

5. Controller action runs
   def index
     respond_with Post.all
   end

6. ResponseRenderer detects index route
   if action_name == 'index' && resource.is_a?(ActiveRecord::Relation)
     query = Query.new(Post.all, schema: PostSchema).perform(params)
     collection = query.result
     meta = query.meta  # Pagination info
   end

7. Query builds ActiveRecord operations
   Post.all
     .where("title LIKE ?", "%Rails%")
     .order(created_at: :desc)
     .limit(20)
     .offset(0)

8. Response returned
   {
     "ok": true,
     "posts": [...],
     "meta": {
       "page": {
         "current": 1,
         "total": 3,
         "items": 47
       }
     }
   }
```

## Real-world example

Let's say you have a blog with posts and comments:

```ruby
# Schema
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id, filterable: true, sortable: true
  attribute :title, filterable: true, sortable: true, writable: true
  attribute :body, filterable: true, writable: true
  attribute :published, filterable: true, sortable: true, writable: true
  attribute :created_at, filterable: true, sortable: true

  has_many :comments,
    schema: CommentSchema,
    filterable: true,
    sortable: true,
    include: :always
end

class CommentSchema < Apiwork::Schema::Base
  model Comment

  attribute :id, filterable: true, sortable: true
  attribute :author, filterable: true, sortable: true, writable: true
  attribute :content, filterable: true, writable: true
  attribute :created_at, filterable: true, sortable: true

  belongs_to :post, schema: PostSchema, filterable: true, sortable: true
end
```

Now your users can do powerful queries without you writing any query code:

```bash
# Find published posts by author "Alice"
GET /posts?filter[published][equal]=true&filter[comments][author][equal]=Alice

# Sort posts by most recent comments
GET /posts?sort[comments][created_at]=desc

# Get page 2 of posts, 10 per page, with comments included
GET /posts?page[number]=2&page[size]=10&include[comments]=true

# Complex: published posts with "Rails" in title or body, sorted by title, paginated
GET /posts?filter[0][published][equal]=true&filter[0][title][contains]=Rails&filter[1][published][equal]=true&filter[1][body][contains]=Rails&sort[title]=asc&page[number]=1&page[size]=5
```

**Generated SQL** (for the association filter example):
```sql
SELECT DISTINCT posts.*
FROM posts
INNER JOIN comments ON comments.post_id = posts.id
WHERE posts.published = true
  AND comments.author = 'Alice'
```

## Why this separation matters

**Schemas** answer: "What data exists and what operations are allowed?"
- `filterable: true` → "This field can be used in WHERE clauses"
- `sortable: true` → "This field can be used in ORDER BY"
- `include: :always` → "This association can be included in responses"

**Queries** answer: "How do I actually execute those operations?"
- Builds WHERE conditions with Arel
- Handles JOINs for association queries
- Prevents N+1 with eager loading
- Generates pagination metadata

**Contracts** validate: "Is this query request valid?"
- Auto-generates param schemas from schema flags
- Validates filter operators match field types
- Ensures only allowed fields are queried
- Type-checks all input

You define once (schema flags), Apiwork validates (contract) and executes (query).

## Automatic features

When you mark fields as queryable, you automatically get:

### Type-specific filter operators

**String fields** (`filterable: true` on string column):
```bash
filter[title][equal]=Rails
filter[title][contains]=Rails
filter[title][starts_with]=Getting
filter[title][in][]=Rails&filter[title][in][]=Elixir
```

**Numeric fields** (integer, decimal):
```bash
filter[views][equal]=100
filter[views][greater_than]=50
filter[views][less_than]=200
filter[views][between][from]=10&filter[views][between][to]=100
```

**Date/DateTime fields**:
```bash
filter[created_at][greater_than]=2024-01-01
filter[created_at][between][from]=2024-01-01&filter[created_at][between][to]=2024-12-31
```

**Boolean fields**:
```bash
filter[published][equal]=true
```

**UUID fields**:
```bash
filter[id][equal]=550e8400-e29b-41d4-a716-446655440000
filter[id][in][]=550e8400-e29b-41d4-a716-446655440000&filter[id][in][]=...
```

See [Filtering](filtering.md) for complete operator reference.

### Pagination metadata

Every paginated response includes:

```json
{
  "ok": true,
  "posts": [...],
  "meta": {
    "page": {
      "current": 2,      // Current page number
      "next": 3,         // Next page (null if last page)
      "prev": 1,         // Previous page (null if first page)
      "total": 5,        // Total number of pages
      "items": 47        // Total number of items
    }
  }
}
```

See [Pagination](pagination.md) for details.

### N+1 prevention

When you mark associations as `include: :always` and include them:

```bash
GET /posts?include[comments]=true
```

Apiwork automatically uses `.includes()` to prevent N+1 queries:

```ruby
# Without includes: N+1 problem
Post.all.each { |post| post.comments.each { ... } }
# Runs: SELECT * FROM posts
#       SELECT * FROM comments WHERE post_id = 1
#       SELECT * FROM comments WHERE post_id = 2
#       ... (N+1 queries!)

# With Apiwork includes: Optimized
Post.includes(:comments)
# Runs: SELECT * FROM posts
#       SELECT * FROM comments WHERE post_id IN (1, 2, 3, ...)
#       (2 queries total!)
```

See [Includes](includes.md) for details.

## When queries DON'T activate

Queries only auto-activate when ALL of these are true:

1. **Action is `index`** - Other actions (show, create, update) don't auto-query
2. **Resource is ActiveRecord::Relation** - Not Array, not single model
3. **Contract has a schema** - Schema provides the query configuration

If any condition fails, no auto-query happens (but you can still use `Query` manually).

## Manual query usage

You can use the Query system manually if needed:

```ruby
class PostsController < ApplicationController
  def search
    # Manual query outside of index action
    scope = Post.where(published: true)
    query = Apiwork::Query.new(scope, schema: PostSchema).perform(action_input.params)

    respond_with query.result, meta: query.meta
  end
end
```

This is useful for:
- Custom actions beyond CRUD
- Multiple queryable endpoints
- Conditional query application

## Performance

Apiwork's query system is built on ActiveRecord and Arel - the same tools Rails uses internally. Performance characteristics:

- **Filtering**: Translates directly to SQL WHERE clauses (fast)
- **Sorting**: Uses database ORDER BY (indexed fields are fast)
- **Pagination**: LIMIT/OFFSET (efficient for reasonable page sizes)
- **Includes**: Uses Rails .includes() (prevents N+1, but loads associations eagerly)

**Best practices**:
- Add database indexes to frequently filtered/sorted fields
- Keep page sizes reasonable (default 20, max 100)
- Use pagination instead of loading all records
- Profile slow queries and add indexes

## Security

Query params are validated by auto-generated contracts:

- ✅ **Only schema-marked fields can be queried** - filterable/sortable flags control access
- ✅ **Type-safe operators** - Can't use string operators on numeric fields
- ✅ **No SQL injection** - Uses Arel parameter binding
- ✅ **Association boundaries** - Only allowed associations can be queried

**Authorization**: Queries respect your authorization layer. If your controller scopes records:

```ruby
def index
  # Only current user's posts
  respond_with current_user.posts
end
```

Queries apply to that scoped relation - users can't query outside their permissions.

## Frontend usage

Query params work with standard HTTP query string encoding:

```javascript
// Vanilla fetch
const url = new URL('/api/v1/posts', 'https://api.example.com');
url.searchParams.append('filter[published][equal]', 'true');
url.searchParams.append('sort[created_at]', 'desc');
url.searchParams.append('page[number]', '1');
url.searchParams.append('page[size]', '10');

const response = await fetch(url);
const data = await response.json();
```

```typescript
// Type-safe with generated client
const response = await api.posts.index({
  filter: {
    published: { equal: true }
  },
  sort: {
    created_at: 'desc'
  },
  page: {
    number: 1,
    size: 10
  }
});

// Response is typed:
// { ok: true; posts: Post[]; meta: { page: PageMeta } }
```

When you generate TypeScript/Zod schemas from your contracts, query params are fully typed with autocomplete and compile-time checking.

## Next steps

- **[Filtering](filtering.md)** - Complete guide to all filter operators
- **[Sorting](sorting.md)** - Sort by one or multiple fields
- **[Pagination](pagination.md)** - Page through large collections
- **[Includes](includes.md)** - Eager load associations, prevent N+1
- **[Combining Queries](combining.md)** - Complex real-world examples
- **[Schemas](../schemas/introduction.md)** - How to mark fields as queryable
