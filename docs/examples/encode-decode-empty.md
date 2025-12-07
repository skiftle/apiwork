---
order: 9
---

# Encode, Decode & Empty

Transform values on input/output and handle nil/empty string conversion

## API Definition

<small>`config/apis/swift_fox.rb`</small>

<<< @/app/config/apis/swift_fox.rb

## Models

<small>`app/models/swift_fox/contact.rb`</small>

<<< @/app/app/models/swift_fox/contact.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| name | string |  |  |
| email | string | ✓ |  |
| phone | string | ✓ |  |
| notes | string | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/swift_fox/contact_schema.rb`</small>

<<< @/app/app/schemas/swift_fox/contact_schema.rb

## Contracts

<small>`app/contracts/swift_fox/contact_contract.rb`</small>

<<< @/app/app/contracts/swift_fox/contact_contract.rb

## Controllers

<small>`app/controllers/swift_fox/contacts_controller.rb`</small>

<<< @/app/app/controllers/swift_fox/contacts_controller.rb

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
    "id": "c1db25b9-857e-46fd-8f09-6b63cbb2430e",
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
GET /swift_fox/contacts/10a545ef-a103-4be6-a6b2-1b418995d168
```

**Response** `200`

```json
{
  "contact": {
    "id": "10a545ef-a103-4be6-a6b2-1b418995d168",
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

<<< @/app/public/swift-fox/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/swift-fox/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/swift-fox/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/swift-fox/openapi.yml

</details>