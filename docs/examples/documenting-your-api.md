---
order: 11
---

# Documenting Your API

Add rich metadata with summaries, descriptions, tags, and operation IDs

## API Definition

<small>`config/apis/brave_eagle.rb`</small>

<<< @/app/config/apis/brave_eagle.rb

## Models

<small>`app/models/brave_eagle/task.rb`</small>

<<< @/app/app/models/brave_eagle/task.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| title | string |  |  |
| description | text | ✓ |  |
| status | string | ✓ | pending |
| priority | string | ✓ | medium |
| due_date | datetime | ✓ |  |
| archived | boolean | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/brave_eagle/task_schema.rb`</small>

<<< @/app/app/schemas/brave_eagle/task_schema.rb

## Contracts

<small>`app/contracts/brave_eagle/task_contract.rb`</small>

<<< @/app/app/contracts/brave_eagle/task_contract.rb

## Controllers

<small>`app/controllers/brave_eagle/tasks_controller.rb`</small>

<<< @/app/app/controllers/brave_eagle/tasks_controller.rb

---



## Request Examples

<details>
<summary>List all tasks</summary>

**Request**

```http
GET /brave-eagle/tasks
```

**Response** `200`

```json
{
  "tasks": [
    {
      "id": "0ddc4a3c-790f-48c4-88fe-31eccc37831e",
      "title": "Write documentation",
      "description": null,
      "status": "pending",
      "priority": "high",
      "due_date": null,
      "archived": false,
      "created_at": "2025-12-07T13:14:56.765Z",
      "updated_at": "2025-12-07T13:14:56.765Z"
    },
    {
      "id": "ddea330c-eb5d-4313-a167-b4344bd6efed",
      "title": "Review pull request",
      "description": null,
      "status": "completed",
      "priority": "medium",
      "due_date": null,
      "archived": false,
      "created_at": "2025-12-07T13:14:56.766Z",
      "updated_at": "2025-12-07T13:14:56.766Z"
    }
  ],
  "pagination": {
    "current": 1,
    "next": null,
    "prev": null,
    "total": 1,
    "items": 2
  }
}
```

</details>

<details>
<summary>Create a task</summary>

**Request**

```http
POST /brave-eagle/tasks
Content-Type: application/json

{
  "task": {
    "title": "New feature implementation",
    "description": "Implement the new dashboard widget",
    "status": "pending",
    "priority": "high",
    "due_date": "2024-02-01"
  }
}
```

**Response** `201`

```json
{
  "task": {
    "id": "08015137-9909-4f00-92d9-3c46f2bfad96",
    "title": "New feature implementation",
    "description": "Implement the new dashboard widget",
    "status": "pending",
    "priority": "high",
    "due_date": "2024-02-01T00:00:00.000Z",
    "archived": false,
    "created_at": "2025-12-07T13:14:56.779Z",
    "updated_at": "2025-12-07T13:14:56.779Z"
  }
}
```

</details>

<details>
<summary>Archive a task (deprecated)</summary>

**Request**

```http
PATCH /brave-eagle/tasks/1dc8104f-170e-425c-88ff-534844b6d535/archive
```

**Response** `200`

```json
{
  "task": {
    "id": "1dc8104f-170e-425c-88ff-534844b6d535",
    "title": "Old task to archive",
    "description": null,
    "status": "completed",
    "priority": "medium",
    "due_date": null,
    "archived": true,
    "created_at": "2025-12-07T13:14:56.782Z",
    "updated_at": "2025-12-07T13:14:56.787Z"
  }
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/app/public/brave-eagle/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/brave-eagle/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/brave-eagle/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/brave-eagle/openapi.yml

</details>