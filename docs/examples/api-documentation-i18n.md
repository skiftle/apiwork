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
      "id": "da7fe627-539c-4e1c-a16f-22c0becf123d",
      "name": "Website Redesign",
      "description": "Complete overhaul of the company website",
      "status": "active",
      "priority": "high",
      "deadline": null,
      "createdAt": "2025-12-07T17:09:10.288Z",
      "updatedAt": "2025-12-07T17:09:10.288Z"
    },
    {
      "id": "391ca84d-b191-44a5-b8b2-7e8ce9487cab",
      "name": "Mobile App",
      "description": "Native iOS and Android apps",
      "status": "paused",
      "priority": "medium",
      "deadline": null,
      "createdAt": "2025-12-07T17:09:10.290Z",
      "updatedAt": "2025-12-07T17:09:10.290Z"
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
GET /wise_tiger/projects/0fe54d80-fc37-4cb6-8bbc-9fa7d9820fe5
```

**Response** `200`

```json
{
  "project": {
    "id": "0fe54d80-fc37-4cb6-8bbc-9fa7d9820fe5",
    "name": "API Integration",
    "description": "Connect to third-party services",
    "status": "active",
    "priority": "critical",
    "deadline": "2024-06-01",
    "createdAt": "2025-12-07T17:09:10.299Z",
    "updatedAt": "2025-12-07T17:09:10.299Z"
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
    "id": "8b97e1b2-29d2-48a9-a220-eba3bca9c41d",
    "name": "New Feature",
    "description": "Implement the new dashboard",
    "status": "active",
    "priority": "high",
    "deadline": "2024-03-15",
    "createdAt": "2025-12-07T17:09:10.310Z",
    "updatedAt": "2025-12-07T17:09:10.310Z"
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