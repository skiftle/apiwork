---
order: 5
---

# Cursor Pagination

Cursor-based pagination for navigating large datasets

## API Definition

<small>`config/apis/grumpy_panda.rb`</small>

<<< @/playground/config/apis/grumpy_panda.rb

## Models

<small>`app/models/grumpy_panda/activity.rb`</small>

<<< @/playground/app/models/grumpy_panda/activity.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| action | string |  |  |
| created_at | datetime |  |  |
| occurred_at | datetime | ✓ |  |
| updated_at | datetime |  |  |

:::

## Representations

<small>`app/representations/grumpy_panda/activity_representation.rb`</small>

<<< @/playground/app/representations/grumpy_panda/activity_representation.rb

## Contracts

<small>`app/contracts/grumpy_panda/activity_contract.rb`</small>

<<< @/playground/app/contracts/grumpy_panda/activity_contract.rb

## Controllers

<small>`app/controllers/grumpy_panda/activities_controller.rb`</small>

<<< @/playground/app/controllers/grumpy_panda/activities_controller.rb

## Request Examples

::: details First page

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
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "28fab1f1-3992-5d5c-9d68-d136bc923c6e",
      "action": "user.login",
      "occurredAt": "2024-01-01T10:00:00.000Z",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "4c39275f-ec14-5a37-858d-84eb6899b55d",
      "action": "post.delete",
      "occurredAt": "2024-01-01T14:00:00.000Z",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "next": "eyJpZCI6IjRjMzkyNzVmLWVjMTQtNWEzNy04NThkLTg0ZWI2ODk5YjU1ZCJ9",
    "prev": null
  }
}
```

:::

::: details Next page

**Request**

```http
GET /grumpy_panda/activities?page[after]=eyJpZCI6IjRjMzkyNzVmLWVjMTQtNWEzNy04NThkLTg0ZWI2ODk5YjU1ZCJ9
```

**Response** `200`

```json
{
  "activities": [
    {
      "id": "941cf71e-f960-5659-8955-cdd06fb62148",
      "action": "post.create",
      "occurredAt": "2024-01-01T12:00:00.000Z",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "d7d2baf6-242e-5a3b-8e5f-258913655538",
      "action": "post.update",
      "occurredAt": "2024-01-01T13:00:00.000Z",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "next": null,
    "prev": "eyJpZCI6Ijk0MWNmNzFlLWY5NjAtNTY1OS04OTU1LWNkZDA2ZmI2MjE0OCJ9"
  }
}
```

:::

## Generated Output

::: details Introspection

<<< @/playground/public/grumpy-panda/introspection.json

:::

::: details TypeScript

<<< @/playground/public/grumpy-panda/typescript.ts

:::

::: details Zod

<<< @/playground/public/grumpy-panda/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/grumpy-panda/openapi.yml

:::