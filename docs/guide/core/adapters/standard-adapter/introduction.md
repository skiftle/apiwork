---
order: 1
---

# Introduction

The **standard adapter** is the built-in runtime that ships with Apiwork.

For custom response formats or query logic, see [Custom Adapters](../custom-adapters.md).

## Generated Types

When you call `representation`, the standard adapter generates typed definitions from your representation:

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
| `invoice_filter`         | Validates filter query params | `filterable: true` |
| `invoice_sort`           | Validates sort query params   | `sortable: true`   |
| `invoice_include`        | Validates include params      | associations       |
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

Invalid or unsupported queries fail fast before reaching the database.

## Next Steps

- [Action Defaults](./action-defaults.md)
- [Filtering](./filtering.md)
- [Sorting](./sorting.md)
- [Pagination](./pagination.md)
- [Includes](./includes.md)
