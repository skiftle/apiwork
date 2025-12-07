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
<summary>index</summary>

**Request**

```http
GET /funny-snake/invoices
```

**Response** `200`

```json
[
  {
    "id": "02dc1f29-b681-42e3-99a9-f72ad1399ed9",
    "number": "INV-001",
    "issued_on": null,
    "status": "draft",
    "notes": null,
    "created_at": "2025-12-07T11:45:01.386Z",
    "updated_at": "2025-12-07T11:45:01.386Z"
  },
  {
    "id": "3ab4e240-ac10-4067-b99b-8ec9fbc492d0",
    "number": "INV-002",
    "issued_on": null,
    "status": "sent",
    "notes": null,
    "created_at": "2025-12-07T11:45:01.387Z",
    "updated_at": "2025-12-07T11:45:01.387Z"
  }
]
```

</details>

<details>
<summary>show</summary>

**Request**

```http
GET /funny-snake/invoices/e75bcaa8-327c-4a93-bffc-503dd2691804
```

**Response** `200`

```json
{
  "id": "e75bcaa8-327c-4a93-bffc-503dd2691804",
  "number": "INV-001",
  "issued_on": null,
  "status": "draft",
  "notes": null,
  "created_at": "2025-12-07T11:45:01.398Z",
  "updated_at": "2025-12-07T11:45:01.398Z"
}
```

</details>

<details>
<summary>create</summary>

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
  "id": "68eda74d-3ba4-4aa9-823a-b0bc42616cec",
  "number": "INV-001",
  "issued_on": "2024-01-15",
  "status": "draft",
  "notes": "First invoice",
  "created_at": "2025-12-07T11:45:01.408Z",
  "updated_at": "2025-12-07T11:45:01.408Z"
}
```

</details>

<details>
<summary>update</summary>

**Request**

```http
PATCH /funny-snake/invoices/784051b2-4230-4a5e-a2bc-d6594a66ea60
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
  "id": "784051b2-4230-4a5e-a2bc-d6594a66ea60",
  "created_at": "2025-12-07T11:45:01.411Z",
  "updated_at": "2025-12-07T11:45:01.416Z"
}
```

</details>

<details>
<summary>destroy</summary>

**Request**

```http
DELETE /funny-snake/invoices/dede6ab1-dcdc-4738-85c7-874ce49bbbb6
```

**Response** `200`

```json
{
  "id": "dede6ab1-dcdc-4738-85c7-874ce49bbbb6",
  "number": "INV-001",
  "issued_on": null,
  "status": null,
  "notes": null,
  "created_at": "2025-12-07T11:45:01.419Z",
  "updated_at": "2025-12-07T11:45:01.419Z"
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