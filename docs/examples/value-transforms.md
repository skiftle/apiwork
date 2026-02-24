---
order: 14
---

# Value Transforms

Transform values on input/output and handle nil/empty string conversion

## API Definition

<small>`config/apis/swift_fox.rb`</small>

<<< @/playground/config/apis/swift_fox.rb

## Models

<small>`app/models/swift_fox/contact.rb`</small>

<<< @/playground/app/models/swift_fox/contact.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| email | string | ✓ |  |
| name | string |  |  |
| notes | string | ✓ |  |
| phone | string | ✓ |  |
| updated_at | datetime |  |  |

:::

## Representations

<small>`app/representations/swift_fox/contact_representation.rb`</small>

<<< @/playground/app/representations/swift_fox/contact_representation.rb

## Contracts

<small>`app/contracts/swift_fox/contact_contract.rb`</small>

<<< @/playground/app/contracts/swift_fox/contact_contract.rb

## Controllers

<small>`app/controllers/swift_fox/contacts_controller.rb`</small>

<<< @/playground/app/controllers/swift_fox/contacts_controller.rb

## Request Examples

::: details Create with transforms

**Request**

```http
POST /swift_fox/contacts
Content-Type: application/json

{
  "contact": {
    "name": "John Doe",
    "email": "John.Doe@Example.COM",
    "phone": "",
    "notes": ""
  }
}
```

**Response** `201`

```json
{
  "contact": {
    "id": "a8683ee9-6e2e-525c-84e5-103a4b4230cb",
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "",
    "notes": "",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

::: details Show transformed data

**Request**

```http
GET /swift_fox/contacts/a8683ee9-6e2e-525c-84e5-103a4b4230cb
```

**Response** `200`

```json
{
  "contact": {
    "id": "a8683ee9-6e2e-525c-84e5-103a4b4230cb",
    "name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "",
    "notes": "",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

## Generated Output

::: details Introspection

<<< @/playground/public/swift-fox/introspection.json

:::

::: details TypeScript

<<< @/playground/public/swift-fox/typescript.ts

:::

::: details Zod

<<< @/playground/public/swift-fox/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/swift-fox/openapi.yml

:::