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
| created_at | datetime |  |  |
| issued_on | date | ✓ |  |
| notes | string | ✓ |  |
| number | string |  |  |
| status | string | ✓ |  |
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
GET /funny_snake/invoices/631ce73f-de80-4748-8ff7-e08be4276649
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
PATCH /funny_snake/invoices/cddd7175-4923-4e30-9423-c222db2e6b78
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
DELETE /funny_snake/invoices/841de6c0-a8fb-4274-9f06-b8d5a33f128a
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