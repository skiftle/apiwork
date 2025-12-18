---
order: 11
---

# API Documentation

Document APIs with descriptions, examples, formats, and deprecation notices at every level

## API Definition

<small>`config/apis/brave_eagle.rb`</small>

<<< @/playground/config/apis/brave_eagle.rb

## Models

<small>`app/models/brave_eagle/user.rb`</small>

<<< @/playground/app/models/brave_eagle/user.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| email | string |  |  |
| name | string |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/brave_eagle/task.rb`</small>

<<< @/playground/app/models/brave_eagle/task.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| archived | boolean | ✓ |  |
| assignee_id | string | ✓ |  |
| created_at | datetime |  |  |
| description | text | ✓ |  |
| due_date | datetime | ✓ |  |
| priority | string | ✓ | medium |
| status | string | ✓ | pending |
| title | string |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/brave_eagle/comment.rb`</small>

<<< @/playground/app/models/brave_eagle/comment.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| author_name | string | ✓ |  |
| body | text |  |  |
| created_at | datetime |  |  |
| task_id | string |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/brave_eagle/user_schema.rb`</small>

<<< @/playground/app/schemas/brave_eagle/user_schema.rb

<small>`app/schemas/brave_eagle/task_schema.rb`</small>

<<< @/playground/app/schemas/brave_eagle/task_schema.rb

<small>`app/schemas/brave_eagle/comment_schema.rb`</small>

<<< @/playground/app/schemas/brave_eagle/comment_schema.rb

## Contracts

<small>`app/contracts/brave_eagle/task_contract.rb`</small>

<<< @/playground/app/contracts/brave_eagle/task_contract.rb

## Controllers

<small>`app/controllers/brave_eagle/tasks_controller.rb`</small>

<<< @/playground/app/controllers/brave_eagle/tasks_controller.rb

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
      "id": "6da302ea-ac15-444f-bf4f-b37960ba8c9e",
      "title": "Write documentation",
      "description": "Complete the API reference guide",
      "status": "pending",
      "priority": "high",
      "dueDate": null,
      "archived": false,
      "createdAt": "2025-12-18T13:29:03.712Z",
      "updatedAt": "2025-12-18T13:29:03.712Z"
    },
    {
      "id": "b3858888-2fb0-4350-86a8-df13975aad90",
      "title": "Review pull request",
      "description": null,
      "status": "completed",
      "priority": "medium",
      "dueDate": null,
      "archived": false,
      "createdAt": "2025-12-18T13:29:03.714Z",
      "updatedAt": "2025-12-18T13:29:03.714Z"
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
<summary>Get task details</summary>

**Request**

```http
GET /brave_eagle/tasks/2287c87d-3f1b-4374-9963-a8e74e2d8307
```

**Response** `404`

```json
{
  "status": 404,
  "error": "Not Found"
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
    "due_date": "2024-02-01",
    "assignee_id": "0bcb0f3b-ddbc-4179-8739-b3d053dcedaf"
  }
}
```

**Response** `400`

```json
{
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "path": [
        "task",
        "assignee_id"
      ],
      "pointer": "/task/assignee_id",
      "meta": {
        "field": "assignee_id",
        "allowed": [
          "title",
          "description",
          "status",
          "priority",
          "due_date"
        ]
      }
    }
  ]
}
```

</details>

<details>
<summary>Archive a task (deprecated)</summary>

**Request**

```http
PATCH /brave_eagle/tasks/7819549c-2dcd-41bc-ad57-d5d1775b9fd0/archive
```

**Response** `200`

```json
{
  "task": {
    "id": "7819549c-2dcd-41bc-ad57-d5d1775b9fd0",
    "title": "Old task to archive",
    "description": null,
    "status": "completed",
    "priority": "medium",
    "dueDate": null,
    "archived": true,
    "createdAt": "2025-12-18T13:29:03.754Z",
    "updatedAt": "2025-12-18T13:29:03.760Z"
  }
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/brave-eagle/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/brave-eagle/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/brave-eagle/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/brave-eagle/openapi.yml

</details>