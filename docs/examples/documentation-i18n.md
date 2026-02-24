---
order: 18
---

# Documentation I18n

Translatable API documentation with built-in I18n support

## API Definition

<small>`config/apis/wise_tiger.rb`</small>

<<< @/playground/config/apis/wise_tiger.rb

## Models

<small>`app/models/wise_tiger/project.rb`</small>

<<< @/playground/app/models/wise_tiger/project.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| deadline | date | ✓ |  |
| description | text | ✓ |  |
| name | string |  |  |
| priority | integer |  | 1 |
| status | integer |  | 0 |
| updated_at | datetime |  |  |

:::

## Representations

<small>`app/representations/wise_tiger/project_representation.rb`</small>

<<< @/playground/app/representations/wise_tiger/project_representation.rb

## Contracts

<small>`app/contracts/wise_tiger/project_contract.rb`</small>

<<< @/playground/app/contracts/wise_tiger/project_contract.rb

## Controllers

<small>`app/controllers/wise_tiger/projects_controller.rb`</small>

<<< @/playground/app/controllers/wise_tiger/projects_controller.rb

## Locales

<small>`config/locales/wise_tiger.en.yml`</small>

<<< @/playground/config/locales/wise_tiger.en.yml

## Request Examples

::: details List all projects

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
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "37e7aaed-3cb7-5641-b7be-3e698b300b7c",
      "name": "Mobile App",
      "description": "Native iOS and Android apps",
      "status": "paused",
      "priority": "medium",
      "deadline": null,
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

:::

::: details Get project details

**Request**

```http
GET /wise_tiger/projects/48b9294b-b5f6-51ea-9c77-a28d821b337d
```

**Response** `200`

```json
{
  "project": {
    "id": "48b9294b-b5f6-51ea-9c77-a28d821b337d",
    "name": "API Integration",
    "description": "Connect to third-party services",
    "status": "active",
    "priority": "critical",
    "deadline": "2024-06-01",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

::: details Create a project

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
    "id": "48b9294b-b5f6-51ea-9c77-a28d821b337d",
    "name": "New Feature",
    "description": "Implement the new dashboard",
    "status": "active",
    "priority": "high",
    "deadline": "2024-03-15",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

## Generated Output

::: details Introspection

<<< @/playground/public/wise-tiger/introspection.json

:::

::: details TypeScript

<<< @/playground/public/wise-tiger/typescript.ts

:::

::: details Zod

<<< @/playground/public/wise-tiger/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/wise-tiger/openapi.yml

:::