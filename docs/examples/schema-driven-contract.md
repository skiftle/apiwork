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
      "id": "7bcd5e97-e8e8-4609-b9f1-3328d28a9cd2",
      "created_at": "2025-12-07T09:01:01.150Z",
      "updated_at": "2025-12-07T09:01:01.150Z",
      "number": "INV-001",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "65ed24cd-c1ad-46f4-aee1-f8c64b9c3c2b",
      "lines": [],
      "customer": {
        "id": "65ed24cd-c1ad-46f4-aee1-f8c64b9c3c2b",
        "name": "Acme Corp"
      }
    },
    {
      "id": "03c91f2a-e0d6-4afa-8359-43bc2b62c8df",
      "created_at": "2025-12-07T09:01:01.155Z",
      "updated_at": "2025-12-07T09:01:01.155Z",
      "number": "INV-002",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "65ed24cd-c1ad-46f4-aee1-f8c64b9c3c2b",
      "lines": [],
      "customer": {
        "id": "65ed24cd-c1ad-46f4-aee1-f8c64b9c3c2b",
        "name": "Acme Corp"
      }
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
GET /eager-lion/invoices/f0bca08e-c41e-4d35-b4e2-b808ba1d2d03
```

**Response** `200`

```json
{
  "invoice": {
    "id": "f0bca08e-c41e-4d35-b4e2-b808ba1d2d03",
    "created_at": "2025-12-07T09:01:01.194Z",
    "updated_at": "2025-12-07T09:01:01.194Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": null,
    "status": null,
    "customer_id": "c8d5f9d8-26ef-45f5-b968-6e00fdd30c6b",
    "lines": [],
    "customer": {
      "id": "c8d5f9d8-26ef-45f5-b968-6e00fdd30c6b",
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
    "customer_id": "9ce3320b-b69a-41d2-bf78-2abc529addb9",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "0ff3bfd1-4b92-4045-a969-da519c8e5945",
    "created_at": "2025-12-07T09:01:01.207Z",
    "updated_at": "2025-12-07T09:01:01.207Z",
    "number": "INV-001",
    "issued_on": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customer_id": "9ce3320b-b69a-41d2-bf78-2abc529addb9",
    "lines": [],
    "customer": {
      "id": "9ce3320b-b69a-41d2-bf78-2abc529addb9",
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
PATCH /eager-lion/invoices/05c3d824-86f2-471c-abcc-5ad773a1f30a
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "45e3a037-70ae-40ed-b717-ba8175b35f84",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "05c3d824-86f2-471c-abcc-5ad773a1f30a",
    "created_at": "2025-12-07T09:01:01.213Z",
    "updated_at": "2025-12-07T09:01:01.218Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": "Updated notes",
    "status": null,
    "customer_id": "45e3a037-70ae-40ed-b717-ba8175b35f84",
    "lines": [],
    "customer": {
      "id": "45e3a037-70ae-40ed-b717-ba8175b35f84",
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
DELETE /eager-lion/invoices/210ac56f-6a00-434c-9098-17f57212b5da
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