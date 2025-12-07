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
      "id": "128bba19-91e4-4a4f-b924-f59a21168b4b",
      "title": "Write documentation",
      "description": null,
      "status": "pending",
      "priority": "high",
      "dueDate": null,
      "archived": false,
      "createdAt": "2025-12-07T13:22:39.544Z",
      "updatedAt": "2025-12-07T13:22:39.544Z"
    },
    {
      "id": "2fcad2b3-5e23-4ce7-b501-be44790f786c",
      "title": "Review pull request",
      "description": null,
      "status": "completed",
      "priority": "medium",
      "dueDate": null,
      "archived": false,
      "createdAt": "2025-12-07T13:22:39.553Z",
      "updatedAt": "2025-12-07T13:22:39.553Z"
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
    "id": "fa7d202b-1710-4824-b800-bba770d80d40",
    "title": "New feature implementation",
    "description": "Implement the new dashboard widget",
    "status": "pending",
    "priority": "high",
    "dueDate": "2024-02-01T00:00:00.000Z",
    "archived": false,
    "createdAt": "2025-12-07T13:22:39.567Z",
    "updatedAt": "2025-12-07T13:22:39.567Z"
  }
}
```

</details>

<details>
<summary>Archive a task (deprecated)</summary>

**Request**

```http
PATCH /brave-eagle/tasks/28a10544-a713-41d2-9cbb-14d372aed130/archive
```

**Response** `200`

```json
{
  "task": {
    "id": "28a10544-a713-41d2-9cbb-14d372aed130",
    "title": "Old task to archive",
    "description": null,
    "status": "completed",
    "priority": "medium",
    "dueDate": null,
    "archived": true,
    "createdAt": "2025-12-07T13:22:39.570Z",
    "updatedAt": "2025-12-07T13:22:39.575Z"
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