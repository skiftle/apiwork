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
      "id": "b9c4d27b-9c54-46ad-9516-0b579b2ee163",
      "created_at": "2025-12-07T10:13:37.392Z",
      "updated_at": "2025-12-07T10:13:37.392Z",
      "number": "INV-001",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "fd5fbeb4-69b3-4faf-9dd8-20b1fbdb01ef",
      "lines": null,
      "customer": null
    },
    {
      "id": "541ab472-3912-447b-af5e-ca13ae9ebdda",
      "created_at": "2025-12-07T10:13:37.394Z",
      "updated_at": "2025-12-07T10:13:37.394Z",
      "number": "INV-002",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "fd5fbeb4-69b3-4faf-9dd8-20b1fbdb01ef",
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
GET /eager-lion/invoices/5dde196d-a8f2-41cc-a4e1-5cec0fa26662
```

**Response** `200`

```json
{
  "invoice": {
    "id": "5dde196d-a8f2-41cc-a4e1-5cec0fa26662",
    "created_at": "2025-12-07T10:13:37.405Z",
    "updated_at": "2025-12-07T10:13:37.405Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": null,
    "status": null,
    "customer_id": "5ef66983-08f5-40ff-8360-2578610ffda8",
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
    "customer_id": "9a7c6bdb-7670-4763-90fc-41f31cc8a164",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "d7f8f694-9ad6-4884-9b0e-e92e53084c35",
    "created_at": "2025-12-07T10:13:37.423Z",
    "updated_at": "2025-12-07T10:13:37.423Z",
    "number": "INV-001",
    "issued_on": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customer_id": "9a7c6bdb-7670-4763-90fc-41f31cc8a164",
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
PATCH /eager-lion/invoices/91f711ab-4835-493e-9781-2dbf1b8fb502
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "c8c38fa6-2350-4322-b5d5-33534a1eaffc",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "91f711ab-4835-493e-9781-2dbf1b8fb502",
    "created_at": "2025-12-07T10:13:37.427Z",
    "updated_at": "2025-12-07T10:13:37.432Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": "Updated notes",
    "status": null,
    "customer_id": "c8c38fa6-2350-4322-b5d5-33534a1eaffc",
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
DELETE /eager-lion/invoices/cc325f36-c767-4595-91e1-4bc1356a1790
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