---
order: 1
---

# Manual Contract

Defining contracts manually without schemas

## API Definition

<small>`config/apis/funny_snake.rb`</small>

<<< @/app/config/apis/funny_snake.rb

## Models

<small>`app/models/funny_snake/invoice.rb`</small>

<<< @/app/app/models/funny_snake/invoice.rb

## Contracts

<small>`app/contracts/funny_snake/invoice_contract.rb`</small>

<<< @/app/app/contracts/funny_snake/invoice_contract.rb

## Controllers

<small>`app/controllers/funny_snake/invoices_controller.rb`</small>

<<< @/app/app/controllers/funny_snake/invoices_controller.rb

---



## Request Examples

<details>
<summary>index</summary>

**Request**

```http
GET /funny-snake/invoices
```

**Response** `200`

```json
[]
```

</details>

<details>
<summary>show</summary>

**Request**

```http
GET /funny-snake/invoices/9691df22-fa8c-43f6-b5ad-46ebb338c18f
```

**Response** `200`

```json
{
  "id": "9691df22-fa8c-43f6-b5ad-46ebb338c18f",
  "number": "INV-001",
  "issued_on": null,
  "status": "draft",
  "notes": null,
  "created_at": "2025-12-07T08:42:27.260Z",
  "updated_at": "2025-12-07T08:42:27.260Z"
}
```

</details>

<details>
<summary>create</summary>

**Request**

```http
POST /funny-snake/invoices
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "issued_on": "2024-01-15",
    "status": "draft",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "id": "281bdcdb-cff1-406b-a5f0-16debe55f7a3",
  "number": "INV-001",
  "issued_on": "2024-01-15",
  "status": "draft",
  "notes": "First invoice",
  "created_at": "2025-12-07T08:42:27.272Z",
  "updated_at": "2025-12-07T08:42:27.272Z"
}
```

</details>

<details>
<summary>update</summary>

**Request**

```http
PATCH /funny-snake/invoices/93e8965b-f3a0-4339-8543-1d1bc7fccbd4
Content-Type: application/json

{
  "invoice": {
    "status": "sent"
  }
}
```

**Response** `400`

```json
{
  "issues": [
    {
      "code": "field_missing",
      "detail": "Field required",
      "path": [
        "invoice",
        "number"
      ],
      "pointer": "/invoice/number",
      "meta": {
        "field": "number"
      }
    },
    {
      "code": "field_missing",
      "detail": "Field required",
      "path": [
        "invoice",
        "issued_on"
      ],
      "pointer": "/invoice/issued_on",
      "meta": {
        "field": "issued_on"
      }
    },
    {
      "code": "field_missing",
      "detail": "Field required",
      "path": [
        "invoice",
        "notes"
      ],
      "pointer": "/invoice/notes",
      "meta": {
        "field": "notes"
      }
    }
  ]
}
```

</details>

<details>
<summary>destroy</summary>

**Request**

```http
DELETE /funny-snake/invoices/32aa7298-f8a7-4121-8abe-ecb69de3ce17
```

**Response** `200`

```json
{
  "id": "32aa7298-f8a7-4121-8abe-ecb69de3ce17",
  "number": "INV-001",
  "issued_on": null,
  "status": null,
  "notes": null,
  "created_at": "2025-12-07T08:42:27.280Z",
  "updated_at": "2025-12-07T08:42:27.280Z"
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/app/public/funny-snake/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/funny-snake/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/funny-snake/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/funny-snake/openapi.yml

</details>