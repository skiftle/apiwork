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
      "id": "47464087-cb4b-4713-a6a3-59ff49e49eb4",
      "action": "user.logout",
      "occurredAt": "2024-01-01T11:00:00.000Z",
      "createdAt": "2025-12-07T14:49:43.045Z"
    },
    {
      "id": "498bb975-7f5c-40b2-aa70-e26383b66123",
      "action": "post.delete",
      "occurredAt": "2024-01-01T14:00:00.000Z",
      "createdAt": "2025-12-07T14:49:43.049Z"
    },
    {
      "id": "55f24bca-2491-4b6d-9adb-c533b30960c8",
      "action": "post.update",
      "occurredAt": "2024-01-01T13:00:00.000Z",
      "createdAt": "2025-12-07T14:49:43.048Z"
    }
  ],
  "pagination": {
    "nextCursor": "eyJpZCI6IjU1ZjI0YmNhLTI0OTEtNGI2ZC05YWRiLWM1MzNiMzA5NjBjOCJ9",
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