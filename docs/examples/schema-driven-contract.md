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
  "invoices": [
    {
      "id": "73bbbb66-ca6e-483c-a46e-4c5ea248b683",
      "created_at": "2025-12-07T09:46:47.179Z",
      "updated_at": "2025-12-07T09:46:47.179Z",
      "number": "INV-001",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "26b7f035-2e74-4882-80dd-7882be11b77c",
      "lines": null,
      "customer": null
    },
    {
      "id": "5c6e322d-7424-4b09-a1d3-b68db95fc460",
      "created_at": "2025-12-07T09:46:47.181Z",
      "updated_at": "2025-12-07T09:46:47.181Z",
      "number": "INV-002",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "26b7f035-2e74-4882-80dd-7882be11b77c",
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
<summary>show</summary>

**Request**

```http
GET /eager-lion/invoices/7cd03c29-f9de-4721-aab8-fb6fdcfca5ce
```

**Response** `200`

```json
{
  "invoice": {
    "id": "7cd03c29-f9de-4721-aab8-fb6fdcfca5ce",
    "created_at": "2025-12-07T09:46:47.192Z",
    "updated_at": "2025-12-07T09:46:47.192Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": null,
    "status": null,
    "customer_id": "3ba89ab3-c4e6-4700-80a5-7f33cd5e43fd",
    "lines": null,
    "customer": null
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
    "customer_id": "efad12fb-dc9d-42fa-871b-3af0bd0ef507",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "35cf1536-2b93-48f4-a6fc-95220cd39720",
    "created_at": "2025-12-07T09:46:47.205Z",
    "updated_at": "2025-12-07T09:46:47.205Z",
    "number": "INV-001",
    "issued_on": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customer_id": "efad12fb-dc9d-42fa-871b-3af0bd0ef507",
    "lines": null,
    "customer": null
  }
}
```

</details>

<details>
<summary>update</summary>

**Request**

```http
PATCH /eager-lion/invoices/a2bf6ac1-0a92-49d6-86bf-abcb4bb1c0ae
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "15eb43c7-10e3-4dbe-bea6-7ef7e243a05d",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "a2bf6ac1-0a92-49d6-86bf-abcb4bb1c0ae",
    "created_at": "2025-12-07T09:46:47.209Z",
    "updated_at": "2025-12-07T09:46:47.214Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": "Updated notes",
    "status": null,
    "customer_id": "15eb43c7-10e3-4dbe-bea6-7ef7e243a05d",
    "lines": null,
    "customer": null
  }
}
```

</details>

<details>
<summary>destroy</summary>

**Request**

```http
DELETE /eager-lion/invoices/38f64c88-aa59-4ac1-b696-3f9221960eea
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