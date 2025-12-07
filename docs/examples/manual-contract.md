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

### Index

**Request**

```http
GET /funny-snake/invoices
```

**Response** `200`

```json
[]
```

### Show

**Request**

```http
GET /funny-snake/invoices/ca808985-3c58-4783-a772-3bc22d024740
```

**Response** `200`

```json
{
  "id": "ca808985-3c58-4783-a772-3bc22d024740",
  "number": "INV-001",
  "issued_on": null,
  "status": "draft",
  "notes": null,
  "created_at": "2025-12-07T08:33:55.742Z",
  "updated_at": "2025-12-07T08:33:55.742Z"
}
```

### Create

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
  "id": "82634cad-7572-41c5-8f3b-763b53858da4",
  "number": "INV-001",
  "issued_on": "2024-01-15",
  "status": "draft",
  "notes": "First invoice",
  "created_at": "2025-12-07T08:33:55.751Z",
  "updated_at": "2025-12-07T08:33:55.751Z"
}
```

### Update

**Request**

```http
PATCH /funny-snake/invoices/5b456798-5fc7-4c0d-9e6f-7399c2f73689
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

### Destroy

**Request**

```http
DELETE /funny-snake/invoices/de278729-e5f6-46e1-afed-d7aa22b4e0e9
```

**Response** `200`

```json
{
  "id": "de278729-e5f6-46e1-afed-d7aa22b4e0e9",
  "number": "INV-001",
  "issued_on": null,
  "status": null,
  "notes": null,
  "created_at": "2025-12-07T08:33:55.758Z",
  "updated_at": "2025-12-07T08:33:55.758Z"
}
```

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