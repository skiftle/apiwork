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
      "id": "643d4052-e908-4d06-878b-4411cbf476e9",
      "action": "user.login",
      "occurredAt": "2024-01-01T10:00:00.000Z",
      "createdAt": "2025-12-18T13:29:04.250Z"
    },
    {
      "id": "7b562c05-100f-430c-aff7-45316456b135",
      "action": "post.update",
      "occurredAt": "2024-01-01T13:00:00.000Z",
      "createdAt": "2025-12-18T13:29:04.254Z"
    },
    {
      "id": "8911d5e1-460d-42a8-ad34-fb37b0cf877a",
      "action": "post.create",
      "occurredAt": "2024-01-01T12:00:00.000Z",
      "createdAt": "2025-12-18T13:29:04.253Z"
    }
  ],
  "pagination": {
    "nextCursor": "eyJpZCI6Ijg5MTFkNWUxLTQ2MGQtNDJhOC1hZDM0LWZiMzdiMGNmODc3YSJ9",
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