---
order: 2
---

# Manual Contracts

Define contracts manually without representations

## API Definition

<small>`config/apis/funny_snake.rb`</small>

<<< @/playground/config/apis/funny_snake.rb

## Models

<small>`app/models/funny_snake/invoice.rb`</small>

<<< @/playground/app/models/funny_snake/invoice.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| issued_on | date | ✓ |  |
| notes | string | ✓ |  |
| number | string |  |  |
| status | integer |  | 0 |
| updated_at | datetime |  |  |

:::

## Contracts

<small>`app/contracts/funny_snake/invoice_contract.rb`</small>

<<< @/playground/app/contracts/funny_snake/invoice_contract.rb

## Controllers

<small>`app/controllers/funny_snake/invoices_controller.rb`</small>

<<< @/playground/app/controllers/funny_snake/invoices_controller.rb

## Request Examples

::: details List all invoices

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

:::

::: details Get invoice details

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

:::

::: details Create a new invoice

**Request**

```http
POST /funny_snake/invoices
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "issuedOn": "2024-01-15",
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

:::

::: details Update an invoice

**Request**

```http
PATCH /funny_snake/invoices/657000e8-1cd9-5b78-9ca2-dd399ce78cb4
Content-Type: application/json

{
  "invoice": {
    "status": "sent",
    "notes": "Updated invoice"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "status": "sent",
    "notes": "Updated invoice",
    "id": "657000e8-1cd9-5b78-9ca2-dd399ce78cb4",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "issuedOn": null,
    "number": "INV-001",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

::: details Delete an invoice

**Request**

```http
DELETE /funny_snake/invoices/657000e8-1cd9-5b78-9ca2-dd399ce78cb4
```

**Response** `204`


:::

## Generated Output

::: details Introspection

<<< @/playground/public/funny-snake/introspection.json

:::

::: details TypeScript

<<< @/playground/public/funny-snake/typescript.ts

:::

::: details Zod

<<< @/playground/public/funny-snake/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/funny-snake/openapi.yml

:::