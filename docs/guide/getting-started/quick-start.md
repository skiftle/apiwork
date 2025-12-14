---
order: 3
---

# Quick Start

This guide walks you through building a complete API endpoint with validation, serialization, filtering, and documentation.

## The Goal

We'll create an Invoices API with:

- List invoices with filtering and pagination
- Create invoices with validation
- Auto-generated OpenAPI, TypeScript, and Zod specs

## 1. Database & Model

<<< @/playground/db/migrate/20251130000004_create_eager_lion_tables.rb

<<< @/playground/app/models/eager_lion/invoice.rb

## 2. API Definition

<<< @/playground/config/apis/eager_lion.rb

## 3. Routes

Mount Apiwork routes in your Rails application:

<<< @/playground/config/routes.rb

## 4. Schema

The schema defines how your model is serialized and what can be filtered/sorted:

<<< @/playground/app/schemas/eager_lion/invoice_schema.rb

## 5. Contract

The contract imports the schema and can add action-specific rules:

<<< @/playground/app/contracts/eager_lion/invoice_contract.rb

`schema!` imports all attributes from InvoiceSchema. The contract now knows:

- What fields are writable (for create/update)
- What fields are filterable/sortable (for index)
- The types of all fields (for validation)

## 6. Controller

<<< @/playground/app/controllers/eager_lion/invoices_controller.rb

## 7. Try It Out

Start the server:

```bash
rails server
```

### Create an invoice

```bash
curl -X POST http://localhost:3000/eager-lion/invoices \
  -H "Content-Type: application/json" \
  -d '{"invoice": {"number": "INV-001", "issued_on": "2024-01-15", "notes": "First invoice"}}'
```

### List invoices with filtering

```bash
# All invoices
curl http://localhost:3000/eager-lion/invoices

# Filter by number
curl "http://localhost:3000/eager-lion/invoices?filter[number][eq]=INV-001"

# Sort by created_at descending
curl "http://localhost:3000/eager-lion/invoices?sort[created_at]=desc"

# Paginate
curl "http://localhost:3000/eager-lion/invoices?page[number]=1&page[size]=10"
```

### Get the specs

```bash
curl http://localhost:3000/eager-lion/.spec/openapi
curl http://localhost:3000/eager-lion/.spec/typescript
curl http://localhost:3000/eager-lion/.spec/zod
```

## What Just Happened?

With minimal code, you got:

1. **Validation** — The contract validates incoming data matches the schema types
2. **Serialization** — Responses are automatically formatted using the schema
3. **Filtering** — `filterable: true` attributes can be filtered via query params
4. **Sorting** — `sortable: true` attributes can be sorted
5. **Pagination** — Built-in offset-based pagination
6. **Documentation** — OpenAPI, TypeScript, and Zod specs generated automatically

See [Schema-Driven Contract Example](../examples/schema-driven-contract.md) for the complete generated output (TypeScript, Zod, OpenAPI).

## There's More

This was a minimal example to get you started. Apiwork has a lot more to offer, including associations with sideloading via `?include=`, nested saves that create or update related records in a single request, automatic eager loading to prevent N+1 queries, advanced filtering with operators like `contains`, `starts_with`, and complex `_and`/`_or` logic, cursor-based pagination for large datasets, custom types, enums, unions, polymorphic associations, STI support with discriminated unions, custom encoders and decoders for attribute transformation, and i18n support. Keep reading to learn more.

## Next Steps

- [Contracts](../core/contracts/introduction.md) — Add custom validation and action-specific params
- [Schemas](../core/schemas/introduction.md) — Associations, computed attributes, and more
- [Spec Generation](../core/spec-generation/introduction.md) — TypeScript, Zod, and OpenAPI options
