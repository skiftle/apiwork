---
order: 5
---

# Quick Start

This guide walks you through building a complete API endpoint with validation, serialization, filtering, and documentation.

## The Goal

We'll create a Posts API with:
- List posts with filtering and pagination
- Create posts with validation
- Auto-generated OpenAPI, TypeScript, and Zod specs

## 1. Database & Model

<<< @/app/db/migrate/20251201000001_create_swift_fox_tables.rb

<<< @/app/app/models/swift_fox/post.rb

## 2. API Definition

<<< @/app/config/apis/swift_fox.rb

## 3. Routes

Mount Apiwork routes in your Rails application:

<<< @/app/config/routes.rb

## 4. Schema

The schema defines how your model is serialized and what can be filtered/sorted:

<<< @/app/app/schemas/swift_fox/post_schema.rb

## 5. Contract

The contract imports the schema and can add action-specific rules:

<<< @/app/app/contracts/swift_fox/post_contract.rb

`schema!` imports all attributes from PostSchema. The contract now knows:
- What fields are writable (for create/update)
- What fields are filterable/sortable (for index)
- The types of all fields (for validation)

## 6. Controller

<<< @/app/app/controllers/swift_fox/posts_controller.rb

## 7. Try It Out

Start the server:

```bash
rails server
```

### Create a post

```bash
curl -X POST http://localhost:3000/swift-fox/posts \
  -H "Content-Type: application/json" \
  -d '{"post": {"title": "Hello World", "body": "My first post"}}'
```

### List posts with filtering

```bash
# All posts
curl http://localhost:3000/swift-fox/posts

# Filter by status
curl "http://localhost:3000/swift-fox/posts?filter[status][eq]=published"

# Sort by created_at descending
curl "http://localhost:3000/swift-fox/posts?sort[created_at]=desc"

# Paginate
curl "http://localhost:3000/swift-fox/posts?page[number]=1&page[size]=10"
```

### Get the specs

```bash
curl http://localhost:3000/swift-fox/.spec/openapi
curl http://localhost:3000/swift-fox/.spec/typescript
curl http://localhost:3000/swift-fox/.spec/zod
```

## What Just Happened?

With minimal code, you got:

1. **Validation** — The contract validates incoming data matches the schema types
2. **Serialization** — Responses are automatically formatted using the schema
3. **Filtering** — `filterable: true` attributes can be filtered via query params
4. **Sorting** — `sortable: true` attributes can be sorted
5. **Pagination** — Built-in page-based pagination
6. **Documentation** — OpenAPI, TypeScript, and Zod specs generated automatically

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/examples/swift-fox/introspection.json

</details>

<details>
<summary>OpenAPI</summary>

<<< @/examples/swift-fox/openapi.yml

</details>

<details>
<summary>TypeScript</summary>

<<< @/examples/swift-fox/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/examples/swift-fox/zod.ts

</details>

## There's More

This was a minimal example to get you started. Apiwork has a lot more to offer, including associations with sideloading via `?include=`, nested saves that create or update related records in a single request, automatic eager loading to prevent N+1 queries, advanced filtering with operators like `contains`, `starts_with`, and complex `_and`/`_or` logic, cursor-based pagination for large datasets, custom types, enums, unions, polymorphic associations, STI support with discriminated unions, custom encoders and decoders for attribute transformation, and i18n support. Keep reading to learn more.

## Next Steps

- [Contracts](../core/contracts/introduction.md) — Add custom validation and action-specific params
- [Schemas](../core/schemas/introduction.md) — Associations, computed attributes, and more
- [Spec Generation](../core/spec-generation/introduction.md) — TypeScript, Zod, and OpenAPI options
