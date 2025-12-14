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
GET /funny_snake/invoices/df96d5b6-65f3-406e-ba24-d047c0711604
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
PATCH /funny_snake/invoices/f0373ec9-fd3c-41fe-971e-ea2ad76dc4ba
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
DELETE /funny_snake/invoices/10942eed-24b6-4bb0-aca7-7f4fb726ecc8
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