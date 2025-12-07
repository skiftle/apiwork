---
order: 11
---

# API Documentation

Document APIs with descriptions, examples, formats, and deprecation notices at every level

## API Definition

<small>`config/apis/brave_eagle.rb`</small>

<<< @/app/config/apis/brave_eagle.rb

## Models

<small>`app/models/brave_eagle/comment.rb`</small>

<<< @/app/app/models/brave_eagle/comment.rb

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
| assignee_id | string | ✓ |  |

</details>

<small>`app/models/brave_eagle/user.rb`</small>

<<< @/app/app/models/brave_eagle/user.rb

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

## Schemas

<small>`app/schemas/brave_eagle/comment_schema.rb`</small>

<<< @/app/app/schemas/brave_eagle/comment_schema.rb

<small>`app/schemas/brave_eagle/task_schema.rb`</small>

<<< @/app/app/schemas/brave_eagle/task_schema.rb

<small>`app/schemas/brave_eagle/user_schema.rb`</small>

<<< @/app/app/schemas/brave_eagle/user_schema.rb

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
      "id": "10199d27-8385-4a86-bf3a-c89e22582a42",
      "title": "Write documentation",
      "description": "Complete the API reference guide",
      "status": "pending",
      "priority": "high",
      "dueDate": null,
      "archived": false,
      "createdAt": "2025-12-07T16:17:39.538Z",
      "updatedAt": "2025-12-07T16:17:39.538Z"
    },
    {
      "id": "a0aecd34-3bc4-48ad-9ce4-6fe304f8766c",
      "title": "Review pull request",
      "description": null,
      "status": "completed",
      "priority": "medium",
      "dueDate": null,
      "archived": false,
      "createdAt": "2025-12-07T16:17:39.540Z",
      "updatedAt": "2025-12-07T16:17:39.540Z"
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
GET /brave_eagle/tasks/da44f5d1-1b22-47f7-a8ef-c0c9761ab172
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
    "assignee_id": "b53dd0dc-6af8-4605-8b1f-85beda5effd3"
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
PATCH /brave_eagle/tasks/c9f57404-1454-4bc8-8801-fd719003b890/archive
```

**Response** `200`

```json
{
  "task": {
    "id": "c9f57404-1454-4bc8-8801-fd719003b890",
    "title": "Old task to archive",
    "description": null,
    "status": "completed",
    "priority": "medium",
    "dueDate": null,
    "archived": true,
    "createdAt": "2025-12-07T16:17:39.577Z",
    "updatedAt": "2025-12-07T16:17:39.582Z"
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