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

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| name | string |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/eager_lion/invoice.rb`</small>

<<< @/app/app/models/eager_lion/invoice.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| customer_id | string |  |  |
| issued_on | date | ✓ |  |
| notes | string | ✓ |  |
| number | string |  |  |
| status | string | ✓ |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/eager_lion/line.rb`</small>

<<< @/app/app/models/eager_lion/line.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| description | string | ✓ |  |
| invoice_id | string |  |  |
| price | decimal | ✓ |  |
| quantity | integer | ✓ |  |
| updated_at | datetime |  |  |

</details>

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
<summary>List all invoices</summary>

**Request**

```http
GET /eager_lion/invoices
```

**Response** `200`

```json
{
  "invoices": [
    {
      "id": "bdbbfc3d-255e-488c-bd3f-7a58f898ab1c",
      "createdAt": "2025-12-10T10:35:26.261Z",
      "updatedAt": "2025-12-10T10:35:26.261Z",
      "number": "INV-001",
      "issuedOn": null,
      "notes": null,
      "status": null,
      "customerId": "7314db44-dd1e-4982-889a-48f894c3996e",
      "lines": null,
      "customer": null
    },
    {
      "id": "b11adcc1-938d-441f-9a27-2da533ab59c2",
      "createdAt": "2025-12-10T10:35:26.263Z",
      "updatedAt": "2025-12-10T10:35:26.263Z",
      "number": "INV-002",
      "issuedOn": null,
      "notes": null,
      "status": null,
      "customerId": "7314db44-dd1e-4982-889a-48f894c3996e",
      "lines": null,
      "customer": null
    }
  ],
  "pagination": {
    "current": 1,
    "next": null,
    "prev": null,
    "total": 1,
    "items": 2
  }
}
```

</details>

<details>
<summary>Get invoice details</summary>

**Request**

```http
GET /eager_lion/invoices/d5cfac63-8db1-4aed-9bfe-fd2816361041
```

**Response** `200`

```json
{
  "invoice": {
    "id": "d5cfac63-8db1-4aed-9bfe-fd2816361041",
    "createdAt": "2025-12-10T10:35:26.293Z",
    "updatedAt": "2025-12-10T10:35:26.293Z",
    "number": "INV-001",
    "issuedOn": null,
    "notes": null,
    "status": null,
    "customerId": "a11bce3c-4541-4c89-8cd4-019771c5d760",
    "lines": null,
    "customer": null
  }
}
```

</details>

<details>
<summary>Create a new invoice</summary>

**Request**

```http
POST /eager_lion/invoices
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "7376025e-bfd4-4693-b6c0-bd0fb439a81b",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "4e16ccec-7ba9-4fee-94e6-55d6a2651920",
    "createdAt": "2025-12-10T10:35:26.319Z",
    "updatedAt": "2025-12-10T10:35:26.319Z",
    "number": "INV-001",
    "issuedOn": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customerId": "7376025e-bfd4-4693-b6c0-bd0fb439a81b",
    "lines": null,
    "customer": null
  }
}
```

</details>

<details>
<summary>Update an invoice</summary>

**Request**

```http
PATCH /eager_lion/invoices/5feae561-e10b-424d-943e-44dd51a229e0
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "b9062e7c-4d62-486e-a303-93d2518a7860",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "5feae561-e10b-424d-943e-44dd51a229e0",
    "createdAt": "2025-12-10T10:35:26.327Z",
    "updatedAt": "2025-12-10T10:35:26.335Z",
    "number": "INV-001",
    "issuedOn": null,
    "notes": "Updated notes",
    "status": null,
    "customerId": "b9062e7c-4d62-486e-a303-93d2518a7860",
    "lines": null,
    "customer": null
  }
}
```

</details>

<details>
<summary>Delete an invoice</summary>

**Request**

```http
DELETE /eager_lion/invoices/2900a284-1819-4180-a76b-e0a3d21b11d9
```

**Response** `204`


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