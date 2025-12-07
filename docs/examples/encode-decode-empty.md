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
<summary>Database Schema</summary>

<<< @/app/public/swift-fox/schema.md

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
<summary>create_with_transforms</summary>

**Request**

```http
POST /swift-fox/contacts
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
    "id": "cf669332-d3b1-4db9-bc19-cdaa635bcffb",
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "",
    "notes": ""
  }
}
```

</details>

<details>
<summary>show_transformed</summary>

**Request**

```http
GET /swift-fox/contacts/649b49ef-6b6d-44cb-a804-383d841d5302
```

**Response** `200`

```json
{
  "contact": {
    "id": "649b49ef-6b6d-44cb-a804-383d841d5302",
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