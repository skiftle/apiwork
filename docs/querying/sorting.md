# Sorting

Sort your index results by marking fields as `sortable: true`. Apiwork generates the contract params and applies ORDER BY clauses automatically.

## Basic syntax

```bash
GET /posts?sort[title]=asc
GET /posts?sort[created_at]=desc
```

**Format**: `sort[field_name]=direction`

**Directions**:
- `asc` - Ascending order (A→Z, 0→9, old→new)
- `desc` - Descending order (Z→A, 9→0, new→old)

## Enable sorting

Mark attributes as sortable in your schema:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, sortable: true
  attribute :created_at, sortable: true
  attribute :views, sortable: true
end
```

Now these fields can be sorted via URL params.

## Single field sort

```bash
# Sort posts by title (ascending)
GET /posts?sort[title]=asc

# Sort posts by created_at (descending, newest first)
GET /posts?sort[created_at]=desc

# Sort posts by views (descending, most viewed first)
GET /posts?sort[views]=desc
```

**Generated SQL**:
```sql
SELECT * FROM posts ORDER BY title ASC
SELECT * FROM posts ORDER BY created_at DESC
SELECT * FROM posts ORDER BY views DESC
```

## Multiple field sort

Use array syntax to sort by multiple fields:

```bash
GET /posts?sort[0][published]=asc&sort[1][created_at]=desc
```

**Order matters**: First sort field takes precedence.

**Generated SQL**:
```sql
SELECT * FROM posts
ORDER BY published ASC, created_at DESC
```

**Example**: Unpublished posts first, then by newest:
```bash
GET /posts?sort[0][published]=asc&sort[1][created_at]=desc
```

Results:
1. Unpublished posts (published=false), newest first
2. Published posts (published=true), newest first

## Association sorting

Sort by associated model fields:

```bash
# Sort posts by most recent comment
GET /posts?sort[comments][created_at]=desc

# Sort posts by comment author name
GET /posts?sort[comments][author]=asc
```

**Requirements**:
- Association marked `sortable: true`
- Associated schema has sortable attributes

**Generated SQL**:
```sql
SELECT posts.*
FROM posts
LEFT JOIN comments ON comments.post_id = posts.id
ORDER BY comments.created_at DESC
```

**Note**: Uses LEFT JOIN to include posts with no comments.

## Nested association sorting

```bash
# Sort posts by comment author's name
GET /posts?sort[comments][user][name]=asc
```

Works with any depth if associations are marked sortable.

## Type-specific sorting

### String fields

```bash
sort[title]=asc   # Alphabetical A→Z
sort[title]=desc  # Reverse Z→A
```

Case-insensitive by default (database collation).

### Numeric fields

```bash
sort[views]=asc   # Lowest to highest
sort[views]=desc  # Highest to lowest
```

### Date/DateTime fields

```bash
sort[created_at]=asc   # Oldest first
sort[created_at]=desc  # Newest first
```

### Boolean fields

```bash
sort[published]=asc   # false first, then true
sort[published]=desc  # true first, then false
```

## Default sort

If no sort param provided, Apiwork uses database default (usually insertion order).

**Best practice**: Always include a sort param for predictable ordering, especially with pagination.

## Combining with filters

```bash
# Published posts, sorted by title
GET /posts?filter[published][equal]=true&sort[title]=asc

# Posts containing "Rails", sorted by most viewed
GET /posts?filter[title][contains]=Rails&sort[views]=desc
```

Sort applies to filtered results.

## Combining with pagination

```bash
# Page 2, sorted by newest
GET /posts?sort[created_at]=desc&page[number]=2&page[size]=10
```

**Important**: Use consistent sort order across pages for reliable pagination.

## Frontend usage

```javascript
// Simple sort
const url = new URL('/api/v1/posts');
url.searchParams.append('sort[created_at]', 'desc');

// Multiple sorts
url.searchParams.append('sort[0][published]', 'asc');
url.searchParams.append('sort[1][title]', 'asc');
```

```typescript
// Type-safe with generated client
const response = await api.posts.index({
  sort: {
    created_at: 'desc'  // Autocomplete: 'asc' | 'desc'
  }
});

// Multiple sorts
const response = await api.posts.index({
  sort: [
    { published: 'asc' },
    { title: 'asc' }
  ]
});
```

## Performance

- **Indexed fields**: Fast (use database indexes)
- **Unindexed fields**: Slower (full table sort)
- **Association sorts**: Requires JOIN (slower than direct column)

**Best practices**:
- Add indexes to frequently sorted columns
- Avoid sorting by text fields on large tables
- Prefer sorting by indexed columns (id, created_at, etc.)

## Next steps

- [Filtering](filtering.md) - Filter before sorting
- [Pagination](pagination.md) - Paginate sorted results
- [Combining Queries](combining.md) - Filter + sort + paginate
