---
order: 13
---

# Inline Type Definitions

Define typed JSON columns with object shapes, arrays, and nested structures

## API Definition

<small>`config/apis/curious_cat.rb`</small>

<<< @/playground/config/apis/curious_cat.rb

## Models

<small>`app/models/curious_cat/profile.rb`</small>

<<< @/playground/app/models/curious_cat/profile.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| name | string |  |  |
| email | string |  |  |
| settings | json |  |  |
| tags | text |  |  |
| addresses | json |  |  |
| preferences | json |  |  |
| metadata | text |  |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/curious_cat/profile_schema.rb`</small>

<<< @/playground/app/schemas/curious_cat/profile_schema.rb

The schema demonstrates all inline type variants:

- **Object shape** (`settings`) — `json` column + `store_accessor` for direct attribute access
- **Array of primitives** (`tags`) — `text` column + `serialize :tags, coder: JSON`
- **Array of objects** (`addresses`) — `json` column with block defining element shape
- **Nested objects** (`preferences`) — `json` column with nested `param :name, type: :object do ... end`
- **Untyped JSON** (`metadata`) — `text` column + `store :metadata, coder: JSON`

## Contracts

<small>`app/contracts/curious_cat/profile_contract.rb`</small>

<<< @/playground/app/contracts/curious_cat/profile_contract.rb

## Controllers

<small>`app/controllers/curious_cat/profiles_controller.rb`</small>

<<< @/playground/app/controllers/curious_cat/profiles_controller.rb

---

## Request Examples

<details>
<summary>Create a profile with all inline types</summary>

**Request**

```http
POST /curious_cat/profiles
Content-Type: application/json

{
  "profile": {
    "name": "Alice",
    "email": "alice@example.com",
    "settings": {
      "theme": "dark",
      "notifications": true,
      "language": "en"
    },
    "tags": ["developer", "typescript"],
    "addresses": [
      {
        "street": "123 Main St",
        "city": "Stockholm",
        "zip": "12345",
        "primary": true
      }
    ],
    "preferences": {
      "ui": {
        "theme": "compact",
        "sidebarCollapsed": false
      },
      "notifications": {
        "email": true,
        "push": false
      }
    },
    "metadata": {
      "source": "api",
      "version": 2
    }
  }
}
```

**Response** `201`

```json
{
  "profile": {
    "id": "abc123",
    "name": "Alice",
    "email": "alice@example.com",
    "settings": {
      "theme": "dark",
      "notifications": true,
      "language": "en"
    },
    "tags": ["developer", "typescript"],
    "addresses": [
      {
        "street": "123 Main St",
        "city": "Stockholm",
        "zip": "12345",
        "primary": true
      }
    ],
    "preferences": {
      "ui": {
        "theme": "compact",
        "sidebarCollapsed": false
      },
      "notifications": {
        "email": true,
        "push": false
      }
    },
    "metadata": {
      "source": "api",
      "version": 2
    },
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

</details>

<details>
<summary>Update with partial inline types</summary>

**Request**

```http
PATCH /curious_cat/profiles/abc123
Content-Type: application/json

{
  "profile": {
    "settings": {
      "theme": "light",
      "notifications": false,
      "language": "sv"
    },
    "tags": ["developer", "ruby", "rails"]
  }
}
```

**Response** `200`

```json
{
  "profile": {
    "id": "abc123",
    "name": "Alice",
    "email": "alice@example.com",
    "settings": {
      "theme": "light",
      "notifications": false,
      "language": "sv"
    },
    "tags": ["developer", "ruby", "rails"],
    "addresses": [
      {
        "street": "123 Main St",
        "city": "Stockholm",
        "zip": "12345",
        "primary": true
      }
    ],
    "preferences": {
      "ui": {
        "theme": "compact",
        "sidebarCollapsed": false
      },
      "notifications": {
        "email": true,
        "push": false
      }
    },
    "metadata": {
      "source": "api",
      "version": 2
    },
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-01-15T11:00:00.000Z"
  }
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/curious-cat/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/curious-cat/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/curious-cat/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/curious-cat/openapi.yml

</details>