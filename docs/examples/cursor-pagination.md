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
      "id": "10d3f422-3739-4066-b2db-7dfca1b7f1c0",
      "action": "post.delete",
      "occurredAt": "2024-01-01T14:00:00.000Z",
      "createdAt": "2025-12-07T15:57:33.176Z"
    },
    {
      "id": "422ed237-2a17-4dba-a056-4a85e3a1b724",
      "action": "user.logout",
      "occurredAt": "2024-01-01T11:00:00.000Z",
      "createdAt": "2025-12-07T15:57:33.173Z"
    },
    {
      "id": "76c8187c-6bfd-42a7-9920-f54022642483",
      "action": "user.login",
      "occurredAt": "2024-01-01T10:00:00.000Z",
      "createdAt": "2025-12-07T15:57:33.167Z"
    }
  ],
  "pagination": {
    "nextCursor": "eyJpZCI6Ijc2YzgxODdjLTZiZmQtNDJhNy05OTIwLWY1NDAyMjY0MjQ4MyJ9",
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