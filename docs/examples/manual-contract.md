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
GET /funny_snake/invoices/083c9e26-3cbb-454d-b1e1-0c6ff8565ffb
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
PATCH /funny_snake/invoices/3e43f225-3e8c-43fa-919e-9915de53da98
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
DELETE /funny_snake/invoices/2cdf051b-65c8-4c1c-99df-2ba6bf6f6f56
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