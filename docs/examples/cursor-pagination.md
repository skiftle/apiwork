---
order: 10
---

# Cursor Pagination

Navigate through large datasets using cursor-based pagination

## API Definition

<small>`config/apis/grumpy_panda.rb`</small>

<<< @/playground/config/apis/grumpy_panda.rb

## Models

<small>`app/models/grumpy_panda/activity.rb`</small>

<<< @/playground/app/models/grumpy_panda/activity.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| action | string |  |  |
| created_at | datetime |  |  |
| occurred_at | datetime | ✓ |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/grumpy_panda/activity_schema.rb`</small>

<<< @/playground/app/schemas/grumpy_panda/activity_schema.rb

## Contracts

<small>`app/contracts/grumpy_panda/activity_contract.rb`</small>

<<< @/playground/app/contracts/grumpy_panda/activity_contract.rb

## Controllers

<small>`app/controllers/grumpy_panda/activities_controller.rb`</small>

<<< @/playground/app/controllers/grumpy_panda/activities_controller.rb

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
      "id": "1dc81f7a-b9de-42a3-8c2a-06c5cc099751",
      "action": "user.logout",
      "occurredAt": "2024-01-01T11:00:00.000Z",
      "createdAt": "2025-12-18T13:21:02.253Z"
    },
    {
      "id": "5db4a993-502e-40b9-9f21-743a36375539",
      "action": "post.create",
      "occurredAt": "2024-01-01T12:00:00.000Z",
      "createdAt": "2025-12-18T13:21:02.253Z"
    },
    {
      "id": "78ce5077-2596-4126-a076-9f15ca5e9903",
      "action": "post.update",
      "occurredAt": "2024-01-01T13:00:00.000Z",
      "createdAt": "2025-12-18T13:21:02.254Z"
    }
  ],
  "pagination": {
    "nextCursor": "eyJpZCI6Ijc4Y2U1MDc3LTI1OTYtNDEyNi1hMDc2LTlmMTVjYTVlOTkwMyJ9",
    "prevCursor": null
  }
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/grumpy-panda/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/grumpy-panda/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/grumpy-panda/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/grumpy-panda/openapi.yml

</details>