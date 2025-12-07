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
      "id": "ad2114a8-6f56-48fd-8ae0-0a880de88786",
      "createdAt": "2025-12-07T15:57:32.826Z",
      "updatedAt": "2025-12-07T15:57:32.826Z",
      "number": "INV-001",
      "issuedOn": null,
      "notes": null,
      "status": null,
      "customerId": "51febb35-f6fa-4d83-a112-4d69d8f49613",
      "lines": null,
      "customer": null
    },
    {
      "id": "f2ce741f-162d-4eff-9181-cf9f7c0383a9",
      "createdAt": "2025-12-07T15:57:32.832Z",
      "updatedAt": "2025-12-07T15:57:32.832Z",
      "number": "INV-002",
      "issuedOn": null,
      "notes": null,
      "status": null,
      "customerId": "51febb35-f6fa-4d83-a112-4d69d8f49613",
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
GET /eager_lion/invoices/78af402e-3248-40d3-be03-c3e9efd2d270
```

**Response** `200`

```json
{
  "invoice": {
    "id": "78af402e-3248-40d3-be03-c3e9efd2d270",
    "createdAt": "2025-12-07T15:57:32.863Z",
    "updatedAt": "2025-12-07T15:57:32.863Z",
    "number": "INV-001",
    "issuedOn": null,
    "notes": null,
    "status": null,
    "customerId": "af00615a-9c2b-4cfe-8f55-02fad1907a1e",
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
    "customer_id": "f31866b6-ba90-47f7-be62-8b861a7c3ea7",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "9b7adc17-a01b-43c5-9e75-0c8b1267a688",
    "createdAt": "2025-12-07T15:57:32.891Z",
    "updatedAt": "2025-12-07T15:57:32.891Z",
    "number": "INV-001",
    "issuedOn": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customerId": "f31866b6-ba90-47f7-be62-8b861a7c3ea7",
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
PATCH /eager_lion/invoices/4c1f811b-c906-426d-a62c-b673b75e9bec
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "1e0db926-62f8-4e04-84d3-2a5fc125f164",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "4c1f811b-c906-426d-a62c-b673b75e9bec",
    "createdAt": "2025-12-07T15:57:32.900Z",
    "updatedAt": "2025-12-07T15:57:32.911Z",
    "number": "INV-001",
    "issuedOn": null,
    "notes": "Updated notes",
    "status": null,
    "customerId": "1e0db926-62f8-4e04-84d3-2a5fc125f164",
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
DELETE /eager_lion/invoices/852c1ff7-9628-469a-b463-93af8d8c425b
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