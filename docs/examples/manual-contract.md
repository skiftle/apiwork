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
<summary>Database Schema</summary>

<<< @/app/public/funny-snake/schema.md

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
    "id": "87ed220b-2007-4fa8-a99f-4a39ddaaa537",
    "number": "INV-001",
    "issued_on": null,
    "status": "draft",
    "notes": null,
    "created_at": "2025-12-07T11:20:16.755Z",
    "updated_at": "2025-12-07T11:20:16.755Z"
  },
  {
    "id": "d6d930f6-25e8-4680-b815-8c43baf0343e",
    "number": "INV-002",
    "issued_on": null,
    "status": "sent",
    "notes": null,
    "created_at": "2025-12-07T11:20:16.756Z",
    "updated_at": "2025-12-07T11:20:16.756Z"
  }
]
```

</details>

<details>
<summary>show</summary>

**Request**

```http
GET /funny-snake/invoices/b2081dbd-3926-46ae-b5ca-57f0961bffea
```

**Response** `200`

```json
{
  "id": "b2081dbd-3926-46ae-b5ca-57f0961bffea",
  "number": "INV-001",
  "issued_on": null,
  "status": "draft",
  "notes": null,
  "created_at": "2025-12-07T11:20:16.765Z",
  "updated_at": "2025-12-07T11:20:16.765Z"
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
  "id": "289d4a21-7f54-4ff6-8cde-df13ab1f6f9c",
  "number": "INV-001",
  "issued_on": "2024-01-15",
  "status": "draft",
  "notes": "First invoice",
  "created_at": "2025-12-07T11:20:16.777Z",
  "updated_at": "2025-12-07T11:20:16.777Z"
}
```

</details>

<details>
<summary>update</summary>

**Request**

```http
PATCH /funny-snake/invoices/c0a466ee-e0e1-4e2e-8308-19a669b65593
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
  "id": "c0a466ee-e0e1-4e2e-8308-19a669b65593",
  "created_at": "2025-12-07T11:20:16.780Z",
  "updated_at": "2025-12-07T11:20:16.786Z"
}
```

</details>

<details>
<summary>destroy</summary>

**Request**

```http
DELETE /funny-snake/invoices/bbbae838-5900-4dae-adad-ed227556b2d0
```

**Response** `200`

```json
{
  "id": "bbbae838-5900-4dae-adad-ed227556b2d0",
  "number": "INV-001",
  "issued_on": null,
  "status": null,
  "notes": null,
  "created_at": "2025-12-07T11:20:16.790Z",
  "updated_at": "2025-12-07T11:20:16.790Z"
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