# query

The `query` method applies filtering, sorting, and pagination to ActiveRecord scopes based on request parameters.

## Basic usage

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def index
    posts = query(Post.all)
    respond_with posts
  end

  def drafts
    posts = query(Post.where(published: false))
    respond_with posts
  end
end
```

## What it does

`query` takes an ActiveRecord scope and applies params:

1. **Filtering** - `filter` param builds WHERE clauses
2. **Sorting** - `sort` param builds ORDER BY clauses
3. **Pagination** - `page` param applies LIMIT/OFFSET

All three are optional. If no params are provided, the original scope is returned unchanged.

## Filtering

Filter records with the `filter` parameter:

```
GET /api/v1/posts?filter[published]=true
GET /api/v1/posts?filter[title][contains]=Rails
GET /api/v1/posts?filter[created_at][greater_than]=2024-01-01
```

Controller:

```ruby
def index
  posts = query(Post.all)  # Automatically applies filter param
  respond_with posts
end
```

### Filterable attributes

Only attributes marked `filterable: true` can be filtered:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id, filterable: true
  attribute :title, filterable: true
  attribute :published, filterable: true
  attribute :created_at, filterable: true

  attribute :body  # NOT filterable
end
```

Attempting to filter by `body` returns a 422 error.

### Filter operators by type

Different types support different operators:

**String/Text:**

```
filter[title][equal]=My Post
filter[title][not_equal]=Draft
filter[title][contains]=Rails
filter[title][not_contains]=PHP
filter[title][starts_with]=Getting
filter[title][ends_with]=Guide
filter[title][in][]=First&filter[title][in][]=Second
filter[title][not_in][]=Archived&filter[title][not_in][]=Deleted
```

**Numeric (integer/decimal/float):**

```
filter[id][equal]=1
filter[id][not_equal]=5
filter[id][greater_than]=10
filter[id][greater_than_or_equal_to]=10
filter[id][less_than]=100
filter[id][less_than_or_equal_to]=100
filter[id][between][from]=1&filter[id][between][to]=10
filter[id][not_between][from]=1&filter[id][not_between][to]=10
filter[id][in][]=1&filter[id][in][]=2&filter[id][in][]=3
filter[id][not_in][]=99&filter[id][not_in][]=100
```

**Boolean:**

```
filter[published][equal]=true
filter[published][not_equal]=false
```

**Date/DateTime:**

```
filter[created_at][equal]=2024-01-15
filter[created_at][not_equal]=2024-01-01
filter[created_at][greater_than]=2024-01-01T10:00:00Z
filter[created_at][greater_than_or_equal_to]=2024-01-01
filter[created_at][less_than]=2024-12-31
filter[created_at][less_than_or_equal_to]=2024-12-31
filter[created_at][between][from]=2024-01-01&filter[created_at][between][to]=2024-12-31
filter[created_at][not_between][from]=2024-01-01&filter[created_at][not_between][to]=2024-12-31
filter[created_at][in][]=2024-01-15&filter[created_at][in][]=2024-01-16
filter[created_at][not_in][]=2024-12-25&filter[created_at][not_in][]=2024-12-26
```

**UUID:**

```
filter[id]=550e8400-e29b-41d4-a716-446655440000
filter[id][]=uuid1&filter[id][]=uuid2  (array of UUIDs)
```

### Shorthand filters

For simple equality, omit the operator:

```
# These are equivalent:
filter[published]=true
filter[published][equal]=true

# These are equivalent:
filter[title]=My Post
filter[title][equal]=My Post
```

### Multiple filters (AND)

Multiple filters are combined with AND:

```
GET /api/v1/posts?filter[published]=true&filter[title][contains]=Rails
```

SQL: `WHERE published = true AND title LIKE '%Rails%'`

### OR filters

Use array syntax for OR conditions:

```
GET /api/v1/posts?filter[0][published]=true&filter[1][title][contains]=Rails
```

SQL: `WHERE published = true OR title LIKE '%Rails%'`

Each array element is a separate filter group, OR'd together.

### Filtering associations

Filter through associations:

```
GET /api/v1/posts?filter[author][name]=Alice
GET /api/v1/posts?filter[comments][body][contains]=great
```

Schema requirements:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :title, filterable: true

  # Association must be filterable
  belongs_to :author,
    schema: Api::V1::UserSchema,
    filterable: true

  has_many :comments,
    schema: Api::V1::CommentSchema,
    filterable: true
end

class Api::V1::UserSchema < Apiwork::Schema::Base
  model User

  # Nested attribute must also be filterable
  attribute :name, filterable: true
end
```

Apiwork automatically joins associations and applies filters.

### Enum validation

For ActiveRecord enums, values are validated:

```ruby
class Post < ApplicationRecord
  enum status: { draft: 0, published: 1, archived: 2 }
end
```

```
GET /api/v1/posts?filter[status]=published  ✅ Valid
GET /api/v1/posts?filter[status]=invalid    ❌ 422 Error
```

## Sorting

Sort records with the `sort` parameter:

```
GET /api/v1/posts?sort[created_at]=desc
GET /api/v1/posts?sort[title]=asc
```

Controller:

```ruby
def index
  posts = query(Post.all)  # Automatically applies sort param
  respond_with posts
end
```

### Sortable attributes

Only attributes marked `sortable: true` can be sorted:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id, sortable: true
  attribute :title, sortable: true
  attribute :created_at, sortable: true

  attribute :body  # NOT sortable
end
```

### Sort directions

Use `asc` or `desc`:

```
sort[title]=asc   # Ascending A-Z
sort[title]=desc  # Descending Z-A
```

### Multiple sorts

Apply multiple sorts:

```
GET /api/v1/posts?sort[published]=desc&sort[created_at]=desc
```

SQL: `ORDER BY published DESC, created_at DESC`

Order matters. First sort is primary, second is secondary, etc.

### Array syntax for explicit order

Use array syntax to be explicit about sort order:

```
GET /api/v1/posts?sort[0][published]=desc&sort[1][created_at]=desc
```

Same as above but more explicit about ordering.

### Sorting by associations

Sort by association attributes:

```
GET /api/v1/posts?sort[author][name]=asc
```

Schema requirements:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  # Association must be sortable
  belongs_to :author,
    schema: Api::V1::UserSchema,
    sortable: true
end

class Api::V1::UserSchema < Apiwork::Schema::Base
  model User

  # Nested attribute must also be sortable
  attribute :name, sortable: true
end
```

Apiwork automatically joins and sorts.

### Default sort

Configure default sorting in your schema:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  default_sort { { created_at: :desc } }

  attribute :created_at, sortable: true
end
```

Or globally in configuration:

```ruby
# config/initializers/apiwork.rb
Apiwork.configure do |config|
  config.default_sort = { created_at: :desc }
end
```

Default is applied when no `sort` param is provided.

## Pagination

Paginate results with the `page` parameter:

```
GET /api/v1/posts?page[number]=1&page[size]=20
GET /api/v1/posts?page[number]=2&page[size]=50
```

Controller:

```ruby
def index
  posts = query(Post.all)  # Automatically applies pagination
  respond_with posts
end
```

Response includes pagination metadata:

```json
{
  "ok": true,
  "posts": [...],
  "meta": {
    "page": {
      "current": 2,
      "next": 3,
      "prev": 1,
      "total": 10,
      "items": 200
    }
  }
}
```

### Pagination params

**`page[number]`** - Page number (1-indexed, default: 1)
**`page[size]`** - Items per page (default: 25)

```
page[number]=1   # First page
page[number]=2   # Second page
page[size]=10    # 10 items per page
page[size]=100   # 100 items per page
```

### Page size limits

Configure default and maximum page size:

```ruby
# config/initializers/apiwork.rb
Apiwork.configure do |config|
  config.default_page_size = 25   # Default if not specified
  config.max_page_size = 100  # Maximum allowed
end
```

Or per-schema:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  default_page_size 25
  max_page_size 100
end
```

Requesting more than the maximum returns an error.

### Pagination metadata

The `meta.page` object includes:

- **current** - Current page number
- **next** - Next page number (or null if last page)
- **prev** - Previous page number (or null if first page)
- **total** - Total number of pages
- **items** - Total number of items across all pages

## Combining filter, sort, and page

All three work together:

```
GET /api/v1/posts?filter[published]=true&sort[created_at]=desc&page[number]=1&page[size]=20
```

Execution order:

1. Filter → `WHERE published = true`
2. Sort → `ORDER BY created_at DESC`
3. Paginate → `LIMIT 20 OFFSET 0`

## Including associations

Control association eager loading with `include`:

```
GET /api/v1/posts?include[comments]=true
GET /api/v1/posts?include[comments][author]=true
```

The `query` method automatically handles includes for N+1 prevention.

See [respond_with](./respond_with.md#including-associations) for details on including associations in responses.

## Working with scopes

`query` works with any ActiveRecord scope:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def index
    # Start with base scope
    posts = query(Post.all)
    respond_with posts
  end

  def published
    # Start with scoped query
    posts = query(Post.where(published: true))
    respond_with posts
  end

  def user_posts
    # Start with association
    user = User.find(params[:user_id])
    posts = query(user.posts)
    respond_with posts
  end
end
```

Filters, sorts, and pagination are applied on top of your scope.

## Performance considerations

**Automatic DISTINCT:** When filtering or sorting by associations, `query` automatically adds `.distinct` to prevent duplicate rows from JOINs.

**Eager loading:** Use the `include` parameter to prevent N+1 queries when associations are serialized.

**Indexes:** Ensure filterable and sortable columns have database indexes for performance.

## Error handling

Invalid query params return 422 errors:

```
GET /api/v1/posts?filter[invalid_field]=value
```

Response:

```json
{
  "ok": false,
  "issues": [
    {
      "code": "filter_error",
      "path": "/filter",
      "message": "invalid_field is not a filterable attribute on Post. Available: id, title, published, created_at"
    }
  ]
}
```

Common error scenarios:

- Filtering/sorting by non-filterable/non-sortable attributes
- Invalid filter operators for type
- Invalid enum values
- Invalid page numbers (< 1)
- Page size exceeding maximum

## What query does NOT do

These features are **not supported**:

- ❌ Full-text search - Use a search engine (Elasticsearch, etc.)
- ❌ Aggregations (SUM, AVG, COUNT) - Build custom actions
- ❌ Complex subqueries - Use custom scopes
- ❌ Raw SQL in filters - Security risk, not supported
- ❌ Geo/spatial queries - Use PostGIS with custom scopes

For complex queries beyond filter/sort/paginate, define custom controller actions and scopes.

## Next steps

- **[respond_with](./respond_with.md)** - Building responses
- **[action_params](./action_params.md)** - Accessing validated parameters
- **[Introduction](./introduction.md)** - Back to controllers overview
