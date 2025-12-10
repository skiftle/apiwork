---
order: 5
---

# Execution Layer

The execution layer is the part of Apiwork that takes your validated
input and turns it into a query. It sits between your contracts and your
data, and is responsible for things like filtering, sorting, pagination,
eager loading, and formatting the final response. You don't configure
this logic directly --- it's derived from the definitions you've already
written.

## What It Does

When a request comes in, the flow looks like this:

1.  **The contract validates** the request (query params and body)
2.  **The execution layer** applies filtering, sorting, pagination, and
    includes
3.  **The schema** serializes the result
4.  The **response** is returned to the client

```{=html}
<!-- -->
```

    Request → Contract → Execution Layer → Schema → Response
                              ↓
                        ActiveRecord

Apiwork handles these steps automatically. You describe the shape of the
API; the runtime takes care of the details.

## Built-in Runtime

Apiwork ships with a built-in runtime that supports:

- **Filtering** --- type-aware operators and logical combinations
- **Sorting** --- ordering by one or many fields
- **Pagination** --- offset-based or cursor-based
- **Eager loading** --- automatic N+1 prevention

Each of these features is optional, derived from your schema, and
explained in detail in the [Runtime](../core/runtime/introduction.md)
section.

## Quick Reference

### Filtering

    GET /posts?filter[status][eq]=published&filter[views][gt]=100

[Filtering](../core/runtime/filtering.md) covers operators like `eq`,
`contains`, `between`, and logical combinations such as `_and` and
`_or`.

### Sorting

    GET /posts?sort[created_at]=desc&sort[title]=asc

[Sorting](../core/runtime/sorting.md) covers multi-field ordering and
sorting across associations.

### Pagination

    GET /posts?page[number]=2&page[size]=20

[Pagination](../core/runtime/pagination.md) explains both offset and
cursor strategies.

### Eager Loading

    GET /posts?include[comments]=true&include[author]=true

[Eager Loading](../core/runtime/eager-loading.md) covers nested includes
and N+1 prevention.

## Configuration

You configure runtime behaviour in your API definition:

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

And you can override settings for specific schemas:

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

# The runtime applies: filter → sort → paginate → includes
# Response: { posts: [...], pagination: {...} }
```

### Single Record Request (show, create, update)

```ruby
def show
  respond_with Post.find(params[:id])
end

# The runtime applies: includes (if requested)
# Response: { post: {...} }
```

## Response Metadata

You can attach metadata to any response:

```ruby
def index
  posts = Post.all
  respond_with posts, meta: {
    generated_at: Time.current,
    api_version: 'v1'
  }
end
```

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

To document metadata in your contract, see [Actions --
meta](../core/contracts/actions.md#meta).

## Key Transform

The runtime respects the API's configured key format:

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

If you're not using ActiveRecord, or if your data source needs custom
behaviour, you can implement your own adapter. See [Custom
Adapters](../advanced/custom-adapters.md) for details.

## Next Steps

- [Runtime](../core/runtime/introduction.md) --- detailed query
  parameter documentation\
- [Contracts](../core/contracts/introduction.md) --- define
  request/response shapes\
- [Schemas](../core/schemas/introduction.md) --- auto-generate
  contracts from models
