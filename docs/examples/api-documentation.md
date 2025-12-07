---
order: 11
---

# API Documentation

Document APIs with descriptions, examples, formats, and deprecation notices at every level

## API Definition

<small>`config/apis/brave_eagle.rb`</small>

<<< @/app/config/apis/brave_eagle.rb

## Models

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

## Schemas

<small>`app/schemas/brave_eagle/user_schema.rb`</small>

<<< @/app/app/schemas/brave_eagle/user_schema.rb

<small>`app/schemas/brave_eagle/task_schema.rb`</small>

<<< @/app/app/schemas/brave_eagle/task_schema.rb

<small>`app/schemas/brave_eagle/comment_schema.rb`</small>

<<< @/app/app/schemas/brave_eagle/comment_schema.rb

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
      "id": "69f42c3a-320d-4ff3-8d28-ad8fcc7e5e76",
      "title": "Write documentation",
      "description": "Complete the API reference guide",
      "status": "pending",
      "priority": "high",
      "dueDate": null,
      "archived": false,
      "createdAt": "2025-12-07T17:20:06.576Z",
      "updatedAt": "2025-12-07T17:20:06.576Z"
    },
    {
      "id": "b34b045b-0829-432e-94d8-fd3cc189e65d",
      "title": "Review pull request",
      "description": null,
      "status": "completed",
      "priority": "medium",
      "dueDate": null,
      "archived": false,
      "createdAt": "2025-12-07T17:20:06.578Z",
      "updatedAt": "2025-12-07T17:20:06.578Z"
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
GET /brave_eagle/tasks/0b77e4ba-a045-4f77-8530-876fa70746f7
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
    "assignee_id": "4897f829-15ef-4605-b631-10079f4cf0f5"
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
PATCH /brave_eagle/tasks/ae81cf6f-ae09-4d9a-ab80-d3f0146569de/archive
```

**Response** `200`

```json
{
  "task": {
    "id": "ae81cf6f-ae09-4d9a-ab80-d3f0146569de",
    "title": "Old task to archive",
    "description": null,
    "status": "completed",
    "priority": "medium",
    "dueDate": null,
    "archived": true,
    "createdAt": "2025-12-07T17:20:06.614Z",
    "updatedAt": "2025-12-07T17:20:06.619Z"
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