---
order: 1
---

# Introduction

Once you connect a schema to a contract with `schema!`, Apiwork's runtime takes over. It reads your schema, generates types, handles filtering and sorting, and serializes responses — all from the schema definition.

## What the Adapter Does

The adapter powers everything behind `schema!`. When you connect a schema to a contract:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!  # Finds InvoiceSchema automatically
end
```

Here's what happens:

1. **Reads your schema** — finds filterable, sortable, writable attributes and associations
2. **Generates types** — creates filter, sort, include, and payload types for the contract
3. **Powers code generation** — TypeScript, Zod, and OpenAPI definitions come from these types
4. **Executes queries** — handles filtering, sorting, and pagination at runtime
5. **Serializes responses** — formats output according to your schema

## Architecture

```text
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

1. Request arrives
2. Contract validates
3. Adapter executes query
4. Schema serializes
5. Response sent

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

From this, the adapter generates:

| Type | Purpose | Source |
|------|---------|--------|
| `invoice_filter` | Filter query validation | `filterable: true` attributes |
| `invoice_sort` | Sort query validation | `sortable: true` attributes |
| `invoice_include` | Include query validation | associations |
| `invoice_create_payload` | Create request body | `writable: true` attributes |
| `invoice_update_payload` | Update request body | `writable: true` attributes |
| `invoice` | Response serialization | all attributes |

These types power everything:
- Request validation (is this filter valid?)
- Code generation (TypeScript interfaces, Zod schemas)
- Documentation (OpenAPI specs)

## Configuration

You configure the adapter at the API level:

```ruby
Apiwork::API.define '/api/v1' do
  adapter do
    pagination do
      strategy :offset
      default_size 20
      max_size 100
    end
  end
end
```

Or override for specific schemas:

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

The adapter handles four query parameter groups for you:

| Parameter | Purpose | Example |
|-----------|---------|---------|
| `filter` | Filter records | `?filter[status][eq]=active` |
| `sort` | Order results | `?sort[created_at]=desc` |
| `page` | Paginate | `?page[number]=2&page[size]=20` |
| `include` | Eager load | `?include[comments]=true` |

## Schema Integration

Your schema options determine what's allowed:

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

When a client sends an invalid query, they get a `400 Bad Request` with structured errors:

```json
{
  "errors": [
    {
      "code": "field_not_filterable",
      "detail": "title is not filterable. Available: status, published_at",
      "path": ["filter", "title"]
    }
  ]
}
```

Notice how error responses include available options — this helps developers debug quickly.

## Next Steps

- [Filtering](./filtering.md) — operators and logical combinations
- [Sorting](./sorting.md) — multi-field ordering
- [Pagination](./pagination.md) — offset-based and cursor-based
- [Eager Loading](./eager-loading.md) — includes and N+1 prevention
