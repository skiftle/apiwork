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
    "id": "366f65a5-daec-43ec-8406-b5a902fd6a67",
    "number": "INV-001",
    "issued_on": null,
    "status": "draft",
    "notes": null,
    "created_at": "2025-12-07T09:01:01.247Z",
    "updated_at": "2025-12-07T09:01:01.247Z"
  },
  {
    "id": "521f2706-9ac9-4c66-a353-01ed0aadb989",
    "number": "INV-002",
    "issued_on": null,
    "status": "sent",
    "notes": null,
    "created_at": "2025-12-07T09:01:01.248Z",
    "updated_at": "2025-12-07T09:01:01.248Z"
  }
]
```

</details>

<details>
<summary>show</summary>

**Request**

```http
GET /funny-snake/invoices/5cc17506-1e42-48c6-9f07-81df73f4cf80
```

**Response** `200`

```json
{
  "id": "5cc17506-1e42-48c6-9f07-81df73f4cf80",
  "number": "INV-001",
  "issued_on": null,
  "status": "draft",
  "notes": null,
  "created_at": "2025-12-07T09:01:01.255Z",
  "updated_at": "2025-12-07T09:01:01.255Z"
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
  "id": "ede6a965-80ec-4767-9fb7-89c08a341592",
  "number": "INV-001",
  "issued_on": "2024-01-15",
  "status": "draft",
  "notes": "First invoice",
  "created_at": "2025-12-07T09:01:01.264Z",
  "updated_at": "2025-12-07T09:01:01.264Z"
}
```

</details>

<details>
<summary>update</summary>

**Request**

```http
PATCH /funny-snake/invoices/6455ac4a-5b15-4979-939f-e716ebcd7785
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
  "id": "6455ac4a-5b15-4979-939f-e716ebcd7785",
  "created_at": "2025-12-07T09:01:01.267Z",
  "updated_at": "2025-12-07T09:01:01.272Z"
}
```

</details>

<details>
<summary>destroy</summary>

**Request**

```http
DELETE /funny-snake/invoices/ccc71d95-418e-48ae-903e-0442bacbab50
```

**Response** `200`

```json
{
  "id": "ccc71d95-418e-48ae-903e-0442bacbab50",
  "number": "INV-001",
  "issued_on": null,
  "status": null,
  "notes": null,
  "created_at": "2025-12-07T09:01:01.274Z",
  "updated_at": "2025-12-07T09:01:01.274Z"
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