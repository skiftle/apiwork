---
order: 3
---

# Nested Saves

Create, update, and delete nested records in a single request

## API Definition

<small>`config/apis/clever_rabbit.rb`</small>

<<< @/playground/config/apis/clever_rabbit.rb

## Models

<small>`app/models/clever_rabbit/order.rb`</small>

<<< @/playground/app/models/clever_rabbit/order.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| order_number | string |  |  |
| status | string | ✓ | pending |
| total | decimal | ✓ |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/clever_rabbit/line_item.rb`</small>

<<< @/playground/app/models/clever_rabbit/line_item.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| order_id | string |  |  |
| product_name | string |  |  |
| quantity | integer | ✓ | 1 |
| unit_price | decimal | ✓ |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/clever_rabbit/shipping_address.rb`</small>

<<< @/playground/app/models/clever_rabbit/shipping_address.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| city | string |  |  |
| country | string |  |  |
| created_at | datetime |  |  |
| order_id | string |  |  |
| postal_code | string |  |  |
| street | string |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/clever_rabbit/order_schema.rb`</small>

<<< @/playground/app/schemas/clever_rabbit/order_schema.rb

<small>`app/schemas/clever_rabbit/line_item_schema.rb`</small>

<<< @/playground/app/schemas/clever_rabbit/line_item_schema.rb

<small>`app/schemas/clever_rabbit/shipping_address_schema.rb`</small>

<<< @/playground/app/schemas/clever_rabbit/shipping_address_schema.rb

## Contracts

<small>`app/contracts/clever_rabbit/order_contract.rb`</small>

<<< @/playground/app/contracts/clever_rabbit/order_contract.rb

## Controllers

<small>`app/controllers/clever_rabbit/orders_controller.rb`</small>

<<< @/playground/app/controllers/clever_rabbit/orders_controller.rb

---



## Request Examples

<details>
<summary>List all orders</summary>

**Request**

```http
GET /clever_rabbit/orders
```

**Response** `200`

```json
{
  "orders": [
    {
      "id": "b9504fe5-aa17-47a9-824f-d6e4c05273cf",
      "orderNumber": "ORD-001",
      "status": "pending",
      "total": null,
      "createdAt": "2025-12-18T13:21:01.868Z",
      "updatedAt": "2025-12-18T13:21:01.868Z",
      "lineItems": null,
      "shippingAddress": null
    },
    {
      "id": "e2ed56a8-cb4d-46a5-ac4c-ee1ce5113141",
      "orderNumber": "ORD-002",
      "status": "pending",
      "total": null,
      "createdAt": "2025-12-18T13:21:01.870Z",
      "updatedAt": "2025-12-18T13:21:01.870Z",
      "lineItems": null,
      "shippingAddress": null
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
GET /clever_rabbit/orders/9180de6d-cbdf-4231-bfd6-eceb0a1ea615
```

**Response** `200`

```json
{
  "order": {
    "id": "9180de6d-cbdf-4231-bfd6-eceb0a1ea615",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-18T13:21:01.887Z",
    "updatedAt": "2025-12-18T13:21:01.887Z",
    "lineItems": null,
    "shippingAddress": null
  }
}
```

</details>

<details>
<summary>Create order with nested records</summary>

**Request**

```http
POST /clever_rabbit/orders
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
    "id": "a9e3d976-e21c-43ee-ba71-c4f861f45aec",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-18T13:21:01.907Z",
    "updatedAt": "2025-12-18T13:21:01.907Z",
    "lineItems": null,
    "shippingAddress": null
  }
}
```

</details>

<details>
<summary>Update order with new items</summary>

**Request**

```http
PATCH /clever_rabbit/orders/2633baf5-3ea5-445d-9b0e-d72ff8237cc9
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
    "id": "2633baf5-3ea5-445d-9b0e-d72ff8237cc9",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-18T13:21:01.912Z",
    "updatedAt": "2025-12-18T13:21:01.912Z",
    "lineItems": null,
    "shippingAddress": null
  }
}
```

</details>

<details>
<summary>Delete an order</summary>

**Request**

```http
DELETE /clever_rabbit/orders/9c8682dc-09d7-425b-b091-a278c2433ede
```

**Response** `204`


</details>

<details>
<summary>Remove nested record</summary>

**Request**

```http
PATCH /clever_rabbit/orders/35e8b5ec-ee77-409a-b560-d5be3c40f765
Content-Type: application/json

{
  "order": {
    "line_items": [
      {
        "id": "d97bb226-6ad7-4321-b857-202547533000",
        "_destroy": true
      }
    ]
  }
}
```

**Response** `400`

```json
{
  "issues": [
    {
      "code": "field_missing",
      "detail": "Field required",
      "path": [
        "order",
        "order_number"
      ],
      "pointer": "/order/order_number",
      "meta": {
        "field": "order_number"
      }
    }
  ]
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/clever-rabbit/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/clever-rabbit/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/clever-rabbit/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/clever-rabbit/openapi.yml

</details>