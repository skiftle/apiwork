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
| occurred_at | datetime | ✓ |  |
| created_at | datetime |  |  |
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
      "id": "05601e34-4e5e-5293-a94c-d7f265d247b4",
      "action": "user.logout",
      "occurredAt": "2024-01-01T11:00:00.000Z",
      "createdAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "28fab1f1-3992-5d5c-9d68-d136bc923c6e",
      "action": "user.login",
      "occurredAt": "2024-01-01T10:00:00.000Z",
      "createdAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "4c39275f-ec14-5a37-858d-84eb6899b55d",
      "action": "post.delete",
      "occurredAt": "2024-01-01T14:00:00.000Z",
      "createdAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "nextCursor": "eyJpZCI6IjRjMzkyNzVmLWVjMTQtNWEzNy04NThkLTg0ZWI2ODk5YjU1ZCJ9",
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