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
    "id": "36768912-22f4-41cf-ace5-46b71162f9a9",
    "number": "INV-001",
    "issued_on": null,
    "status": "draft",
    "notes": null,
    "created_at": "2025-12-07T13:14:57.095Z",
    "updated_at": "2025-12-07T13:14:57.095Z"
  },
  {
    "id": "dd018003-c51e-4afc-a8d0-1f6f0df6394e",
    "number": "INV-002",
    "issued_on": null,
    "status": "sent",
    "notes": null,
    "created_at": "2025-12-07T13:14:57.097Z",
    "updated_at": "2025-12-07T13:14:57.097Z"
  }
]
```

</details>

<details>
<summary>Get invoice details</summary>

**Request**

```http
GET /funny-snake/invoices/a5834d6e-ec84-45a0-b9c8-ab35c1960bf7
```

**Response** `200`

```json
{
  "id": "a5834d6e-ec84-45a0-b9c8-ab35c1960bf7",
  "number": "INV-001",
  "issued_on": null,
  "status": "draft",
  "notes": null,
  "created_at": "2025-12-07T13:14:57.112Z",
  "updated_at": "2025-12-07T13:14:57.112Z"
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
  "id": "cc85ef44-e733-44f5-9154-df21793fba29",
  "number": "INV-001",
  "issued_on": "2024-01-15",
  "status": "draft",
  "notes": "First invoice",
  "created_at": "2025-12-07T13:14:57.134Z",
  "updated_at": "2025-12-07T13:14:57.134Z"
}
```

</details>

<details>
<summary>Update an invoice</summary>

**Request**

```http
PATCH /funny-snake/invoices/cfc7c475-ec3e-42c1-a97d-fe66d1d8a011
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
  "id": "cfc7c475-ec3e-42c1-a97d-fe66d1d8a011",
  "created_at": "2025-12-07T13:14:57.139Z",
  "updated_at": "2025-12-07T13:14:57.146Z"
}
```

</details>

<details>
<summary>Delete an invoice</summary>

**Request**

```http
DELETE /funny-snake/invoices/8a21d5c9-319a-4e23-a501-a21666b0bfa6
```

**Response** `200`

```json
{
  "id": "8a21d5c9-319a-4e23-a501-a21666b0bfa6",
  "number": "INV-001",
  "issued_on": null,
  "status": null,
  "notes": null,
  "created_at": "2025-12-07T13:14:57.149Z",
  "updated_at": "2025-12-07T13:14:57.149Z"
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