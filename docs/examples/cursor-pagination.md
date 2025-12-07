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
GET /grumpy-panda/activities
```

**Response** `200`

```json
{
  "activities": [
    {
      "id": "3b83c9a1-bdec-4963-bf3f-b7af614c924f",
      "action": "user.logout",
      "occurred_at": "2024-01-01T11:00:00.000Z",
      "created_at": "2025-12-07T13:14:57.407Z"
    },
    {
      "id": "3e386b60-31e8-4fc9-a53e-1c5e08d3f7b5",
      "action": "post.create",
      "occurred_at": "2024-01-01T12:00:00.000Z",
      "created_at": "2025-12-07T13:14:57.409Z"
    },
    {
      "id": "4ff8f59b-3805-4c0f-85c9-0b3d6b53ec1a",
      "action": "post.delete",
      "occurred_at": "2024-01-01T14:00:00.000Z",
      "created_at": "2025-12-07T13:14:57.416Z"
    }
  ],
  "pagination": {
    "next_cursor": "eyJpZCI6IjRmZjhmNTliLTM4MDUtNGMwZi04NWM5LTBiM2Q2YjUzZWMxYSJ9",
    "prev_cursor": null
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