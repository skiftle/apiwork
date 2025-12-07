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
GET /brave_eagle/tasks
```

**Response** `200`

```json
{
  "tasks": [
    {
      "id": "3bde0316-e5b5-4a9e-b93b-550fd40f87ca",
      "title": "Write documentation",
      "description": null,
      "status": "pending",
      "priority": "high",
      "dueDate": null,
      "archived": false,
      "createdAt": "2025-12-07T13:30:59.537Z",
      "updatedAt": "2025-12-07T13:30:59.537Z"
    },
    {
      "id": "03a273f8-f639-4f83-a357-57a3c92c127f",
      "title": "Review pull request",
      "description": null,
      "status": "completed",
      "priority": "medium",
      "dueDate": null,
      "archived": false,
      "createdAt": "2025-12-07T13:30:59.559Z",
      "updatedAt": "2025-12-07T13:30:59.559Z"
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
POST /brave_eagle/tasks
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
    "id": "a40b25ed-dbbc-404b-86f0-1ff5424f423f",
    "title": "New feature implementation",
    "description": "Implement the new dashboard widget",
    "status": "pending",
    "priority": "high",
    "dueDate": "2024-02-01T00:00:00.000Z",
    "archived": false,
    "createdAt": "2025-12-07T13:30:59.592Z",
    "updatedAt": "2025-12-07T13:30:59.592Z"
  }
}
```

</details>

<details>
<summary>Archive a task (deprecated)</summary>

**Request**

```http
PATCH /brave_eagle/tasks/1156466c-a3aa-4b10-aae8-255d9cdbf8bd/archive
```

**Response** `200`

```json
{
  "task": {
    "id": "1156466c-a3aa-4b10-aae8-255d9cdbf8bd",
    "title": "Old task to archive",
    "description": null,
    "status": "completed",
    "priority": "medium",
    "dueDate": null,
    "archived": true,
    "createdAt": "2025-12-07T13:30:59.597Z",
    "updatedAt": "2025-12-07T13:30:59.608Z"
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