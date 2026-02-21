---
order: 1
---

# Manual Contract

Defining contracts manually without schemas

## API Definition

<small>`config/apis/funny_snake.rb`</small>

<<< @/playground/config/apis/funny_snake.rb

## Models

<small>`app/models/funny_snake/invoice.rb`</small>

<<< @/playground/app/models/funny_snake/invoice.rb

<details>
<summary>Database Table</summary>

| Column     | Type     | Nullable | Default |
| ---------- | -------- | -------- | ------- |
| id         | string   |          |         |
| created_at | datetime |          |         |
| issued_on  | date     | ✓        |         |
| notes      | string   | ✓        |         |
| number     | string   |          |         |
| status     | string   | ✓        |         |
| updated_at | datetime |          |         |

</details>

## Contracts

<small>`app/contracts/funny_snake/invoice_contract.rb`</small>

<<< @/playground/app/contracts/funny_snake/invoice_contract.rb

## Controllers

<small>`app/controllers/funny_snake/invoices_controller.rb`</small>

<<< @/playground/app/controllers/funny_snake/invoices_controller.rb

---

## Request Examples

<details>
<summary>List all invoices</summary>

**Request**

```http
GET /funny_snake/invoices
```

**Response** `200`

```json
{
  "invoices": [
    {
      "id": "657000e8-1cd9-5b78-9ca2-dd399ce78cb4",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "issuedOn": null,
      "notes": null,
      "number": "INV-001",
      "status": "draft",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "a791666c-73b8-5dd1-b737-31ca691383ca",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "issuedOn": null,
      "notes": null,
      "number": "INV-002",
      "status": "sent",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ]
}
```

</details>

<details>
<summary>Get invoice details</summary>

**Request**

```http
GET /funny_snake/invoices/657000e8-1cd9-5b78-9ca2-dd399ce78cb4
```

**Response** `200`

```json
{
  "invoice": {
    "id": "657000e8-1cd9-5b78-9ca2-dd399ce78cb4",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "issuedOn": null,
    "notes": null,
    "number": "INV-001",
    "status": "draft",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

</details>

<details>
<summary>Create a new invoice</summary>

**Request**

```http
POST /funny_snake/invoices
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
  "invoice": {
    "id": "657000e8-1cd9-5b78-9ca2-dd399ce78cb4",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "issuedOn": "2024-01-15",
    "notes": "First invoice",
    "number": "INV-001",
    "status": "draft",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

</details>

<details>
<summary>Update an invoice</summary>

**Request**

```http
PATCH /funny_snake/invoices/657000e8-1cd9-5b78-9ca2-dd399ce78cb4
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
  "invoice": {
    "number": "INV-001",
    "issuedOn": "2024-01-15",
    "status": "sent",
    "notes": "Updated invoice",
    "id": "657000e8-1cd9-5b78-9ca2-dd399ce78cb4",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

</details>

<details>
<summary>Delete an invoice</summary>

**Request**

```http
DELETE /funny_snake/invoices/657000e8-1cd9-5b78-9ca2-dd399ce78cb4
```

**Response** `204`

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/funny-snake/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/funny-snake/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/funny-snake/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/funny-snake/openapi.yml

</details>
