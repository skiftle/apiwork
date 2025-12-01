---
order: 4
---

# Execution Layer

The execution layer sits between your contracts and your data. It handles filtering, sorting, pagination, eager loading, and response formatting. This is where Apiwork transforms contract metadata into actual database queries and API responses.

## What It Does

When a request comes in:

1. **Contract validates** the request (query params, body)
2. **Execution layer** applies filters, sorting, pagination
3. **Schema serializes** the result
4. **Response** goes back to the client

```
Request → Contract → Execution Layer → Schema → Response
                          ↓
                    ActiveRecord
```

## Built-in Adapter

Apiwork includes a built-in adapter that provides:

- **Pagination** — page-based and cursor-based
- **Filtering** — type-aware operators
- **Sorting** — multi-field ordering
- **Eager Loading** — automatic N+1 prevention

## Configuration

Configure the adapter in your API definition:

```ruby
Apiwork::API.draw '/api/v1' do
  adapter do
    pagination do
      strategy :page        # or :cursor
      default_size 20
      max_size 100
    end
  end
end
```

## Pagination

### Page-Based (Default)

```ruby
adapter do
  pagination do
    strategy :page
    default_size 20
    max_size 100
  end
end
```

**Query:**

```
GET /api/v1/posts?page[number]=2&page[size]=10
```

**Response:**

```json
{
  "posts": [...],
  "pagination": {
    "current_page": 2,
    "total_pages": 5,
    "total_count": 48,
    "per_page": 10
  }
}
```

### Cursor-Based

```ruby
adapter do
  pagination do
    strategy :cursor
    default_size 20
    max_size 100
  end
end
```

**Query:**

```
GET /api/v1/posts?page[after]=eyJpZCI6MTIzfQ&page[size]=10
```

**Response:**

```json
{
  "posts": [...],
  "pagination": {
    "has_next_page": true,
    "has_previous_page": true,
    "start_cursor": "eyJpZCI6MTAwfQ",
    "end_cursor": "eyJpZCI6MTEwfQ"
  }
}
```

## Filtering

The adapter translates filter params to ActiveRecord queries:

```
GET /api/v1/posts?filter[status][eq]=published&filter[created_at][gt]=2024-01-01
```

Becomes:

```ruby
Post.where(status: 'published').where('created_at > ?', Date.parse('2024-01-01'))
```

See [Attributes - Filtering](../core/schemas/attributes.md#filtering) for all operators.

## Sorting

```
GET /api/v1/posts?sort[created_at]=desc&sort[title]=asc
```

Becomes:

```ruby
Post.order(created_at: :desc, title: :asc)
```

See [Attributes - Sorting](../core/schemas/attributes.md#sorting) for details.

## Eager Loading

When includes are requested, the adapter preloads associations:

```
GET /api/v1/posts?include[comments]=true&include[author]=true
```

Becomes:

```ruby
Post.includes(:comments, :author)
```

Prevents N+1 queries automatically.

## Per-Schema Configuration

Override adapter settings for specific schemas:

```ruby
class PostSchema < Apiwork::Schema::Base
  adapter do
    pagination do
      default_size 10
      max_size 50
    end
  end
end
```

## How It Flows

### Collection Request (index)

```ruby
# 1. Controller
def index
  posts = Post.all
  respond_with posts
end

# 2. Adapter receives Post.all and contract.query
#    Applies: filter, sort, paginate, includes
#    Returns: { posts: [...], pagination: {...} }
```

### Single Record Request (show, create, update)

```ruby
# 1. Controller
def show
  respond_with Post.find(params[:id])
end

# 2. Adapter receives single record
#    Applies: includes (if requested)
#    Returns: { post: {...} }
```

## Key Transform

The adapter respects the API's key format setting:

```ruby
Apiwork::API.draw '/api/v1' do
  key_format :camel
end
```

```json
// Request
{ "post": { "createdAt": "2024-01-15" } }
// ↓ transformed to
// { post: { created_at: "2024-01-15" } }

// Response
// { created_at: "2024-01-15" }
// ↓ transformed to
{ "createdAt": "2024-01-15" }
```

## Custom Adapters

For non-ActiveRecord data sources or custom query logic, you can create your own adapter. See [Custom Adapters](../advanced/custom-adapters.md).
