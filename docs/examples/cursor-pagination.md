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
      "id": "35033e2a-2833-49ce-a974-f10790a7a8d5",
      "action": "post.create",
      "occurredAt": "2024-01-01T12:00:00.000Z",
      "createdAt": "2025-12-07T17:20:07.176Z"
    },
    {
      "id": "4e2d1d2c-f284-484c-a3ae-59617ead8093",
      "action": "post.delete",
      "occurredAt": "2024-01-01T14:00:00.000Z",
      "createdAt": "2025-12-07T17:20:07.178Z"
    },
    {
      "id": "e50ce779-0009-4142-8733-2396698140bc",
      "action": "user.logout",
      "occurredAt": "2024-01-01T11:00:00.000Z",
      "createdAt": "2025-12-07T17:20:07.175Z"
    }
  ],
  "pagination": {
    "nextCursor": "eyJpZCI6ImU1MGNlNzc5LTAwMDktNDE0Mi04NzMzLTIzOTY2OTgxNDBiYyJ9",
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