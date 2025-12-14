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
| name | string |  |  |
| email | string |  |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/brave_eagle/task.rb`</small>

<<< @/playground/app/models/brave_eagle/task.rb

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
| assignee_id | string | ✓ |  |

</details>

<small>`app/models/brave_eagle/comment.rb`</small>

<<< @/playground/app/models/brave_eagle/comment.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| task_id | string |  |  |
| body | text |  |  |
| author_name | string | ✓ |  |
| created_at | datetime |  |  |
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
      "id": "d5269b50-123f-40a8-9aa5-4c2fd3952dcc",
      "title": "Write documentation",
      "description": "Complete the API reference guide",
      "status": "pending",
      "priority": "high",
      "dueDate": null,
      "archived": false,
      "createdAt": "2025-12-10T10:35:26.069Z",
      "updatedAt": "2025-12-10T10:35:26.069Z"
    },
    {
      "id": "43a7a1b6-5082-4e45-b1a5-f8d3f0d4d316",
      "title": "Review pull request",
      "description": null,
      "status": "completed",
      "priority": "medium",
      "dueDate": null,
      "archived": false,
      "createdAt": "2025-12-10T10:35:26.070Z",
      "updatedAt": "2025-12-10T10:35:26.070Z"
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
GET /brave_eagle/tasks/9d5a79c8-7e83-406b-a493-09c5a5901572
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
    "assignee_id": "f69f07c8-5775-4475-900c-6a72c26c5791"
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
PATCH /brave_eagle/tasks/8719fd49-4ec3-4e35-8610-f9c24d3783f3/archive
```

**Response** `200`

```json
{
  "task": {
    "id": "8719fd49-4ec3-4e35-8610-f9c24d3783f3",
    "title": "Old task to archive",
    "description": null,
    "status": "completed",
    "priority": "medium",
    "dueDate": null,
    "archived": true,
    "createdAt": "2025-12-10T10:35:26.107Z",
    "updatedAt": "2025-12-10T10:35:26.112Z"
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