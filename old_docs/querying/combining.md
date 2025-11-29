# Combining Queries

Real-world APIs rarely use just filtering, sorting, pagination, or includes in isolation. This guide shows how to combine all query features together for powerful, efficient data retrieval.

## The basic pattern

```bash
GET /resource?filter[...]&sort[...]&page[...]&include[...]
```

All query params work together:

1. **Filter** - Narrow down which records to return
2. **Sort** - Order the filtered results
3. **Paginate** - Take a slice of the sorted results
4. **Include** - Eager load associations for that slice

The order matters for performance and correctness.

## Simple example

```bash
GET /posts?filter[published][equal]=true&sort[created_at]=desc&page[number]=1&page[size]=10&include[comments]=true
```

**What happens**:
1. Filter: Only published posts
2. Sort: Newest first
3. Paginate: First 10 posts
4. Include: Load comments for those 10 posts

**Generated SQL**:
```sql
-- Filter + sort + paginate
SELECT * FROM posts
WHERE published = true
ORDER BY created_at DESC
LIMIT 10 OFFSET 0

-- Include comments for those 10 posts
SELECT * FROM comments
WHERE post_id IN (1,2,3,4,5,6,7,8,9,10)
```

**Response**:
```json
{
  "ok": true,
  "posts": [
    {
      "id": 1,
      "title": "Latest Post",
      "published": true,
      "created_at": "2024-01-15T10:00:00Z",
      "comments": [
        { "id": 1, "content": "Great!" }
      ]
    }
  ],
  "meta": {
    "page": {
      "current": 1,
      "next": 2,
      "prev": null,
      "total": 5,
      "items": 47
    }
  }
}
```

## Real-world examples

### Blog post listing

**Use case**: Show published posts, newest first, 20 per page, with comment count.

```bash
GET /posts?filter[published][equal]=true&sort[created_at]=desc&page[size]=20&include[comments]=true
```

**Schema**:
```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, filterable: true, sortable: true
  attribute :published, filterable: true, sortable: true
  attribute :created_at, filterable: true, sortable: true

  has_many :comments, schema: CommentSchema, include: :always
end
```

Frontend can count comments: `post.comments.length`

### Search results

**Use case**: Search posts by title, sort by relevance (views), paginate.

```bash
GET /posts?filter[title][contains]=Rails&sort[views]=desc&page[number]=1&page[size]=10
```

**SQL**:
```sql
SELECT * FROM posts
WHERE title LIKE '%Rails%'
ORDER BY views DESC
LIMIT 10 OFFSET 0
```

### User dashboard

**Use case**: Current user's posts, sorted by last updated, with tags.

```bash
GET /posts?filter[user_id][equal]=123&sort[updated_at]=desc&include[tags]=true
```

**Schema**:
```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :user_id, filterable: true
  attribute :updated_at, filterable: true, sortable: true

  has_many :tags, schema: TagSchema, include: :always
end
```

### Admin moderation queue

**Use case**: Unpublished posts, oldest first, with author info.

```bash
GET /posts?filter[published][equal]=false&sort[created_at]=asc&include[user]=true
```

**SQL**:
```sql
SELECT * FROM posts
WHERE published = false
ORDER BY created_at ASC

SELECT * FROM users
WHERE id IN (...)
```

### Date range reports

**Use case**: Posts created in January 2024, sorted by title.

```bash
GET /posts?filter[created_at][between][from]=2024-01-01&filter[created_at][between][to]=2024-01-31&sort[title]=asc
```

**SQL**:
```sql
SELECT * FROM posts
WHERE created_at BETWEEN '2024-01-01' AND '2024-01-31'
ORDER BY title ASC
```

## Complex filtering with other features

### AND filters with sort and pagination

```bash
GET /posts?filter[published][equal]=true&filter[views][greater_than]=100&sort[views]=desc&page[size]=5
```

**Meaning**: Published posts with more than 100 views, sorted by most viewed, top 5.

**SQL**:
```sql
SELECT * FROM posts
WHERE published = true
  AND views > 100
ORDER BY views DESC
LIMIT 5
```

### OR filters with pagination

```bash
GET /posts?filter[0][title][contains]=Rails&filter[1][title][contains]=Elixir&sort[created_at]=desc&page[number]=1
```

**Meaning**: Posts containing "Rails" OR "Elixir", newest first, page 1.

**SQL**:
```sql
SELECT * FROM posts
WHERE (title LIKE '%Rails%' OR title LIKE '%Elixir%')
ORDER BY created_at DESC
LIMIT 20 OFFSET 0
```

## Association filtering with includes

```bash
GET /posts?filter[comments][author][equal]=Alice&include[comments]=true
```

**What happens**:
1. Filter posts that have comments by Alice
2. Include ALL comments for those posts (not just Alice's)

**SQL**:
```sql
-- Filter posts
SELECT DISTINCT posts.*
FROM posts
INNER JOIN comments ON comments.post_id = posts.id
WHERE comments.author = 'Alice'

-- Include all comments for those posts
SELECT * FROM comments
WHERE post_id IN (...)
```

**Important**: The included comments are not filtered - you get all comments for posts that match the filter.

## Association sorting with includes

```bash
GET /posts?sort[comments][created_at]=desc&include[comments]=true
```

**What happens**:
1. Sort posts by their most recent comment
2. Include all comments for those posts

**SQL**:
```sql
-- Sort posts
SELECT posts.*
FROM posts
LEFT JOIN comments ON comments.post_id = posts.id
ORDER BY comments.created_at DESC

-- Include comments
SELECT * FROM comments
WHERE post_id IN (...)
```

## Multiple associations

```bash
GET /posts?filter[published][equal]=true&sort[created_at]=desc&include[comments]=true&include[tags]=true&include[user]=true
```

**What it does**: Published posts, newest first, with comments, tags, and author.

**SQL**:
```sql
SELECT * FROM posts
WHERE published = true
ORDER BY created_at DESC

SELECT * FROM comments WHERE post_id IN (...)
SELECT * FROM tags ...
SELECT * FROM users WHERE id IN (...)
```

Multiple `includes` queries, but still efficient (no N+1).

## Nested includes with filtering

```bash
GET /posts?filter[published][equal]=true&include[comments][user]=true&sort[created_at]=desc
```

**What it does**: Published posts, newest first, with comments and comment authors.

**SQL**:
```sql
SELECT * FROM posts WHERE published = true ORDER BY created_at DESC
SELECT * FROM comments WHERE post_id IN (...)
SELECT * FROM users WHERE id IN (...)
```

Three queries total, fully optimized.

## Performance optimization strategies

### Strategy 1: Filter first, paginate early

```bash
# Good: Filter + paginate, then include
GET /posts?filter[published][equal]=true&page[size]=10&include[comments]=true
```

Only 10 posts × comments loaded.

```bash
# Bad: No pagination with large includes
GET /posts?include[comments]=true
```

All posts × all comments loaded (could be massive).

### Strategy 2: Sort by indexed columns

```bash
# Good: Sort by indexed column
GET /posts?sort[created_at]=desc&page[size]=20

# Slower: Sort by unindexed column
GET /posts?sort[body]=desc&page[size]=20
```

Add indexes to frequently sorted columns:

```ruby
# Migration
add_index :posts, :created_at
add_index :posts, :published
add_index :posts, [:published, :created_at]  # Composite index
```

### Strategy 3: Combine filters to use indexes

```bash
# Uses composite index on (published, created_at)
GET /posts?filter[published][equal]=true&sort[created_at]=desc
```

### Strategy 4: Include only what you need

```bash
# Good: Specific includes
GET /posts?include[user]=true

# Bad: Kitchen sink includes
GET /posts?include[comments]=true&include[tags]=true&include[categories]=true&include[user]=true
```

## Common patterns

### Infinite scroll

```javascript
let page = 1;

async function loadMore() {
  const response = await fetch(
    `/api/v1/posts?filter[published][equal]=true&sort[created_at]=desc&page[number]=${page}&page[size]=20&include[comments]=true`
  );

  const data = await response.json();
  displayPosts(data.posts);

  if (data.meta.page.next) {
    page++;
  }
}
```

### Searchable, sortable, paginated table

```javascript
function fetchPosts({ search, sort, page }) {
  const url = new URL('/api/v1/posts');

  // Search filter
  if (search) {
    url.searchParams.append('filter[title][contains]', search);
  }

  // Sort
  if (sort.field) {
    url.searchParams.append(`sort[${sort.field}]`, sort.direction);
  }

  // Pagination
  url.searchParams.append('page[number]', page);
  url.searchParams.append('page[size]', 20);

  return fetch(url);
}

// Usage
const posts = await fetchPosts({
  search: 'Rails',
  sort: { field: 'created_at', direction: 'desc' },
  page: 1
});
```

### Filtered reports

```javascript
async function generateReport(filters) {
  const url = new URL('/api/v1/posts');

  // Date range
  if (filters.startDate) {
    url.searchParams.append('filter[created_at][greater_than]', filters.startDate);
  }
  if (filters.endDate) {
    url.searchParams.append('filter[created_at][less_than]', filters.endDate);
  }

  // Status
  if (filters.published !== null) {
    url.searchParams.append('filter[published][equal]', filters.published);
  }

  // Sort by date
  url.searchParams.append('sort[created_at]', 'desc');

  // Include author
  url.searchParams.append('include[user]', 'true');

  const response = await fetch(url);
  return response.json();
}
```

### Master-detail view

```javascript
// List view: Just titles, no includes
const list = await fetch('/api/v1/posts?page[size]=50&sort[title]=asc');

// Detail view: Everything
const detail = await fetch(
  '/api/v1/posts?filter[id][equal]=123&include[comments][user]=true&include[tags]=true'
);
```

Different views need different data - adjust queries accordingly.

## URL encoding

Complex queries create long URLs. Make sure to properly encode params:

```javascript
const params = {
  filter: {
    title: { contains: 'Rails & PostgreSQL' },
    published: { equal: true }
  },
  sort: { created_at: 'desc' },
  page: { number: 1, size: 10 },
  include: { comments: true }
};

// URLSearchParams handles encoding
const url = new URL('/api/v1/posts');
url.searchParams.append('filter[title][contains]', 'Rails & PostgreSQL');
url.searchParams.append('filter[published][equal]', 'true');
url.searchParams.append('sort[created_at]', 'desc');
url.searchParams.append('page[number]', '1');
url.searchParams.append('page[size]', '10');
url.searchParams.append('include[comments]', 'true');

fetch(url);
```

### TypeScript client

With generated clients, this is automatic:

```typescript
const response = await api.posts.index({
  filter: {
    title: { contains: 'Rails & PostgreSQL' },
    published: { equal: true }
  },
  sort: { created_at: 'desc' },
  page: { number: 1, size: 10 },
  include: { comments: true }
});
```

No manual URL construction needed.

## Error handling

Queries can fail validation:

```bash
GET /posts?filter[invalid_field][equal]=true
```

```json
{
  "ok": false,
  "issues": [
    {
      "code": "unknown_field",
      "detail": "Unknown field: invalid_field",
      "path": ["filter", "invalid_field"]
    }
  ]
}
```

Check the `ok` field and handle errors:

```javascript
const response = await api.posts.index({ ... });

if (!response.ok) {
  console.error('Query failed:', response.errors);
  return;
}

// Use response.posts
```

## Testing queries

### RSpec example

```ruby
RSpec.describe 'Posts index' do
  it 'filters, sorts, paginates, and includes' do
    create_list(:post, 30, published: true)
    create_list(:post, 10, published: false)

    get '/api/v1/posts', params: {
      filter: { published: { equal: true } },
      sort: { created_at: 'desc' },
      page: { number: 1, size: 10 },
      include: { comments: true }
    }

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)

    expect(json['posts'].size).to eq(10)
    expect(json['meta']['page']['total']).to eq(3)  # 30 posts / 10 per page
    expect(json['meta']['page']['items']).to eq(30)

    # Check sorting (newest first)
    dates = json['posts'].map { |p| p['created_at'] }
    expect(dates).to eq(dates.sort.reverse)

    # Check includes
    expect(json['posts'].first).to have_key('comments')
  end
end
```

## Debugging

### View generated SQL

In Rails console or logs:

```ruby
# Enable SQL logging
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Make a request
get '/api/v1/posts', params: {
  filter: { published: { equal: true } },
  sort: { created_at: 'desc' },
  page: { number: 1, size: 10 },
  include: { comments: true }
}

# Check logs for SQL
```

### Explain query performance

```ruby
Post.where(published: true)
    .order(created_at: :desc)
    .limit(10)
    .explain
```

Shows query plan and identifies missing indexes.

## Best practices

1. **Filter before paginating** - Reduce the dataset size first
2. **Sort consistently** - Include a unique field (like `id`) for stable ordering
3. **Paginate everything** - Never return unbounded collections
4. **Include strategically** - Only load associations you'll use
5. **Index frequently queried fields** - Especially for filters and sorts
6. **Combine filters efficiently** - Use composite indexes for common filter combinations
7. **Monitor query performance** - Profile slow queries and optimize
8. **Use TypeScript clients** - Get type safety and autocomplete
9. **Test complex queries** - Verify filters, sorting, and pagination work together
10. **Document your API** - Show example queries in your API docs

## Next steps

- [Filtering](filtering.md) - Complete filter operator reference
- [Sorting](sorting.md) - Sorting details and multi-field sorts
- [Pagination](pagination.md) - Pagination metadata and configuration
- [Includes](includes.md) - Eager loading and N+1 prevention
- [Introduction](introduction.md) - How the query system works
