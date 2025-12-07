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
      "id": "266eac80-1088-4dfb-b417-b6488bad1c4a",
      "created_at": "2025-12-07T10:25:48.886Z",
      "updated_at": "2025-12-07T10:25:48.886Z",
      "number": "INV-001",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "df7391c1-81d5-42d5-bc95-0f425978655b",
      "lines": null,
      "customer": null
    },
    {
      "id": "583c8c62-179c-4921-a5f1-1b5012b9b462",
      "created_at": "2025-12-07T10:25:48.887Z",
      "updated_at": "2025-12-07T10:25:48.887Z",
      "number": "INV-002",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "df7391c1-81d5-42d5-bc95-0f425978655b",
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
GET /eager-lion/invoices/e185da7a-4fc3-4e3b-a223-5ed903b2a145
```

**Response** `200`

```json
{
  "invoice": {
    "id": "e185da7a-4fc3-4e3b-a223-5ed903b2a145",
    "created_at": "2025-12-07T10:25:48.899Z",
    "updated_at": "2025-12-07T10:25:48.899Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": null,
    "status": null,
    "customer_id": "43079114-fd70-4f1f-8f18-e8e827817f2d",
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
    "customer_id": "4d555364-395e-45a8-901a-c0c64eba5b80",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "bbc5e59c-966f-4b23-895a-3629fc2f7dd3",
    "created_at": "2025-12-07T10:25:48.912Z",
    "updated_at": "2025-12-07T10:25:48.912Z",
    "number": "INV-001",
    "issued_on": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customer_id": "4d555364-395e-45a8-901a-c0c64eba5b80",
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
PATCH /eager-lion/invoices/c4e5be51-fa7c-4a20-9471-2f6d2b397a78
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "0b275700-fd7d-492a-b5d0-a54144f0a17d",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "c4e5be51-fa7c-4a20-9471-2f6d2b397a78",
    "created_at": "2025-12-07T10:25:48.916Z",
    "updated_at": "2025-12-07T10:25:48.921Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": "Updated notes",
    "status": null,
    "customer_id": "0b275700-fd7d-492a-b5d0-a54144f0a17d",
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
DELETE /eager-lion/invoices/c2da1b45-2c54-44ad-a5ed-13eccaa150d0
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