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
GET /funny_snake/invoices
```

**Response** `500`

```json
{
  "status": 500,
  "error": "Internal Server Error"
}
```

</details>

<details>
<summary>Get invoice details</summary>

**Request**

```http
GET /funny_snake/invoices/e4d6f1ef-5a9e-4984-952e-468b3aa66ed0
```

**Response** `500`

```json
{
  "status": 500,
  "error": "Internal Server Error"
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

**Response** `500`

```json
{
  "status": 500,
  "error": "Internal Server Error"
}
```

</details>

<details>
<summary>Update an invoice</summary>

**Request**

```http
PATCH /funny_snake/invoices/e7e7bea1-bd53-422c-bfde-698f9f2c82a1
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

**Response** `500`

```json
{
  "status": 500,
  "error": "Internal Server Error"
}
```

</details>

<details>
<summary>Delete an invoice</summary>

**Request**

```http
DELETE /funny_snake/invoices/004071f6-f9c7-4739-b695-a2d22355c421
```

**Response** `500`

```json
{
  "status": 500,
  "error": "Internal Server Error"
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