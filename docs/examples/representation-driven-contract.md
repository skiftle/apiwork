---
order: 2
---

# Representation-Driven Contract

Using `representation` to generate a complete contract from representation definitions

## API Definition

<small>`config/apis/eager_lion.rb`</small>

<<< @/playground/config/apis/eager_lion.rb

## Models

<small>`app/models/eager_lion/invoice.rb`</small>

<<< @/playground/app/models/eager_lion/invoice.rb

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

<small>`app/models/eager_lion/customer.rb`</small>

<<< @/playground/app/models/eager_lion/customer.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| name | string |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/eager_lion/line.rb`</small>

<<< @/playground/app/models/eager_lion/line.rb

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

---



## Request Examples

<details>
<summary>List all invoices</summary>

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
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "number": "INV-001",
      "issuedOn": null,
      "notes": null,
      "status": null,
      "customerId": "9428d849-05a5-5c52-a90a-906eac07ecd2",
      "lines": [],
      "customer": {
        "id": "9428d849-05a5-5c52-a90a-906eac07ecd2",
        "name": "Acme Corp"
      }
    },
    {
      "id": "beeed37c-a296-52da-9206-364418ea6f8e",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "number": "INV-002",
      "issuedOn": null,
      "notes": null,
      "status": null,
      "customerId": "9428d849-05a5-5c52-a90a-906eac07ecd2",
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

</details>

<details>
<summary>Get invoice details</summary>

**Request**

```http
GET /eager_lion/invoices/534ec78b-1e57-5f61-ae31-cd61470deb95
```

**Response** `200`

```json
{
  "invoice": {
    "id": "534ec78b-1e57-5f61-ae31-cd61470deb95",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "number": "INV-001",
    "issuedOn": null,
    "notes": null,
    "status": null,
    "customerId": "9428d849-05a5-5c52-a90a-906eac07ecd2",
    "lines": [],
    "customer": {
      "id": "9428d849-05a5-5c52-a90a-906eac07ecd2",
      "name": "Acme Corp"
    }
  }
}
```

</details>

<details>
<summary>Create a new invoice</summary>

**Request**

```http
POST /eager_lion/invoices
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "9428d849-05a5-5c52-a90a-906eac07ecd2",
    "issued_on": "2024-01-15",
    "notes": "First invoice"
  }
}
```

**Response** `201`

```json
{
  "invoice": {
    "id": "534ec78b-1e57-5f61-ae31-cd61470deb95",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "number": "INV-001",
    "issuedOn": "2024-01-15",
    "notes": "First invoice",
    "status": null,
    "customerId": "9428d849-05a5-5c52-a90a-906eac07ecd2",
    "lines": [],
    "customer": {
      "id": "9428d849-05a5-5c52-a90a-906eac07ecd2",
      "name": "Acme Corp"
    }
  }
}
```

</details>

<details>
<summary>Update an invoice</summary>

**Request**

```http
PATCH /eager_lion/invoices/534ec78b-1e57-5f61-ae31-cd61470deb95
Content-Type: application/json

{
  "invoice": {
    "number": "INV-001",
    "customer_id": "9428d849-05a5-5c52-a90a-906eac07ecd2",
    "notes": "Updated notes"
  }
}
```

**Response** `200`

```json
{
  "invoice": {
    "id": "534ec78b-1e57-5f61-ae31-cd61470deb95",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "number": "INV-001",
    "issuedOn": null,
    "notes": "Updated notes",
    "status": null,
    "customerId": "9428d849-05a5-5c52-a90a-906eac07ecd2",
    "lines": [],
    "customer": {
      "id": "9428d849-05a5-5c52-a90a-906eac07ecd2",
      "name": "Acme Corp"
    }
  }
}
```

</details>

<details>
<summary>Delete an invoice</summary>

**Request**

```http
DELETE /eager_lion/invoices/534ec78b-1e57-5f61-ae31-cd61470deb95
```

**Response** `204`


</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/eager-lion/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/eager-lion/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/eager-lion/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/eager-lion/openapi.yml

</details>