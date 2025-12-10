---
order: 12
---

# API Documentation (I18n)

Using built-in I18n for translatable API documentation

## API Definition

<small>`config/apis/wise_tiger.rb`</small>

<<< @/app/config/apis/wise_tiger.rb

## Models

<small>`app/models/wise_tiger/project.rb`</small>

<<< @/app/app/models/wise_tiger/project.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| name | string |  |  |
| description | text | ✓ |  |
| status | string | ✓ | active |
| priority | string | ✓ | medium |
| deadline | date | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/wise_tiger/project_schema.rb`</small>

<<< @/app/app/schemas/wise_tiger/project_schema.rb

## Contracts

<small>`app/contracts/wise_tiger/project_contract.rb`</small>

<<< @/app/app/contracts/wise_tiger/project_contract.rb

## Controllers

<small>`app/controllers/wise_tiger/projects_controller.rb`</small>

<<< @/app/app/controllers/wise_tiger/projects_controller.rb

## Locales

<small>`config/locales/wise_tiger.en.yml`</small>

<<< @/app/config/locales/wise_tiger.en.yml

---



## Request Examples

<details>
<summary>List all projects</summary>

**Request**

```http
GET /wise_tiger/projects
```

**Response** `200`

```json
{
  "projects": [
    {
      "id": "412aea8f-7fad-4955-8f3a-c4f706c11693",
      "name": "Website Redesign",
      "description": "Complete overhaul of the company website",
      "status": "active",
      "priority": "high",
      "deadline": null,
      "createdAt": "2025-12-10T10:35:26.951Z",
      "updatedAt": "2025-12-10T10:35:26.951Z"
    },
    {
      "id": "62424e42-0a01-4940-addb-43774e3dce01",
      "name": "Mobile App",
      "description": "Native iOS and Android apps",
      "status": "paused",
      "priority": "medium",
      "deadline": null,
      "createdAt": "2025-12-10T10:35:26.952Z",
      "updatedAt": "2025-12-10T10:35:26.952Z"
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
<summary>Get project details</summary>

**Request**

```http
GET /wise_tiger/projects/7a0fa960-99cb-4d7d-9b56-9a01e432fd20
```

**Response** `200`

```json
{
  "project": {
    "id": "7a0fa960-99cb-4d7d-9b56-9a01e432fd20",
    "name": "API Integration",
    "description": "Connect to third-party services",
    "status": "active",
    "priority": "critical",
    "deadline": "2024-06-01",
    "createdAt": "2025-12-10T10:35:26.961Z",
    "updatedAt": "2025-12-10T10:35:26.961Z"
  }
}
```

</details>

<details>
<summary>Create a project</summary>

**Request**

```http
POST /wise_tiger/projects
Content-Type: application/json

{
  "project": {
    "name": "New Feature",
    "description": "Implement the new dashboard",
    "status": "active",
    "priority": "high",
    "deadline": "2024-03-15"
  }
}
```

**Response** `201`

```json
{
  "project": {
    "id": "3622ffac-4225-41cb-a7fd-38ae26d37e47",
    "name": "New Feature",
    "description": "Implement the new dashboard",
    "status": "active",
    "priority": "high",
    "deadline": "2024-03-15",
    "createdAt": "2025-12-10T10:35:26.971Z",
    "updatedAt": "2025-12-10T10:35:26.971Z"
  }
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/app/public/wise-tiger/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/wise-tiger/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/wise-tiger/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/wise-tiger/openapi.yml

</details>