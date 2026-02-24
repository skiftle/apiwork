---
order: 1
---

# Representations

Generate a complete contract from representation definitions

## API Definition

<small>`config/apis/eager_lion.rb`</small>

<<< @/playground/config/apis/eager_lion.rb

## Models

<small>`app/models/eager_lion/invoice.rb`</small>

<<< @/playground/app/models/eager_lion/invoice.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| customer_id | string |  |  |
| issued_on | date | ✓ |  |
| notes | string | ✓ |  |
| number | string |  |  |
| status | integer |  | 0 |
| updated_at | datetime |  |  |

:::

<small>`app/models/eager_lion/customer.rb`</small>

<<< @/playground/app/models/eager_lion/customer.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| name | string |  |  |
| updated_at | datetime |  |  |

:::

<small>`app/models/eager_lion/line.rb`</small>

<<< @/playground/app/models/eager_lion/line.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| description | string | ✓ |  |
| invoice_id | string |  |  |
| price | decimal | ✓ |  |
| quantity | integer | ✓ |  |
| updated_at | datetime |  |  |

:::

## Representations

<small>`app/representations/eager_lion/invoice_representation.rb`</small>

<<< @/playground/app/representations/eager_lion/invoice_representation.rb

<small>`app/representations/eager_lion/customer_representation.rb`</small>

<<< @/playground/app/representations/eager_lion/customer_representation.rb

<small>`app/representations/eager_lion/line_representation.rb`</small>

<<< @/playground/app/representations/eager_lion/line_representation.rb

## Contracts

<small>`app/contracts/eager_lion/invoice_contract.rb`</small>

<<< @/playground/app/contracts/eager_lion/invoice_contract.rb

## Controllers

<small>`app/controllers/eager_lion/invoices_controller.rb`</small>

<<< @/playground/app/controllers/eager_lion/invoices_controller.rb

## Request Examples

::: details List all invoices

**Request**

```http
GET /eager_lion/invoices
```

**Response** `200`

```json
{
  "invoices": [
    {
      "id": "534ec78b-1e57-5f61-ae31-cd61470deb95",
      "number": "INV-001",
      "issuedOn": null,
      "notes": null,
      "status": "sent",
      "customerId": "9428d849-05a5-5c52-a90a-906eac07ecd2",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "lines": [],
      "customer": {
        "id": "9428d849-05a5-5c52-a90a-906eac07ecd2",
        "name": "Acme Corp"
      }
    },
    {
      "id": "beeed37c-a296-52da-9206-364418ea6f8e",
      "number": "INV-002",
      "issuedOn": null,
      "notes": null,
      "status": "draft",
      "customerId": "9428d849-05a5-5c52-a90a-906eac07ecd2",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "lines": [],
      "customer": {
        "id": "9428d849-05a5-5c52-a90a-906eac07ecd2",
        "name": "Acme Corp"
      }
    }
  ],
  "pagination": {
    "items": 2,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
  }
}
```

:::

::: details Get invoice details

**Request**

```http
GET /eager_lion/invoices/534ec78b-1e57-5f61-ae31-cd61470deb95
```

**Response** `200`

```json
{
  "invoice": {
    "id": "534ec78b-1e57-5f61-ae31-cd61470deb95",
    "number": "INV-001",
    "issuedOn": null,
    "notes": null,
    "status": "sent",
    "customerId": "9428d849-05a5-5c52-a90a-906eac07ecd2",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "lines": [],
    "customer": {
      "id": "9428d849-05a5-5c52-a90a-906eac07ecd2",
      "name": "Acme Corp"
    }
  }
}
```

:::

::: details Create a new invoice

**Request**

```http
POST /eager_lion/invoices
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "status": "sent",
    "customerId": "9428d849-05a5-5c52-a90a-906eac07ecd2",
    "issuedOn": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "534ec78b-1e57-5f61-ae31-cd61470deb95",
    "number": "INV-001",
    "issuedOn": "2024-01-15",
    "notes": "First invoice",
    "status": "sent",
    "customerId": "9428d849-05a5-5c52-a90a-906eac07ecd2",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "lines": [],
    "customer": {
      "id": "9428d849-05a5-5c52-a90a-906eac07ecd2",
      "name": "Acme Corp"
    }
  }
}
```

:::

::: details Update an invoice

**Request**

```http
PATCH /eager_lion/invoices/534ec78b-1e57-5f61-ae31-cd61470deb95
Content-Type: application/json

{
  "invoice": {
    "status": "sent",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "534ec78b-1e57-5f61-ae31-cd61470deb95",
    "number": "INV-001",
    "issuedOn": null,
    "notes": "Updated notes",
    "status": "sent",
    "customerId": "9428d849-05a5-5c52-a90a-906eac07ecd2",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "lines": [],
    "customer": {
      "id": "9428d849-05a5-5c52-a90a-906eac07ecd2",
      "name": "Acme Corp"
    }
  }
}
```

:::

::: details Delete an invoice

**Request**

```http
DELETE /eager_lion/invoices/534ec78b-1e57-5f61-ae31-cd61470deb95
```

**Response** `204`


:::

## Generated Output

::: details Introspection

<<< @/playground/public/eager-lion/introspection.json

:::

::: details TypeScript

<<< @/playground/public/eager-lion/typescript.ts

:::

::: details Zod

<<< @/playground/public/eager-lion/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/eager-lion/openapi.yml

:::