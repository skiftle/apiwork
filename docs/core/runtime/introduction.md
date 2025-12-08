---
order: 1
---

# Runtime

The runtime is powered by Apiwork's built-in adapter. It reads your schemas, generates typed definitions, executes queries, and serializes responses.

## What the Adapter Does

The adapter is the engine behind `schema!`. When you connect a schema to a contract:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!  # Finds InvoiceSchema automatically
end
```

The adapter:

1. **Reads schema metadata** — filterable, sortable, writable attributes and associations
2. **Generates types** — filter, sort, include, and payload types for the contract
3. **Powers code generation** — TypeScript, Zod, and OpenAPI definitions come from these types
4. **Executes queries** — filtering, sorting, pagination at runtime
5. **Serializes responses** — formats output according to the schema

## Architecture

```
Schema Definition
       ↓
   Adapter reads metadata
       ↓
   ContractBuilder generates types
       ├── Filter types (from filterable attributes)
       ├── Sort types (from sortable attributes)
       ├── Include types (from associations)
       ├── Payload types (from writable attributes)
       └── Resource types (for responses)
       ↓
   Contract with typed actions
       ↓
   TypeScript / Zod / OpenAPI generation
```

At runtime:

```
Request → Contract validates → Adapter executes query → Schema serializes → Response
```

## Generated Types

For a schema like:

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  attribute :number, filterable: true, sortable: true, writable: true
  attribute :issued_on, filterable: true, sortable: true

  belongs_to :customer, filterable: true, sortable: true
  has_many :lines, writable: true, include: :always
end
```

The adapter generates:

| Type | Purpose | Source |
|------|---------|--------|
| `invoice_filter` | Filter query validation | `filterable: true` attributes |
| `invoice_sort` | Sort query validation | `sortable: true` attributes |
| `invoice_include` | Include query validation | associations |
| `invoice_create_payload` | Create request body | `writable: true` attributes |
| `invoice_update_payload` | Update request body | `writable: true` attributes |
| `invoice` | Response serialization | all attributes |

These types power:
- Request validation (is this filter valid?)
- Code generation (TypeScript interfaces, Zod schemas)
- Documentation (OpenAPI specs)

## Configuration

Configure at the API level:

```ruby
Apiwork::API.draw '/api/v1' do
  adapter do
    pagination do
      strategy :offset
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

The adapter handles four query parameter groups:

| Parameter | Purpose | Example |
|-----------|---------|---------|
| `filter` | Filter records | `?filter[status][eq]=active` |
| `sort` | Order results | `?sort[created_at]=desc` |
| `page` | Paginate | `?page[number]=2&page[size]=20` |
| `include` | Eager load | `?include[comments]=true` |

## Schema Integration

The adapter reads schema options to determine what's allowed:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, filterable: true, sortable: true
  attribute :body, filterable: true
  attribute :views, sortable: true

  has_many :comments, filterable: true, include: :optional
  belongs_to :author, sortable: true, include: :always
end
```

- `filterable: true` — generates filter type, allows `filter[field][operator]=value`
- `sortable: true` — generates sort type, allows `sort[field]=asc|desc`
- `writable: true` — generates payload type for create/update
- `include: :optional` — generates include type, client requests with `include[assoc]=true`
- `include: :always` — included automatically in every response

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
- [Pagination](./pagination.md) — offset-based and cursor-based
- [Eager Loading](./eager-loading.md) — includes and N+1 prevention
