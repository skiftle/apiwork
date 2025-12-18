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
      "id": "4079e8f6-a46b-4463-875a-8f832c64d554",
      "name": "Website Redesign",
      "description": "Complete overhaul of the company website",
      "status": "active",
      "priority": "high",
      "deadline": null,
      "createdAt": "2025-12-18T13:21:02.604Z",
      "updatedAt": "2025-12-18T13:21:02.604Z"
    },
    {
      "id": "80cf6b0b-eb1d-47dd-8932-5124eefcf026",
      "name": "Mobile App",
      "description": "Native iOS and Android apps",
      "status": "paused",
      "priority": "medium",
      "deadline": null,
      "createdAt": "2025-12-18T13:21:02.605Z",
      "updatedAt": "2025-12-18T13:21:02.605Z"
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
GET /wise_tiger/projects/61e4608d-1201-48f5-ab03-c0d53d1e14bd
```

**Response** `200`

```json
{
  "project": {
    "id": "61e4608d-1201-48f5-ab03-c0d53d1e14bd",
    "name": "API Integration",
    "description": "Connect to third-party services",
    "status": "active",
    "priority": "critical",
    "deadline": "2024-06-01",
    "createdAt": "2025-12-18T13:21:02.613Z",
    "updatedAt": "2025-12-18T13:21:02.613Z"
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
    "id": "8d4a5f7e-7e35-4be9-a3d3-071041d7e533",
    "name": "New Feature",
    "description": "Implement the new dashboard",
    "status": "active",
    "priority": "high",
    "deadline": "2024-03-15",
    "createdAt": "2025-12-18T13:21:02.625Z",
    "updatedAt": "2025-12-18T13:21:02.625Z"
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