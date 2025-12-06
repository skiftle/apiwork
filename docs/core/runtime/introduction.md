---
order: 1
---

# Runtime

The runtime is Apiwork's built-in query engine. It translates query parameters into ActiveRecord queries and handles filtering, sorting, pagination, and eager loading.

## What It Does

When a request comes in:

1. **Contract validates** the request structure
2. **Runtime applies** filters, sorting, pagination, includes
3. **Schema serializes** the result

```
Request → Contract → Runtime → Schema → Response
                        ↓
                  ActiveRecord
```

The runtime reads your schema definitions to know which fields are filterable, sortable, and how associations should load.

## Configuration

Configure at the API level:

```ruby
Apiwork::API.draw '/api/v1' do
  adapter do
    pagination do
      strategy :page
      default_size 20
      max_size 100
    end
  end
end
```

Override for specific schemas:

```ruby
class ActivitySchema < Apiwork::Schema::Base
  adapter do
    pagination do
      strategy :cursor
      default_size 50
    end
  end
end
```

## Query Parameters

The runtime recognizes four query parameter groups:

| Parameter | Purpose | Example |
|-----------|---------|---------|
| `filter` | Filter records | `?filter[status][eq]=active` |
| `sort` | Order results | `?sort[created_at]=desc` |
| `page` | Paginate | `?page[number]=2&page[size]=20` |
| `include` | Eager load | `?include[comments]=true` |

## Schema Integration

The runtime respects schema attribute options:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, filterable: true, sortable: true
  attribute :body, filterable: true
  attribute :views, sortable: true

  has_many :comments, filterable: true, include: :optional
  belongs_to :author, sortable: true, include: :always
end
```

- `filterable: true` — allows `filter[field][operator]=value`
- `sortable: true` — allows `sort[field]=asc|desc`
- `include: :optional` — client can request with `include[assoc]=true`
- `include: :always` — automatically included in every response

## Error Handling

Invalid queries return `400 Bad Request` with structured issues:

```json
{
  "issues": [
    {
      "code": "field_not_filterable",
      "detail": "title is not filterable. Available: status, published_at",
      "path": ["filter", "title"]
    }
  ]
}
```

Error responses include available options to help developers debug.

## Next Steps

- [Filtering](./filtering.md) — operators and logical combinations
- [Sorting](./sorting.md) — multi-field ordering
- [Pagination](./pagination.md) — page-based and cursor-based
- [Eager Loading](./eager-loading.md) — includes and N+1 prevention
