---
order: 2
---

# Schema-Driven Contract

Using `schema!` to generate a complete contract from schema definitions

## API Definition

<small>`config/apis/eager_lion.rb`</small>

<<< @/app/config/apis/eager_lion.rb

## Models

<small>`app/models/eager_lion/customer.rb`</small>

<<< @/app/app/models/eager_lion/customer.rb

<small>`app/models/eager_lion/invoice.rb`</small>

<<< @/app/app/models/eager_lion/invoice.rb

<small>`app/models/eager_lion/line.rb`</small>

<<< @/app/app/models/eager_lion/line.rb

## Schemas

<small>`app/schemas/eager_lion/customer_schema.rb`</small>

<<< @/app/app/schemas/eager_lion/customer_schema.rb

<small>`app/schemas/eager_lion/invoice_schema.rb`</small>

<<< @/app/app/schemas/eager_lion/invoice_schema.rb

<small>`app/schemas/eager_lion/line_schema.rb`</small>

<<< @/app/app/schemas/eager_lion/line_schema.rb

## Contracts

<small>`app/contracts/eager_lion/invoice_contract.rb`</small>

<<< @/app/app/contracts/eager_lion/invoice_contract.rb

## Controllers

<small>`app/controllers/eager_lion/invoices_controller.rb`</small>

<<< @/app/app/controllers/eager_lion/invoices_controller.rb

---



## Request Examples

### Index

**Request**

```http
GET /eager-lion/invoices
```

**Response** `200`

```json
{
  "invoices": [],
  "pagination": {
    "current": 1,
    "next": null,
    "prev": null,
    "total": 0,
    "items": 0
  }
}
```

### Show

**Request**

```http
GET /eager-lion/invoices/ae85bb91-4941-4e17-8a0e-a5b8be16719c
```

**Response** `404`

```json
{
  "status": 404,
  "error": "Not Found"
}
```

### Create

**Request**

```http
POST /eager-lion/invoices
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "d82240ab-b47b-4e14-9e1f-b346666aa115",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `400`

```json
{
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "path": [
        "invoice",
        "customer_id"
      ],
      "pointer": "/invoice/customer_id",
      "meta": {
        "field": "customer_id",
        "allowed": [
          "number",
          "issued_on",
          "notes",
          "lines"
        ]
      }
    }
  ]
}
```

### Update

**Request**

```http
PATCH /eager-lion/invoices/ac4cbb4d-24c4-466d-a0e6-5722d186bdd0
Content-Type: application/json

{
  "invoice": {
    "notes": "Updated notes"
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
    }
  ]
}
```

### Destroy

**Request**

```http
DELETE /eager-lion/invoices/6377b713-4c6b-4b31-a7d1-9e3250e05512
```

**Response** `404`

```json
{
  "status": 404,
  "error": "Not Found"
}
```

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/app/public/eager-lion/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/eager-lion/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/eager-lion/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/eager-lion/openapi.yml

</details>