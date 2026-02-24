---
order: 1
---
# Standard Adapter

The standard adapter is the built-in adapter included in Apiwork.

For custom response formats or query logic, see [Custom Adapters](../custom-adapters/).

## Design

The standard adapter combines REST conventions with a Prisma-inspired query format built for end-to-end type safety. Structured parameters with explicit field names, operators, and types are fully typed — enabling contract-level validation and TypeScript, Zod, and OpenAPI generation from the same definitions. Error codes, query formats, and response shapes are built for API clients, not tied to any specific framework.

## Generated Types

The standard adapter generates typed definitions from the representation:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :number, filterable: true, sortable: true, writable: true
  attribute :status, filterable: true, enum: %w[draft sent paid]
  attribute :issued_on, filterable: true, sortable: true

  belongs_to :customer, filterable: true
  has_many :lines, writable: true
end
```

From this schema, the adapter generates:

| Generated Type           | Purpose                       | Derived From       |
| ------------------------ | ----------------------------- | ------------------ |
| `invoice_filter`         | Validates filter query parameters | `filterable: true` |
| `invoice_sort`           | Validates sort query parameters   | `sortable: true`   |
| `invoice_include`        | Validates include parameters      | associations       |
| `invoice_create_payload` | Validates create request body | `writable: true`   |
| `invoice_update_payload` | Validates update request body | `writable: true`   |
| `invoice`                | Serializes responses          | all attributes     |

In addition, Apiwork generates [action defaults](./action-defaults.md) for each action on the resource.

## Query Parameters

The standard adapter supports four query parameter groups:

| Parameter | Purpose         | Example                         |
| --------- | --------------- | ------------------------------- |
| `filter`  | Filter records  | `?filter[status][eq]=sent`      |
| `sort`    | Order results   | `?sort[issued_on]=desc`         |
| `page`    | Paginate        | `?page[number]=2&page[size]=20` |
| `include` | Eager load data | `?include[lines]=true`          |

Invalid or unsupported queries are rejected before reaching the database.

## Next Steps

- [Action Defaults](./action-defaults.md)
- [Writing](./writing.md)
- [Filtering](./filtering.md)
- [Sorting](./sorting.md)
- [Pagination](./pagination.md)
- [Includes](./includes.md)
- [Serialization](./serialization.md)
- [Validation](./validation.md)
- [Extending](./extending.md)
