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
GET /eager-lion/invoices
```

**Response** `200`

```json
{
  "invoices": [
    {
      "id": "9ba4b5d6-2650-4702-9700-d30e1b33dc36",
      "created_at": "2025-12-07T12:02:57.863Z",
      "updated_at": "2025-12-07T12:02:57.863Z",
      "number": "INV-001",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "78484d34-7080-406a-b111-cd44e8fb64fa",
      "lines": null,
      "customer": null
    },
    {
      "id": "2dd7b493-1e33-47d2-901d-7e5ea2638f22",
      "created_at": "2025-12-07T12:02:57.864Z",
      "updated_at": "2025-12-07T12:02:57.864Z",
      "number": "INV-002",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "78484d34-7080-406a-b111-cd44e8fb64fa",
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
GET /eager-lion/invoices/21cf3685-fe60-473b-8d31-03610b8a6f70
```

**Response** `200`

```json
{
  "invoice": {
    "id": "21cf3685-fe60-473b-8d31-03610b8a6f70",
    "created_at": "2025-12-07T12:02:57.881Z",
    "updated_at": "2025-12-07T12:02:57.881Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": null,
    "status": null,
    "customer_id": "7793cbe5-b8c3-45ff-b4e0-a0755096d342",
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
POST /eager-lion/invoices
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "8d45a103-cc33-4f73-b87f-59e45a0a9189",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "f1ab30f9-0091-4413-9335-2a310f36cbfb",
    "created_at": "2025-12-07T12:02:57.893Z",
    "updated_at": "2025-12-07T12:02:57.893Z",
    "number": "INV-001",
    "issued_on": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customer_id": "8d45a103-cc33-4f73-b87f-59e45a0a9189",
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
PATCH /eager-lion/invoices/5f8c67b3-6c7b-41c1-a699-340368ae0cac
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "312e0d7a-08e0-49ad-8b26-8a675e9fa2c4",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "5f8c67b3-6c7b-41c1-a699-340368ae0cac",
    "created_at": "2025-12-07T12:02:57.897Z",
    "updated_at": "2025-12-07T12:02:57.902Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": "Updated notes",
    "status": null,
    "customer_id": "312e0d7a-08e0-49ad-8b26-8a675e9fa2c4",
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
DELETE /eager-lion/invoices/5fef362b-4792-4c09-94c0-924d44466d1e
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