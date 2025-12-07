---
order: 1
---

# Manual Contract

Defining contracts manually without schemas

## API Definition

<small>`config/apis/funny_snake.rb`</small>

<<< @/app/config/apis/funny_snake.rb

## Models

<small>`app/models/funny_snake/invoice.rb`</small>

<<< @/app/app/models/funny_snake/invoice.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| number | string |  |  |
| issued_on | date | ✓ |  |
| status | string | ✓ |  |
| notes | string | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

## Contracts

<small>`app/contracts/funny_snake/invoice_contract.rb`</small>

<<< @/app/app/contracts/funny_snake/invoice_contract.rb

## Controllers

<small>`app/controllers/funny_snake/invoices_controller.rb`</small>

<<< @/app/app/controllers/funny_snake/invoices_controller.rb

---



## Request Examples

<details>
<summary>List all invoices</summary>

**Request**

```http
GET /funny-snake/invoices
```

**Response** `200`

```json
[
  {
    "id": "300c2bd3-5292-4d66-98cf-8a0769472ff4",
    "number": "INV-001",
    "issued_on": null,
    "status": "draft",
    "notes": null,
    "created_at": "2025-12-07T12:02:57.932Z",
    "updated_at": "2025-12-07T12:02:57.932Z"
  },
  {
    "id": "87b486a5-73a0-4fed-ab87-43394fed1c88",
    "number": "INV-002",
    "issued_on": null,
    "status": "sent",
    "notes": null,
    "created_at": "2025-12-07T12:02:57.933Z",
    "updated_at": "2025-12-07T12:02:57.933Z"
  }
]
```

</details>

<details>
<summary>Get invoice details</summary>

**Request**

```http
GET /funny-snake/invoices/9a859b3b-b86b-497a-952c-b19ac04979dc
```

**Response** `200`

```json
{
  "id": "9a859b3b-b86b-497a-952c-b19ac04979dc",
  "number": "INV-001",
  "issued_on": null,
  "status": "draft",
  "notes": null,
  "created_at": "2025-12-07T12:02:57.941Z",
  "updated_at": "2025-12-07T12:02:57.941Z"
}
```

</details>

<details>
<summary>Create a new invoice</summary>

**Request**

```http
POST /funny-snake/invoices
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "issued_on": "2024-01-15",
    "status": "draft",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "id": "4d57f95d-edd6-48df-825b-23e8897604c6",
  "number": "INV-001",
  "issued_on": "2024-01-15",
  "status": "draft",
  "notes": "First invoice",
  "created_at": "2025-12-07T12:02:57.953Z",
  "updated_at": "2025-12-07T12:02:57.953Z"
}
```

</details>

<details>
<summary>Update an invoice</summary>

**Request**

```http
PATCH /funny-snake/invoices/2b4805aa-4fe9-45d0-9928-1c1e4061b668
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "issued_on": "2024-01-15",
    "status": "sent",
    "notes": "Updated invoice"
  }
}
```

**Response** `200`

```json
{
  "number": "INV-001",
  "issued_on": "2024-01-15",
  "status": "sent",
  "notes": "Updated invoice",
  "id": "2b4805aa-4fe9-45d0-9928-1c1e4061b668",
  "created_at": "2025-12-07T12:02:57.956Z",
  "updated_at": "2025-12-07T12:02:57.961Z"
}
```

</details>

<details>
<summary>Delete an invoice</summary>

**Request**

```http
DELETE /funny-snake/invoices/3e21bad0-14e3-465f-afb7-7b63d963f1e4
```

**Response** `200`

```json
{
  "id": "3e21bad0-14e3-465f-afb7-7b63d963f1e4",
  "number": "INV-001",
  "issued_on": null,
  "status": null,
  "notes": null,
  "created_at": "2025-12-07T12:02:57.963Z",
  "updated_at": "2025-12-07T12:02:57.963Z"
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/app/public/funny-snake/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/funny-snake/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/funny-snake/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/funny-snake/openapi.yml

</details>