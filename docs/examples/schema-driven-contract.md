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
      "id": "13d5b635-9091-4894-aec2-060c32a04e84",
      "created_at": "2025-12-07T11:45:01.300Z",
      "updated_at": "2025-12-07T11:45:01.300Z",
      "number": "INV-001",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "b1e334df-78f9-425a-9913-15d76b04b902",
      "lines": null,
      "customer": null
    },
    {
      "id": "3ea5b55d-d8a5-44f0-9535-7cfe7206d124",
      "created_at": "2025-12-07T11:45:01.302Z",
      "updated_at": "2025-12-07T11:45:01.302Z",
      "number": "INV-002",
      "issued_on": null,
      "notes": null,
      "status": null,
      "customer_id": "b1e334df-78f9-425a-9913-15d76b04b902",
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
GET /eager-lion/invoices/ff7c9121-96c6-4db0-9332-200cd3aa207a
```

**Response** `200`

```json
{
  "invoice": {
    "id": "ff7c9121-96c6-4db0-9332-200cd3aa207a",
    "created_at": "2025-12-07T11:45:01.323Z",
    "updated_at": "2025-12-07T11:45:01.323Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": null,
    "status": null,
    "customer_id": "afa0bcd7-22f2-478d-a475-3d50f263ef54",
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
    "customer_id": "b69da10a-10c5-42f4-bc21-a3568a3e033b",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "5e7b7a72-752f-463d-88da-bc308edabf14",
    "created_at": "2025-12-07T11:45:01.339Z",
    "updated_at": "2025-12-07T11:45:01.339Z",
    "number": "INV-001",
    "issued_on": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customer_id": "b69da10a-10c5-42f4-bc21-a3568a3e033b",
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
PATCH /eager-lion/invoices/c98443a4-d9d3-4e29-a08e-598610331934
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "3b12d77b-5150-4e46-9b64-d00d865d236d",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "c98443a4-d9d3-4e29-a08e-598610331934",
    "created_at": "2025-12-07T11:45:01.344Z",
    "updated_at": "2025-12-07T11:45:01.350Z",
    "number": "INV-001",
    "issued_on": null,
    "notes": "Updated notes",
    "status": null,
    "customer_id": "3b12d77b-5150-4e46-9b64-d00d865d236d",
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
DELETE /eager-lion/invoices/aab1798b-fa09-4399-8904-3d184e758fea
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