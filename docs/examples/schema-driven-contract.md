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
GET /eager-lion/invoices/de72cbf8-e871-4557-9f2e-a33d5ec999c2
```

**Response** `200`

```json
{
  "invoice": {
    "id": "de72cbf8-e871-4557-9f2e-a33d5ec999c2",
    "created_at": "2025-12-07T08:54:44.116Z",
    "updated_at": "2025-12-07T08:54:44.116Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": null,
    "status": null,
    "customer_id": "f1ba24f7-80e5-4d03-adef-aa66bbedd3d9",
    "lines": [],
    "customer": {
      "id": "f1ba24f7-80e5-4d03-adef-aa66bbedd3d9",
      "name": "Acme Corp"
    }
  }
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
    "customer_id": "9826e08c-a629-4da2-a452-6ae029bbc63f",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "20b21ca3-4163-4130-9c05-ff169556c887",
    "created_at": "2025-12-07T08:54:44.157Z",
    "updated_at": "2025-12-07T08:54:44.157Z",
    "number": "INV-001",
    "issued_on": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customer_id": "9826e08c-a629-4da2-a452-6ae029bbc63f",
    "lines": [],
    "customer": {
      "id": "9826e08c-a629-4da2-a452-6ae029bbc63f",
      "name": "Acme Corp"
    }
  }
}
```

</details>

<details>
<summary>update</summary>

**Request**

```http
PATCH /eager-lion/invoices/1ff27a9d-7be8-4adc-9af9-0a945a6a0581
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "e31b4125-bfc2-4ed5-8056-766e24b550c2",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "1ff27a9d-7be8-4adc-9af9-0a945a6a0581",
    "created_at": "2025-12-07T08:54:44.174Z",
    "updated_at": "2025-12-07T08:54:44.182Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": "Updated notes",
    "status": null,
    "customer_id": "e31b4125-bfc2-4ed5-8056-766e24b550c2",
    "lines": [],
    "customer": {
      "id": "e31b4125-bfc2-4ed5-8056-766e24b550c2",
      "name": "Acme Corp"
    }
  }
}
```

</details>

<details>
<summary>destroy</summary>

**Request**

```http
DELETE /eager-lion/invoices/539c7ace-cde4-466b-b043-a7dcc1b7aa6f
```

**Response** `200`

```json
{
  "meta": {}
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