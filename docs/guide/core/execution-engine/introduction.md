---
order: 1
---

# Introduction

The **Execution Engine** is the runtime that interprets and executes your API schemas.

It reads schema definitions, derives types, and handles requests — validation, querying, serialization.
All execution is delegated through an **adapter**, which defines how queries are built and responses are rendered.

This section documents the adapter that ships with Apiwork. Throughout, "the adapter" refers to this default implementation.

For custom response formats or query logic, see [Custom Adapters](../../advanced/custom-adapters.md).

## Two Phases

The execution engine operates in two distinct phases: **definition time** and **request time**.

---

## Definition Time

When you call `schema!`, the adapter reads your schema and interprets it as an executable contract.

From this single definition, Apiwork derives a set of typed constraints that describe:

- which query parameters are allowed
- how data can be written
- how responses should be serialized

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  attribute :number, filterable: true, sortable: true, writable: true
  attribute :status, filterable: true, enum: %w[draft sent paid]
  attribute :issued_on, filterable: true, sortable: true

  belongs_to :customer, filterable: true
  has_many :lines, writable: true
end
```

From this schema, the adapter generates the following types:

| Generated Type           | Purpose                       | Derived From       |
| ------------------------ | ----------------------------- | ------------------ |
| `invoice_filter`         | Validates filter query params | `filterable: true` |
| `invoice_sort`           | Validates sort query params   | `sortable: true`   |
| `invoice_include`        | Validates include params      | associations       |
| `invoice_create_payload` | Validates create request body | `writable: true`   |
| `invoice_update_payload` | Validates update request body | `writable: true`   |
| `invoice`                | Serializes responses          | all attributes     |

In addition, Apiwork generates [action defaults](./action-defaults.md) for each action on the resource.
The generated types vary depending on the action type.

All defaults are derived from the schema.

---

## Request Time

When a request arrives, the contract validates it against the generated types. Then the adapter:

1. **Query** — translates filter/sort/page/include into database queries
2. **Serialize** — formats the response according to the schema

---

## Query Parameters

The adapter supports four query parameter groups:

| Parameter | Purpose         | Example                         |
| --------- | --------------- | ------------------------------- |
| `filter`  | Filter records  | `?filter[status][eq]=sent`      |
| `sort`    | Order results   | `?sort[issued_on]=desc`         |
| `page`    | Paginate        | `?page[number]=2&page[size]=20` |
| `include` | Eager load data | `?include[lines]=true`          |

Invalid or unsupported queries fail fast before reaching the database.

---

## Next Steps

- [Action Defaults](./action-defaults.md)
- [Filtering](./filtering.md)
- [Sorting](./sorting.md)
- [Pagination](./pagination.md)
- [Includes](./includes.md)
