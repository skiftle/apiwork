---
order: 12
---

# API Documentation (I18n)

Using built-in I18n for translatable API documentation

## API Definition

<small>`config/apis/wise_tiger.rb`</small>

<<< @/playground/config/apis/wise_tiger.rb

## Models

<small>`app/models/wise_tiger/project.rb`</small>

<<< @/playground/app/models/wise_tiger/project.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| deadline | date | ✓ |  |
| description | text | ✓ |  |
| name | string |  |  |
| priority | string | ✓ | medium |
| status | string | ✓ | active |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/wise_tiger/project_schema.rb`</small>

<<< @/playground/app/schemas/wise_tiger/project_schema.rb

## Contracts

<small>`app/contracts/wise_tiger/project_contract.rb`</small>

<<< @/playground/app/contracts/wise_tiger/project_contract.rb

## Controllers

<small>`app/controllers/wise_tiger/projects_controller.rb`</small>

<<< @/playground/app/controllers/wise_tiger/projects_controller.rb

## Locales

<small>`config/locales/wise_tiger.en.yml`</small>

<<< @/playground/config/locales/wise_tiger.en.yml

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
      "id": "48b9294b-b5f6-51ea-9c77-a28d821b337d",
      "name": "Website Redesign",
      "description": "Complete overhaul of the company website",
      "status": "active",
      "priority": "high",
      "deadline": null,
      "createdAt": "2025-12-18T14:06:00.019Z",
      "updatedAt": "2025-12-18T14:06:00.019Z"
    },
    {
      "id": "37e7aaed-3cb7-5641-b7be-3e698b300b7c",
      "name": "Mobile App",
      "description": "Native iOS and Android apps",
      "status": "paused",
      "priority": "medium",
      "deadline": null,
      "createdAt": "2025-12-18T14:06:00.021Z",
      "updatedAt": "2025-12-18T14:06:00.021Z"
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
GET /wise_tiger/projects/7ce6e5ed-28f5-52ba-83bc-a726660c12bc
```

**Response** `200`

```json
{
  "project": {
    "id": "7ce6e5ed-28f5-52ba-83bc-a726660c12bc",
    "name": "API Integration",
    "description": "Connect to third-party services",
    "status": "active",
    "priority": "critical",
    "deadline": "2024-06-01",
    "createdAt": "2025-12-18T14:06:00.029Z",
    "updatedAt": "2025-12-18T14:06:00.029Z"
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
    "id": "3161e556-4c18-54ab-8027-a5ac92b19bcb",
    "name": "New Feature",
    "description": "Implement the new dashboard",
    "status": "active",
    "priority": "high",
    "deadline": "2024-03-15",
    "createdAt": "2025-12-18T14:06:00.042Z",
    "updatedAt": "2025-12-18T14:06:00.042Z"
  }
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/wise-tiger/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/wise-tiger/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/wise-tiger/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/wise-tiger/openapi.yml

</details>