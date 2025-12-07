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

<details>
<summary>index</summary>

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

</details>

<details>
<summary>show</summary>

**Request**

```http
GET /eager-lion/invoices/c9a83474-d844-4f96-883c-c8579ed5e8fb
```

**Response** `404`

```json
{
  "status": 404,
  "error": "Not Found"
}
```

</details>

<details>
<summary>create</summary>

**Request**

```http
POST /eager-lion/invoices
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "105c87ea-08a7-4fd7-9584-2ca7fe5b10b2",
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

</details>

<details>
<summary>update</summary>

**Request**

```http
PATCH /eager-lion/invoices/ad025512-360b-4ead-8984-173f2a964618
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

</details>

<details>
<summary>destroy</summary>

**Request**

```http
DELETE /eager-lion/invoices/2930cee8-562d-4776-b4fa-0e33d2a40c75
```

**Response** `404`

```json
{
  "status": 404,
  "error": "Not Found"
}
```

</details>

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