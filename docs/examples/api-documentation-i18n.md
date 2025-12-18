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
      "id": "1d7bfbd4-d888-4a73-918d-ea0f3156e0b0",
      "name": "Website Redesign",
      "description": "Complete overhaul of the company website",
      "status": "active",
      "priority": "high",
      "deadline": null,
      "createdAt": "2025-12-18T13:29:04.643Z",
      "updatedAt": "2025-12-18T13:29:04.643Z"
    },
    {
      "id": "5068d933-7483-4f8a-8a8e-4813ec8c852f",
      "name": "Mobile App",
      "description": "Native iOS and Android apps",
      "status": "paused",
      "priority": "medium",
      "deadline": null,
      "createdAt": "2025-12-18T13:29:04.645Z",
      "updatedAt": "2025-12-18T13:29:04.645Z"
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
GET /wise_tiger/projects/07ff7948-5326-4236-9cbc-d7b44222bd51
```

**Response** `200`

```json
{
  "project": {
    "id": "07ff7948-5326-4236-9cbc-d7b44222bd51",
    "name": "API Integration",
    "description": "Connect to third-party services",
    "status": "active",
    "priority": "critical",
    "deadline": "2024-06-01",
    "createdAt": "2025-12-18T13:29:04.655Z",
    "updatedAt": "2025-12-18T13:29:04.655Z"
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
    "id": "1326bb0c-bf0a-4953-a752-65f064afc820",
    "name": "New Feature",
    "description": "Implement the new dashboard",
    "status": "active",
    "priority": "high",
    "deadline": "2024-03-15",
    "createdAt": "2025-12-18T13:29:04.666Z",
    "updatedAt": "2025-12-18T13:29:04.666Z"
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