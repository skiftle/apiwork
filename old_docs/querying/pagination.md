# Pagination

Paginate large collections automatically by passing `page` params. Apiwork handles the LIMIT/OFFSET SQL and returns metadata about the current page, total pages, and total items.

## Basic syntax

```bash
GET /posts?page[number]=1&page[size]=10
```

**Format**: `page[number]=X&page[size]=Y`

**Parameters**:

- `number` - Which page to retrieve (starts at 1)
- `size` - How many items per page

## Default pagination

If no page params are provided, Apiwork uses defaults:

```bash
GET /posts
# Same as: GET /posts?page[number]=1&page[size]=20
```

**Defaults**:

- `page[number]` defaults to `1`
- `page[size]` defaults to `20` (configurable)

## Basic pagination

```bash
# First page, 10 items
GET /posts?page[number]=1&page[size]=10

# Second page, 10 items
GET /posts?page[number]=2&page[size]=10

# Third page, 25 items
GET /posts?page[number]=3&page[size]=25
```

**Generated SQL**:

```sql
-- Page 1, size 10
SELECT * FROM posts LIMIT 10 OFFSET 0

-- Page 2, size 10
SELECT * FROM posts LIMIT 10 OFFSET 10

-- Page 3, size 25
SELECT * FROM posts LIMIT 25 OFFSET 50
```

Offset = (page_number - 1) × page_size

## Pagination metadata

Every response includes pagination metadata in the `meta` field:

```json
{
  "ok": true,
  "posts": [...],
  "meta": {
    "page": {
      "current": 2,
      "next": 3,
      "prev": 1,
      "total": 5,
      "items": 47
    }
  }
}
```

**Metadata fields**:

- `current` - Current page number
- `next` - Next page number (null if on last page)
- `prev` - Previous page number (null if on first page)
- `total` - Total number of pages
- `items` - Total number of items across all pages

## Edge cases

### First page

```bash
GET /posts?page[number]=1&page[size]=10
```

```json
{
  "ok": true,
  "posts": [...],
  "meta": {
    "page": {
      "current": 1,
      "next": 2,
      "prev": null,  // No previous page
      "total": 5,
      "items": 47
    }
  }
}
```

### Last page

```bash
GET /posts?page[number]=5&page[size]=10
```

```json
{
  "ok": true,
  "posts": [...],  // May have fewer than 10 items
  "meta": {
    "page": {
      "current": 5,
      "next": null,  // No next page
      "prev": 4,
      "total": 5,
      "items": 47
    }
  }
}
```

### Beyond last page

```bash
GET /posts?page[number]=100&page[size]=10
```

Returns empty results:

```json
{
  "ok": true,
  "posts": [],
  "meta": {
    "page": {
      "current": 100,
      "next": null,
      "prev": 99,
      "total": 5,
      "items": 47
    }
  }
}
```

Not an error - just no results for that page.

### Empty collection

```bash
GET /posts?page[number]=1&page[size]=10
# When there are no posts
```

```json
{
  "ok": true,
  "posts": [],
  "meta": {
    "page": {
      "current": 1,
      "next": null,
      "prev": null,
      "total": 0,
      "items": 0
    }
  }
}
```

## Page size limits

Apiwork enforces minimum and maximum page sizes to prevent abuse:

```bash
# Too small (< 1)
GET /posts?page[size]=0
# Error: page[size] must be >= 1

# Too large (> 200 by default)
GET /posts?page[size]=1000
# Error: page[size] must be <= 200
```

**Limits**:

- Minimum: `1`
- Maximum: `200` (default, configurable)

If you exceed the maximum, Apiwork raises a `PaginationError`.

## Configuring defaults

### Global configuration

```ruby
# config/initializers/apiwork.rb
Apiwork.configure do |config|
  config.default_page_size = 25   # Default: 20
  config.max_page_size = 100  # Default: 200
end
```

Now all index routes use these defaults.

### Schema-level configuration

You can override per-schema:

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  # Override pagination for this schema
  self.default_page_size = 50
  self.max_page_size = 500

  attribute :title, filterable: true
  # ...
end
```

Schema settings take precedence over global config.

## Combining with filters

```bash
# Published posts, page 2
GET /posts?filter[published][equal]=true&page[number]=2&page[size]=10
```

Pagination applies to filtered results:

```sql
SELECT * FROM posts
WHERE published = true
LIMIT 10 OFFSET 10
```

Metadata reflects filtered count:

```json
{
  "ok": true,
  "posts": [...],
  "meta": {
    "page": {
      "current": 2,
      "total": 3,
      "items": 27  // Only published posts
    }
  }
}
```

## Combining with sorting

```bash
# Sorted by newest, page 1
GET /posts?sort[created_at]=desc&page[number]=1&page[size]=10
```

**Important**: Always use the same sort order across pages. Inconsistent sorting can cause items to appear on multiple pages or be skipped.

```sql
SELECT * FROM posts
ORDER BY created_at DESC
LIMIT 10 OFFSET 0
```

**Best practice**: Include a unique field (like `id`) as a secondary sort to ensure stable ordering:

```bash
GET /posts?sort[0][created_at]=desc&sort[1][id]=asc&page[number]=1
```

## Frontend usage

### JavaScript

```javascript
// Simple pagination
const url = new URL("/api/v1/posts");
url.searchParams.append("page[number]", "2");
url.searchParams.append("page[size]", "10");

const response = await fetch(url);
const data = await response.json();

console.log(data.posts); // Current page items
console.log(data.meta.page.total); // Total pages
console.log(data.meta.page.items); // Total items
```

### Building a paginator

```javascript
function buildPaginator(meta) {
  const { current, next, prev, total } = meta.page;

  return {
    currentPage: current,
    totalPages: total,
    hasNext: next !== null,
    hasPrev: prev !== null,
    nextPage: next,
    prevPage: prev,
  };
}

// Usage
const paginator = buildPaginator(data.meta);
if (paginator.hasNext) {
  // Load next page
  fetchPage(paginator.nextPage);
}
```

### TypeScript

```typescript
// Type-safe with generated client
const response = await api.posts.index({
  page: {
    number: 2,
    size: 10,
  },
});

// Response type includes pagination metadata
type Response = {
  ok: true;
  posts: Post[];
  meta: {
    page: {
      current: number;
      next: number | null;
      prev: number | null;
      total: number;
      items: number;
    };
  };
};
```

## Performance

### Count queries

Pagination metadata requires counting total items:

```sql
-- First query: count total items
SELECT COUNT(*) FROM posts WHERE published = true

-- Second query: fetch page
SELECT * FROM posts WHERE published = true LIMIT 10 OFFSET 10
```

**Impact**: Two queries per paginated request.

For large tables, counting can be slow. Consider:

- Adding indexes on filtered columns
- Caching total counts for static data
- Using cursor-based pagination for very large datasets

### Offset performance

OFFSET becomes slower for deep pages:

```sql
-- Page 1: Fast (skip 0 rows)
SELECT * FROM posts LIMIT 10 OFFSET 0

-- Page 100: Slower (skip 990 rows)
SELECT * FROM posts LIMIT 10 OFFSET 990

-- Page 1000: Very slow (skip 9990 rows)
SELECT * FROM posts LIMIT 10 OFFSET 9990
```

The database must scan and discard offset rows before returning results.

**Best practices**:

- Limit maximum page number for public APIs
- Use cursor-based pagination for deep pagination
- Encourage users to use filters instead of deep pagination

## Cursor-based pagination (future)

Offset-based pagination has limitations for large datasets. Cursor-based pagination (keyset pagination) is more efficient but not yet implemented in Apiwork.

**How it would work**:

```bash
# First page
GET /posts?page[size]=10

# Next page using cursor
GET /posts?page[size]=10&page[after]=eyJpZCI6MTIzfQ==
```

**Benefits**:

- Consistent results even when data changes
- Fast for any page depth
- No expensive offset scans

**Drawbacks**:

- No random page access (only next/prev)
- More complex implementation

For now, use offset-based pagination with reasonable page size limits.

## Common patterns

### Infinite scroll

```javascript
let page = 1;
const pageSize = 20;

async function loadMore() {
  const response = await api.posts.index({
    page: { number: page, size: pageSize },
  });

  displayPosts(response.posts);

  if (response.meta.page.next) {
    page++;
  } else {
    // No more pages
    hideLoadMoreButton();
  }
}
```

### Page number list

```javascript
function buildPageNumbers(meta) {
  const { current, total } = meta.page;
  const pages = [];

  // Show current page ± 2
  const start = Math.max(1, current - 2);
  const end = Math.min(total, current + 2);

  for (let i = start; i <= end; i++) {
    pages.push(i);
  }

  return pages;
}

// Usage
const pages = buildPageNumbers(data.meta);
// [1, 2, 3, 4, 5] when on page 3
```

### Prev/Next navigation

```javascript
function Navigation({ meta }) {
  const { prev, next } = meta.page;

  return (
    <div>
      <button disabled={!prev} onClick={() => loadPage(prev)}>
        Previous
      </button>

      <button disabled={!next} onClick={() => loadPage(next)}>
        Next
      </button>
    </div>
  );
}
```

## Validation errors

### Invalid page number

```bash
GET /posts?page[number]=0
```

```json
{
  "ok": false,
  "issues": [
    {
      "code": "invalid_page_number",
      "detail": "page[number] must be >= 1",
      "path": ["page", "number"]
    }
  ]
}
```

### Invalid page size

```bash
GET /posts?page[size]=-10
```

```json
{
  "ok": false,
  "issues": [
    {
      "code": "invalid_page_size",
      "detail": "page[size] must be >= 1",
      "path": ["page", "size"]
    }
  ]
}
```

### Page size too large

```bash
GET /posts?page[size]=1000
# When maximum is 200
```

```json
{
  "ok": false,
  "issues": [
    {
      "code": "invalid_page_size",
      "detail": "page[size] must be <= 200",
      "path": ["page", "size"]
    }
  ]
}
```

## Best practices

1. **Always paginate index routes** - Never load all records without pagination
2. **Use consistent page sizes** - Pick a default and stick with it across your API
3. **Include sort params** - Ensures consistent ordering across pages
4. **Add indexes** - Index columns used in filters and sorts
5. **Document limits** - Tell API consumers the maximum page size
6. **Cache counts** - For static/slow-changing data, cache total counts
7. **Limit deep pagination** - Consider max page number for public APIs
8. **Use cursor pagination** - For infinite scroll and large datasets (when available)

## Next steps

- [Filtering](filtering.md) - Filter before paginating
- [Sorting](sorting.md) - Sort before paginating
- [Includes](includes.md) - Eager load associations
- [Combining Queries](combining.md) - Filter + sort + paginate
