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
      "id": "790acde5-9e64-4200-8901-c4e641d6342d",
      "action": "post.create",
      "occurredAt": "2024-01-01T12:00:00.000Z",
      "createdAt": "2025-12-07T16:17:39.963Z"
    },
    {
      "id": "a34d957e-9ca5-411a-b96f-799dea3aefb4",
      "action": "post.update",
      "occurredAt": "2024-01-01T13:00:00.000Z",
      "createdAt": "2025-12-07T16:17:39.964Z"
    },
    {
      "id": "bad508e8-8cb3-4a5c-93a2-516d03ca66a8",
      "action": "user.logout",
      "occurredAt": "2024-01-01T11:00:00.000Z",
      "createdAt": "2025-12-07T16:17:39.962Z"
    }
  ],
  "pagination": {
    "nextCursor": "eyJpZCI6ImJhZDUwOGU4LThjYjMtNGE1Yy05M2EyLTUxNmQwM2NhNjZhOCJ9",
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