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

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| order_id | string |  |  |
| product_name | string |  |  |
| quantity | integer | ✓ | 1 |
| unit_price | decimal | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/clever_rabbit/order.rb`</small>

<<< @/app/app/models/clever_rabbit/order.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| order_number | string |  |  |
| status | string | ✓ | pending |
| total | decimal | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/clever_rabbit/shipping_address.rb`</small>

<<< @/app/app/models/clever_rabbit/shipping_address.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| order_id | string |  |  |
| street | string |  |  |
| city | string |  |  |
| postal_code | string |  |  |
| country | string |  |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

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
<summary>List all orders</summary>

**Request**

```http
GET /clever-rabbit/orders
```

**Response** `200`

```json
{
  "orders": [
    {
      "id": "41b0f85e-80d2-40bf-82c2-83c1974a45bf",
      "order_number": "ORD-001",
      "status": "pending",
      "total": null,
      "created_at": "2025-12-07T12:02:57.767Z",
      "updated_at": "2025-12-07T12:02:57.767Z",
      "line_items": null,
      "shipping_address": null
    },
    {
      "id": "d167f251-7527-440a-89ed-66f3402c11b7",
      "order_number": "ORD-002",
      "status": "pending",
      "total": null,
      "created_at": "2025-12-07T12:02:57.768Z",
      "updated_at": "2025-12-07T12:02:57.768Z",
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
<summary>Get order details</summary>

**Request**

```http
GET /clever-rabbit/orders/fbbac020-72d7-4e1c-be6e-d8d3a22f4954
```

**Response** `200`

```json
{
  "order": {
    "id": "fbbac020-72d7-4e1c-be6e-d8d3a22f4954",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T12:02:57.788Z",
    "updated_at": "2025-12-07T12:02:57.788Z",
    "line_items": null,
    "shipping_address": null
  }
}
```

</details>

<details>
<summary>Create order with nested records</summary>

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
    "id": "cb2cadf8-f8f0-41d2-b714-896ad8870acd",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T12:02:57.805Z",
    "updated_at": "2025-12-07T12:02:57.805Z",
    "line_items": null,
    "shipping_address": null
  }
}
```

</details>

<details>
<summary>Update order with new items</summary>

**Request**

```http
PATCH /clever-rabbit/orders/77fc7d6b-3552-4996-8f6f-e4336764407f
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
    "id": "77fc7d6b-3552-4996-8f6f-e4336764407f",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T12:02:57.809Z",
    "updated_at": "2025-12-07T12:02:57.809Z",
    "line_items": null,
    "shipping_address": null
  }
}
```

</details>

<details>
<summary>Delete an order</summary>

**Request**

```http
DELETE /clever-rabbit/orders/e3edd64f-e75d-4ed0-adc1-ada1763202aa
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