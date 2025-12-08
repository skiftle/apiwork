---
order: 5
---

# Execution Layer

The execution layer sits between your contracts and your data. It handles filtering, sorting, pagination, eager loading, and response formatting.

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

## Built-in Runtime

Apiwork includes a built-in runtime that provides:

- **Filtering** — type-aware operators, logical combinations
- **Sorting** — multi-field ordering
- **Pagination** — offset-based and cursor-based
- **Eager Loading** — automatic N+1 prevention

For detailed documentation, see [Runtime](../core/runtime/introduction.md).

## Quick Reference

### Filtering

```
GET /posts?filter[status][eq]=published&filter[views][gt]=100
```

[Filtering](../core/runtime/filtering.md) covers operators like `eq`, `contains`, `between`, and logical combinations with `_and`/`_or`.

### Sorting

```
GET /posts?sort[created_at]=desc&sort[title]=asc
```

[Sorting](../core/runtime/sorting.md) covers multi-field ordering and association sorting.

### Pagination

```
GET /posts?page[number]=2&page[size]=20
```

[Pagination](../core/runtime/pagination.md) covers offset-based and cursor-based strategies.

### Eager Loading

```
GET /posts?include[comments]=true&include[author]=true
```

[Eager Loading](../core/runtime/eager-loading.md) covers nested includes and N+1 prevention.

## Configuration

Configure the runtime in your API definition:

```ruby
Apiwork::API.draw '/api/v1' do
  adapter do
    pagination do
      strategy :offset        # or :cursor
      default_size 20
      max_size 100
    end
  end
end
```

Override for specific schemas:

```ruby
class PostSchema < Apiwork::Schema::Base
  adapter do
    pagination do
      strategy :cursor
      default_size 50
    end
  end
end
```

## How It Flows

### Collection Request (index)

```ruby
def index
  posts = Post.all
  respond_with posts
end

# Runtime applies: filter → sort → paginate → includes
# Returns: { posts: [...], pagination: {...} }
```

### Single Record Request (show, create, update)

```ruby
def show
  respond_with Post.find(params[:id])
end

# Runtime applies: includes (if requested)
# Returns: { post: {...} }
```

## Response Metadata

Add custom metadata to any response:

```ruby
def index
  posts = Post.all
  respond_with posts, meta: {
    generated_at: Time.current,
    api_version: 'v1'
  }
end
```

Response:

```json
{
  "posts": [...],
  "pagination": {...},
  "meta": {
    "generated_at": "2024-01-15T10:30:00Z",
    "api_version": "v1"
  }
}
```

To document the meta structure in your contract, use the `meta` block. [Actions - meta](../core/contracts/actions.md#meta) shows how to define typed meta fields.

## Key Transform

The runtime respects the API's key format setting:

```ruby
Apiwork::API.draw '/api/v1' do
  key_format :camel
end
```

```json
// Request
{ "post": { "createdAt": "2024-01-15" } }
// ↓ transformed to snake_case internally

// Response
// snake_case ↓ transformed to camelCase
{ "createdAt": "2024-01-15" }
```

## Custom Adapters

For non-ActiveRecord data sources or custom query logic, you can create your own adapter. [Custom Adapters](../advanced/custom-adapters.md) explains the adapter interface.

## Next Steps

- [Runtime](../core/runtime/introduction.md) — detailed query parameter documentation
- [Contracts](../core/contracts/introduction.md) — define request/response shapes
- [Schemas](../core/schemas/introduction.md) — auto-generate contracts from models
