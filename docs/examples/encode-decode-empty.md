---
order: 9
---

# Encode, Decode & Empty

Transform values on input/output and handle nil/empty string conversion

## API Definition

<small>`config/apis/swift_fox.rb`</small>

<<< @/playground/config/apis/swift_fox.rb

## Models

<small>`app/models/swift_fox/contact.rb`</small>

<<< @/playground/app/models/swift_fox/contact.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| email | string | ✓ |  |
| name | string |  |  |
| notes | string | ✓ |  |
| phone | string | ✓ |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/swift_fox/contact_schema.rb`</small>

<<< @/playground/app/schemas/swift_fox/contact_schema.rb

## Contracts

<small>`app/contracts/swift_fox/contact_contract.rb`</small>

<<< @/playground/app/contracts/swift_fox/contact_contract.rb

## Controllers

<small>`app/controllers/swift_fox/contacts_controller.rb`</small>

<<< @/playground/app/controllers/swift_fox/contacts_controller.rb

---



## Request Examples

<details>
<summary>Create with transforms</summary>

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
    "id": "c163bab9-6a02-4a10-b1c3-ebf634284ac9",
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "",
    "notes": ""
  }
}
```

</details>

<details>
<summary>Show transformed data</summary>

**Request**

```http
GET /swift_fox/contacts/47f94dcc-13ba-4336-a2fc-9fbb1dc36497
```

**Response** `200`

```json
{
  "contact": {
    "id": "47f94dcc-13ba-4336-a2fc-9fbb1dc36497",
    "name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "",
    "notes": ""
  }
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/swift-fox/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/swift-fox/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/swift-fox/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/swift-fox/openapi.yml

</details>