---
order: 3
---

# Nested Saves

Create, update, and delete nested records in a single request

## API Definition

<small>`config/apis/clever_rabbit.rb`</small>

<<< @/app/config/apis/clever_rabbit.rb

## Models

<small>`app/models/clever_rabbit/line_item.rb`</small>

<<< @/app/app/models/clever_rabbit/line_item.rb

<small>`app/models/clever_rabbit/order.rb`</small>

<<< @/app/app/models/clever_rabbit/order.rb

<small>`app/models/clever_rabbit/shipping_address.rb`</small>

<<< @/app/app/models/clever_rabbit/shipping_address.rb

## Schemas

<small>`app/schemas/clever_rabbit/line_item_schema.rb`</small>

<<< @/app/app/schemas/clever_rabbit/line_item_schema.rb

<small>`app/schemas/clever_rabbit/order_schema.rb`</small>

<<< @/app/app/schemas/clever_rabbit/order_schema.rb

<small>`app/schemas/clever_rabbit/shipping_address_schema.rb`</small>

<<< @/app/app/schemas/clever_rabbit/shipping_address_schema.rb

## Contracts

<small>`app/contracts/clever_rabbit/order_contract.rb`</small>

<<< @/app/app/contracts/clever_rabbit/order_contract.rb

## Controllers

<small>`app/controllers/clever_rabbit/orders_controller.rb`</small>

<<< @/app/app/controllers/clever_rabbit/orders_controller.rb

---



## Request Examples

<details>
<summary>index</summary>

**Request**

```http
GET /clever-rabbit/orders
```

**Response** `200`

```json
{
  "orders": [
    {
      "id": "e975f40c-52d6-4a2a-87e1-9223534e80e4",
      "order_number": "ORD-001",
      "status": "pending",
      "total": null,
      "created_at": "2025-12-07T09:01:00.926Z",
      "updated_at": "2025-12-07T09:01:00.926Z",
      "line_items": null,
      "shipping_address": null
    },
    {
      "id": "29ec1c15-9a40-4803-bf2b-2dd1e4f75d4d",
      "order_number": "ORD-002",
      "status": "pending",
      "total": null,
      "created_at": "2025-12-07T09:01:00.927Z",
      "updated_at": "2025-12-07T09:01:00.927Z",
      "line_items": null,
      "shipping_address": null
    }
  ],
  "pagination": {
    "current": 1,
    "next": null,
    "prev": null,
    "total": 1,
    "items": 2
  }
}
```

</details>

<details>
<summary>show</summary>

**Request**

```http
GET /clever-rabbit/orders/9d8bf9b6-86fd-45cb-90af-7f09a9e4149c
```

**Response** `200`

```json
{
  "order": {
    "id": "9d8bf9b6-86fd-45cb-90af-7f09a9e4149c",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T09:01:00.967Z",
    "updated_at": "2025-12-07T09:01:00.967Z",
    "line_items": null,
    "shipping_address": null
  }
}
```

</details>

<details>
<summary>create</summary>

**Request**

```http
POST /clever-rabbit/orders
Content-Type: application/json

{
  "order": {
    "order_number": "ORD-001",
    "line_items": [
      {
        "product_name": "Widget",
        "quantity": 2,
        "unit_price": 29.99
      },
      {
        "product_name": "Gadget",
        "quantity": 1,
        "unit_price": 49.99
      }
    ],
    "shipping_address": {
      "street": "123 Main St",
      "city": "Springfield",
      "postal_code": "12345",
      "country": "USA"
    }
  }
}
```

**Response** `201`

```json
{
  "order": {
    "id": "898334f6-f2d1-4d14-a1a5-cf937945a67f",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T09:01:01.007Z",
    "updated_at": "2025-12-07T09:01:01.007Z",
    "line_items": null,
    "shipping_address": null
  }
}
```

</details>

<details>
<summary>update</summary>

**Request**

```http
PATCH /clever-rabbit/orders/8fdc4ad3-44ab-4cb8-82bf-c1a7cf195f3f
Content-Type: application/json

{
  "order": {
    "order_number": "ORD-001",
    "line_items": [
      {
        "product_name": "New Item",
        "quantity": 3,
        "unit_price": 19.99
      }
    ]
  }
}
```

**Response** `200`

```json
{
  "order": {
    "id": "8fdc4ad3-44ab-4cb8-82bf-c1a7cf195f3f",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T09:01:01.012Z",
    "updated_at": "2025-12-07T09:01:01.012Z",
    "line_items": null,
    "shipping_address": null
  }
}
```

</details>

<details>
<summary>destroy</summary>

**Request**

```http
DELETE /clever-rabbit/orders/9c43018e-1138-49c1-8c90-693984b753dd
```

**Response** `200`

```json
{
  "meta": {}
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/app/public/clever-rabbit/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/clever-rabbit/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/clever-rabbit/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/clever-rabbit/openapi.yml

</details>