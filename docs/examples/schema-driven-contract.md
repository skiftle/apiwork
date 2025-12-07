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

<details>
<summary>Database Schema</summary>

<<< @/app/public/eager-lion/schema.md

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
      "id": "b7227c0b-bb52-4ec1-8297-88f5cd7a97fe",
      "created_at": "2025-12-07T11:20:16.682Z",
      "updated_at": "2025-12-07T11:20:16.682Z",
      "number": "INV-001",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "542d63f4-c059-4a8e-958e-280c441bc2a9",
      "lines": null,
      "customer": null
    },
    {
      "id": "a15946a9-f750-46ac-b215-1353b829366f",
      "created_at": "2025-12-07T11:20:16.684Z",
      "updated_at": "2025-12-07T11:20:16.684Z",
      "number": "INV-002",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "542d63f4-c059-4a8e-958e-280c441bc2a9",
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
GET /eager-lion/invoices/def2baaa-3063-4388-8173-33c1aa9c62b6
```

**Response** `200`

```json
{
  "invoice": {
    "id": "def2baaa-3063-4388-8173-33c1aa9c62b6",
    "created_at": "2025-12-07T11:20:16.696Z",
    "updated_at": "2025-12-07T11:20:16.696Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": null,
    "status": null,
    "customer_id": "a0f265e2-f75f-4f94-aff2-2f8d9c7951e9",
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
    "customer_id": "87374ed3-8691-4034-afa1-7eb7471dd9ba",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "94d844b7-d219-4869-bd67-6ef48b76b5ac",
    "created_at": "2025-12-07T11:20:16.718Z",
    "updated_at": "2025-12-07T11:20:16.718Z",
    "number": "INV-001",
    "issued_on": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customer_id": "87374ed3-8691-4034-afa1-7eb7471dd9ba",
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
PATCH /eager-lion/invoices/15c24d45-ff89-49c9-8928-ff847fa69038
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "ddae5ba5-7cfd-40bc-ad0e-07b4d0d8cb99",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "15c24d45-ff89-49c9-8928-ff847fa69038",
    "created_at": "2025-12-07T11:20:16.722Z",
    "updated_at": "2025-12-07T11:20:16.727Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": "Updated notes",
    "status": null,
    "customer_id": "ddae5ba5-7cfd-40bc-ad0e-07b4d0d8cb99",
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
DELETE /eager-lion/invoices/c32f28ce-b796-4932-a321-a5bc7809e2d5
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