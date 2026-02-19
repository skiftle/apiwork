---
order: 11
---

# API Documentation

Document APIs with descriptions, examples, formats, and deprecation notices at every level

## API Definition

<small>`config/apis/brave_eagle.rb`</small>

<<< @/playground/config/apis/brave_eagle.rb

## Models

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

## Representations

<small>`app/representations/brave_eagle/task_representation.rb`</small>

<<< @/playground/app/representations/brave_eagle/task_representation.rb

<small>`app/representations/brave_eagle/user_representation.rb`</small>

<<< @/playground/app/representations/brave_eagle/user_representation.rb

<small>`app/representations/brave_eagle/comment_representation.rb`</small>

<<< @/playground/app/representations/brave_eagle/comment_representation.rb

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
      "id": "0ec28309-26a2-5f19-92c0-3b60b8796f2e",
      "title": "Write documentation",
      "description": "Complete the API reference guide",
      "status": "pending",
      "priority": "high",
      "dueDate": null,
      "archived": false,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "87bd2ab1-033b-5369-b8e7-687307ff4f1b",
      "title": "Review pull request",
      "description": null,
      "status": "completed",
      "priority": "medium",
      "dueDate": null,
      "archived": false,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 2,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
  }
}
```

</details>

<details>
<summary>Get task details</summary>

**Request**

```http
GET /brave_eagle/tasks/0ec28309-26a2-5f19-92c0-3b60b8796f2e
```

**Response** `200`

```json
{
  "task": {
    "id": "0ec28309-26a2-5f19-92c0-3b60b8796f2e",
    "title": "Implement login",
    "description": "Add OAuth2 support",
    "status": "in_progress",
    "priority": "critical",
    "dueDate": "2024-02-01T00:00:00.000Z",
    "archived": false,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
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
    "id": "0ec28309-26a2-5f19-92c0-3b60b8796f2e",
    "title": "New feature implementation",
    "description": "Implement the new dashboard widget",
    "status": "pending",
    "priority": "high",
    "dueDate": "2024-02-01T00:00:00.000Z",
    "archived": false,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

</details>

<details>
<summary>Archive a task (deprecated)</summary>

**Request**

```http
PATCH /brave_eagle/tasks/0ec28309-26a2-5f19-92c0-3b60b8796f2e/archive
```

**Response** `200`

```json
{
  "task": {
    "id": "0ec28309-26a2-5f19-92c0-3b60b8796f2e",
    "title": "Old task to archive",
    "description": null,
    "status": "completed",
    "priority": "medium",
    "dueDate": null,
    "archived": true,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
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