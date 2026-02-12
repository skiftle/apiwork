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

## Representations

<small>`app/representations/swift_fox/contact_representation.rb`</small>

<<< @/playground/app/representations/swift_fox/contact_representation.rb

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
    "id": "a8683ee9-6e2e-525c-84e5-103a4b4230cb",
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