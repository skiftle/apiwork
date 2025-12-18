---
order: 2
---

# Schema-Driven Contract

Using `schema!` to generate a complete contract from schema definitions

## API Definition

<small>`config/apis/eager_lion.rb`</small>

<<< @/playground/config/apis/eager_lion.rb

## Models

<small>`app/models/eager_lion/customer.rb`</small>

<<< @/playground/app/models/eager_lion/customer.rb

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

<<< @/playground/app/models/eager_lion/invoice.rb

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

<<< @/playground/app/models/eager_lion/line.rb

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

<<< @/playground/app/schemas/eager_lion/customer_schema.rb

<small>`app/schemas/eager_lion/invoice_schema.rb`</small>

<<< @/playground/app/schemas/eager_lion/invoice_schema.rb

<small>`app/schemas/eager_lion/line_schema.rb`</small>

<<< @/playground/app/schemas/eager_lion/line_schema.rb

## Contracts

<small>`app/contracts/eager_lion/invoice_contract.rb`</small>

<<< @/playground/app/contracts/eager_lion/invoice_contract.rb

## Controllers

<small>`app/controllers/eager_lion/invoices_controller.rb`</small>

<<< @/playground/app/controllers/eager_lion/invoices_controller.rb

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
      "id": "5441fa6e-07c4-4545-8623-c5366105b0db",
      "createdAt": "2025-12-18T13:29:03.919Z",
      "updatedAt": "2025-12-18T13:29:03.919Z",
      "number": "INV-001",
      "issuedOn": null,
      "notes": null,
      "status": null,
      "customerId": "62e53928-1197-401e-ad64-82dd20138288",
      "lines": null,
      "customer": null
    },
    {
      "id": "22054fbd-f3bf-479e-a275-9f4eb78fde7b",
      "createdAt": "2025-12-18T13:29:03.920Z",
      "updatedAt": "2025-12-18T13:29:03.920Z",
      "number": "INV-002",
      "issuedOn": null,
      "notes": null,
      "status": null,
      "customerId": "62e53928-1197-401e-ad64-82dd20138288",
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
GET /eager_lion/invoices/de291757-3ee3-480d-948d-c920a42f0161
```

**Response** `200`

```json
{
  "invoice": {
    "id": "de291757-3ee3-480d-948d-c920a42f0161",
    "createdAt": "2025-12-18T13:29:03.934Z",
    "updatedAt": "2025-12-18T13:29:03.934Z",
    "number": "INV-001",
    "issuedOn": null,
    "notes": null,
    "status": null,
    "customerId": "24e970d1-c77c-4cd6-b656-54a54492724c",
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
    "customer_id": "544588cb-d5c4-4c3e-89ae-b8f919d5500e",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "6498b8f0-d20f-4b82-9fdf-25e9edef50c3",
    "createdAt": "2025-12-18T13:29:03.947Z",
    "updatedAt": "2025-12-18T13:29:03.947Z",
    "number": "INV-001",
    "issuedOn": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customerId": "544588cb-d5c4-4c3e-89ae-b8f919d5500e",
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
PATCH /eager_lion/invoices/ea9ec7bb-8244-4f50-aeb8-591f79d6a2e6
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "cc82d365-8dc2-41b0-b40d-11deddb45552",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "ea9ec7bb-8244-4f50-aeb8-591f79d6a2e6",
    "createdAt": "2025-12-18T13:29:03.951Z",
    "updatedAt": "2025-12-18T13:29:03.956Z",
    "number": "INV-001",
    "issuedOn": null,
    "notes": "Updated notes",
    "status": null,
    "customerId": "cc82d365-8dc2-41b0-b40d-11deddb45552",
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
DELETE /eager_lion/invoices/94bcea75-d181-4fd4-baf3-1067d25f5405
```

**Response** `204`


</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/eager-lion/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/eager-lion/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/eager-lion/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/eager-lion/openapi.yml

</details>