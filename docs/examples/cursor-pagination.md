---
order: 10
---

# Cursor Pagination

Navigate through large datasets using cursor-based pagination

## API Definition

<small>`config/apis/grumpy_panda.rb`</small>

<<< @/app/config/apis/grumpy_panda.rb

## Models

<small>`app/models/grumpy_panda/activity.rb`</small>

<<< @/app/app/models/grumpy_panda/activity.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| action | string |  |  |
| occurred_at | datetime | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/grumpy_panda/activity_schema.rb`</small>

<<< @/app/app/schemas/grumpy_panda/activity_schema.rb

## Contracts

<small>`app/contracts/grumpy_panda/activity_contract.rb`</small>

<<< @/app/app/contracts/grumpy_panda/activity_contract.rb

## Controllers

<small>`app/controllers/grumpy_panda/activities_controller.rb`</small>

<<< @/app/app/controllers/grumpy_panda/activities_controller.rb

---



## Request Examples

<details>
<summary>First page</summary>

**Request**

```http
GET /grumpy_panda/activities
```

**Response** `200`

```json
{
  "activities": [
    {
      "id": "67968ddb-d475-48bb-9082-6d872684e221",
      "action": "post.update",
      "occurredAt": "2024-01-01T13:00:00.000Z",
      "createdAt": "2025-12-07T16:39:26.191Z"
    },
    {
      "id": "a33ae66c-d38e-4129-aa33-2c71766b9775",
      "action": "post.create",
      "occurredAt": "2024-01-01T12:00:00.000Z",
      "createdAt": "2025-12-07T16:39:26.191Z"
    },
    {
      "id": "c24bfdf5-8d76-41b8-aa39-0078e94b536a",
      "action": "post.delete",
      "occurredAt": "2024-01-01T14:00:00.000Z",
      "createdAt": "2025-12-07T16:39:26.192Z"
    }
  ],
  "pagination": {
    "nextCursor": "eyJpZCI6ImMyNGJmZGY1LThkNzYtNDFiOC1hYTM5LTAwNzhlOTRiNTM2YSJ9",
    "prevCursor": null
  }
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/app/public/grumpy-panda/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/grumpy-panda/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/grumpy-panda/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/grumpy-panda/openapi.yml

</details>