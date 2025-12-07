---
order: 3
---

# Nested Saves

Create, update, and delete nested records in a single request

## API Definition

<small>`config/apis/clever_rabbit.rb`</small>

<<< @/app/config/apis/clever_rabbit.rb

## Models

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

<small>`app/schemas/clever_rabbit/order_schema.rb`</small>

<<< @/app/app/schemas/clever_rabbit/order_schema.rb

<small>`app/schemas/clever_rabbit/line_item_schema.rb`</small>

<<< @/app/app/schemas/clever_rabbit/line_item_schema.rb

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
GET /clever_rabbit/orders
```

**Response** `200`

```json
{
  "orders": [
    {
      "id": "9db226cc-1d71-4a81-9935-565441223790",
      "orderNumber": "ORD-001",
      "status": "pending",
      "total": null,
      "createdAt": "2025-12-07T16:39:25.864Z",
      "updatedAt": "2025-12-07T16:39:25.864Z",
      "lineItems": null,
      "shippingAddress": null
    },
    {
      "id": "361d50dc-a385-4f83-a837-9093f534a419",
      "orderNumber": "ORD-002",
      "status": "pending",
      "total": null,
      "createdAt": "2025-12-07T16:39:25.866Z",
      "updatedAt": "2025-12-07T16:39:25.866Z",
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
GET /clever_rabbit/orders/7d0eb56d-b767-4471-aae0-54ce0804b74e
```

**Response** `200`

```json
{
  "order": {
    "id": "7d0eb56d-b767-4471-aae0-54ce0804b74e",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-07T16:39:25.883Z",
    "updatedAt": "2025-12-07T16:39:25.883Z",
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
    "id": "3595d427-3ad4-4748-b63c-58c67d1d0e2a",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-07T16:39:25.903Z",
    "updatedAt": "2025-12-07T16:39:25.903Z",
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
PATCH /clever_rabbit/orders/463d2fde-da75-4d3d-8423-8f8ab32ef747
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
    "id": "463d2fde-da75-4d3d-8423-8f8ab32ef747",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-07T16:39:25.908Z",
    "updatedAt": "2025-12-07T16:39:25.908Z",
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
DELETE /clever_rabbit/orders/dcbd656c-eb59-4592-9041-cdb3ff8e45a3
```

**Response** `200`

```json
{
  "meta": {}
}
```

</details>

<details>
<summary>Remove nested record</summary>

**Request**

```http
PATCH /clever_rabbit/orders/b18e4b4a-a4e4-4acd-b680-bb14e059a949
Content-Type: application/json

{
  "order": {
    "line_items": [
      {
        "id": "efa605e9-38fb-477c-b755-361635799969",
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