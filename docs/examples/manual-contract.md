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
    "id": "eb76d9c4-8a56-4d83-80c5-090cb7832b06",
    "number": "INV-001",
    "issued_on": null,
    "status": "draft",
    "notes": null,
    "created_at": "2025-12-07T10:25:48.950Z",
    "updated_at": "2025-12-07T10:25:48.950Z"
  },
  {
    "id": "705b481d-c82b-42e1-b982-eff8f9c78cb9",
    "number": "INV-002",
    "issued_on": null,
    "status": "sent",
    "notes": null,
    "created_at": "2025-12-07T10:25:48.951Z",
    "updated_at": "2025-12-07T10:25:48.951Z"
  }
]
```

</details>

<details>
<summary>show</summary>

**Request**

```http
GET /funny-snake/invoices/2a127024-c5b7-466d-878f-cd50f6ba8480
```

**Response** `200`

```json
{
  "id": "2a127024-c5b7-466d-878f-cd50f6ba8480",
  "number": "INV-001",
  "issued_on": null,
  "status": "draft",
  "notes": null,
  "created_at": "2025-12-07T10:25:48.961Z",
  "updated_at": "2025-12-07T10:25:48.961Z"
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
  "id": "3e9c6590-926d-4c7d-8e8d-fc7fbf4aca36",
  "number": "INV-001",
  "issued_on": "2024-01-15",
  "status": "draft",
  "notes": "First invoice",
  "created_at": "2025-12-07T10:25:48.970Z",
  "updated_at": "2025-12-07T10:25:48.970Z"
}
```

</details>

<details>
<summary>update</summary>

**Request**

```http
PATCH /funny-snake/invoices/a8feef6c-488d-4bbb-ab0f-d29e868ed1ce
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
  "id": "a8feef6c-488d-4bbb-ab0f-d29e868ed1ce",
  "created_at": "2025-12-07T10:25:48.972Z",
  "updated_at": "2025-12-07T10:25:48.976Z"
}
```

</details>

<details>
<summary>destroy</summary>

**Request**

```http
DELETE /funny-snake/invoices/2d045a85-fca8-44cd-b8e8-33e5058a5196
```

**Response** `200`

```json
{
  "id": "2d045a85-fca8-44cd-b8e8-33e5058a5196",
  "number": "INV-001",
  "issued_on": null,
  "status": null,
  "notes": null,
  "created_at": "2025-12-07T10:25:48.978Z",
  "updated_at": "2025-12-07T10:25:48.978Z"
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