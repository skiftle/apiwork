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
| addresses | json |  |  |
| created_at | datetime |  |  |
| email | string |  |  |
| metadata | text |  |  |
| name | string |  |  |
| preferences | json |  |  |
| settings | json |  |  |
| tags | text |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

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
    "tags": [
      "developer",
      "typescript"
    ],
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
        "sidebar_collapsed": false
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
    "id": "696f7bb0-6a34-5c02-b53f-46e76dd02494",
    "name": "Alice",
    "email": "alice@example.com",
    "settings": {
      "theme": "dark",
      "notifications": true,
      "language": "en"
    },
    "tags": [
      "developer",
      "typescript"
    ],
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
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

</details>

<details>
<summary>Update profile settings and tags</summary>

**Request**

```http
PATCH /curious_cat/profiles/6f45e345-dbd9-543b-bfd8-0f430bd8299f
Content-Type: application/json

{
  "profile": {
    "name": "Alice",
    "email": "alice@example.com",
    "settings": {
      "theme": "light",
      "notifications": false,
      "language": "sv"
    },
    "tags": [
      "developer",
      "ruby",
      "rails"
    ],
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
        "sidebar_collapsed": false
      },
      "notifications": {
        "email": true,
        "push": false
      }
    },
    "metadata": {
      "source": "api",
      "version": 3
    }
  }
}
```

**Response** `200`

```json
{
  "profile": {
    "id": "6f45e345-dbd9-543b-bfd8-0f430bd8299f",
    "name": "Alice",
    "email": "alice@example.com",
    "settings": {
      "theme": "light",
      "notifications": false,
      "language": "sv"
    },
    "tags": [
      "developer",
      "ruby",
      "rails"
    ],
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
      "version": 3
    },
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