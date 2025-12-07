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
      "id": "b56d5130-94fc-4b23-abc8-8eb1b1b7f827",
      "created_at": "2025-12-07T09:41:44.776Z",
      "updated_at": "2025-12-07T09:41:44.776Z",
      "number": "INV-001",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "14b042f7-c3d5-4b77-bb4e-c952c3991162",
      "lines": [],
      "customer": {
        "id": "14b042f7-c3d5-4b77-bb4e-c952c3991162",
        "name": "Acme Corp"
      }
    },
    {
      "id": "0f0832df-75e6-4ba9-91b9-7782fe1f6a38",
      "created_at": "2025-12-07T09:41:44.779Z",
      "updated_at": "2025-12-07T09:41:44.779Z",
      "number": "INV-002",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "14b042f7-c3d5-4b77-bb4e-c952c3991162",
      "lines": [],
      "customer": {
        "id": "14b042f7-c3d5-4b77-bb4e-c952c3991162",
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
GET /eager-lion/invoices/90c59d78-c14c-45ff-9bfb-45488729fbce
```

**Response** `200`

```json
{
  "invoice": {
    "id": "90c59d78-c14c-45ff-9bfb-45488729fbce",
    "created_at": "2025-12-07T09:41:44.803Z",
    "updated_at": "2025-12-07T09:41:44.803Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": null,
    "status": null,
    "customer_id": "cefc174c-16f4-4f02-ae2f-0c544c69770d",
    "lines": [],
    "customer": {
      "id": "cefc174c-16f4-4f02-ae2f-0c544c69770d",
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
    "customer_id": "d203d92e-b891-4f57-acc0-12229c5cf826",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "2c79c16a-bcb8-4c20-882e-353577a1e24d",
    "created_at": "2025-12-07T09:41:44.817Z",
    "updated_at": "2025-12-07T09:41:44.817Z",
    "number": "INV-001",
    "issued_on": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customer_id": "d203d92e-b891-4f57-acc0-12229c5cf826",
    "lines": [],
    "customer": {
      "id": "d203d92e-b891-4f57-acc0-12229c5cf826",
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
PATCH /eager-lion/invoices/bce8ae71-71ca-412b-a585-e7af3954a3d3
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "d4b81cc6-8854-49ff-83b6-da50bf644e82",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "bce8ae71-71ca-412b-a585-e7af3954a3d3",
    "created_at": "2025-12-07T09:41:44.822Z",
    "updated_at": "2025-12-07T09:41:44.827Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": "Updated notes",
    "status": null,
    "customer_id": "d4b81cc6-8854-49ff-83b6-da50bf644e82",
    "lines": [],
    "customer": {
      "id": "d4b81cc6-8854-49ff-83b6-da50bf644e82",
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
DELETE /eager-lion/invoices/f459a058-8fb1-49f9-b007-47de5e02bcff
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