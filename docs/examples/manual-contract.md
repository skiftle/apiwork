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
    "id": "9ce5ab49-14eb-4a37-8459-76faba2de753",
    "number": "INV-001",
    "issued_on": null,
    "status": "draft",
    "notes": null,
    "created_at": "2025-12-07T09:41:44.855Z",
    "updated_at": "2025-12-07T09:41:44.855Z"
  },
  {
    "id": "2e6b9b30-6ad0-40fd-a4c3-c1547f3b6d76",
    "number": "INV-002",
    "issued_on": null,
    "status": "sent",
    "notes": null,
    "created_at": "2025-12-07T09:41:44.856Z",
    "updated_at": "2025-12-07T09:41:44.856Z"
  }
]
```

</details>

<details>
<summary>show</summary>

**Request**

```http
GET /funny-snake/invoices/fa52713b-0c02-464e-b004-80691cda9124
```

**Response** `200`

```json
{
  "id": "fa52713b-0c02-464e-b004-80691cda9124",
  "number": "INV-001",
  "issued_on": null,
  "status": "draft",
  "notes": null,
  "created_at": "2025-12-07T09:41:44.864Z",
  "updated_at": "2025-12-07T09:41:44.864Z"
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
  "id": "c87a488a-8fcf-402c-b6cc-caa20e01d513",
  "number": "INV-001",
  "issued_on": "2024-01-15",
  "status": "draft",
  "notes": "First invoice",
  "created_at": "2025-12-07T09:41:44.880Z",
  "updated_at": "2025-12-07T09:41:44.880Z"
}
```

</details>

<details>
<summary>update</summary>

**Request**

```http
PATCH /funny-snake/invoices/63b92e33-2f83-4337-9cb3-f0192d105b1c
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
  "id": "63b92e33-2f83-4337-9cb3-f0192d105b1c",
  "created_at": "2025-12-07T09:41:44.883Z",
  "updated_at": "2025-12-07T09:41:44.888Z"
}
```

</details>

<details>
<summary>destroy</summary>

**Request**

```http
DELETE /funny-snake/invoices/01e201ff-b763-491f-ad09-299ddee27c34
```

**Response** `200`

```json
{
  "id": "01e201ff-b763-491f-ad09-299ddee27c34",
  "number": "INV-001",
  "issued_on": null,
  "status": null,
  "notes": null,
  "created_at": "2025-12-07T09:41:44.891Z",
  "updated_at": "2025-12-07T09:41:44.891Z"
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