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
GET /clever_rabbit/orders
```

**Response** `200`

```json
{
  "orders": [
    {
      "id": "f7942efc-17b2-4174-8866-f0ae21d90bda",
      "orderNumber": "ORD-001",
      "status": "pending",
      "total": null,
      "createdAt": "2025-12-07T14:49:42.490Z",
      "updatedAt": "2025-12-07T14:49:42.490Z",
      "lineItems": null,
      "shippingAddress": null
    },
    {
      "id": "74433efa-814c-474b-b484-cb2cf17af6f0",
      "orderNumber": "ORD-002",
      "status": "pending",
      "total": null,
      "createdAt": "2025-12-07T14:49:42.492Z",
      "updatedAt": "2025-12-07T14:49:42.492Z",
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
GET /clever_rabbit/orders/b4eb3fb9-411c-4759-a438-7f8b60fcb4c4
```

**Response** `200`

```json
{
  "order": {
    "id": "b4eb3fb9-411c-4759-a438-7f8b60fcb4c4",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-07T14:49:42.520Z",
    "updatedAt": "2025-12-07T14:49:42.520Z",
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
    "id": "032a02d1-665f-4bd0-b572-2074a49a8566",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-07T14:49:42.548Z",
    "updatedAt": "2025-12-07T14:49:42.548Z",
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
PATCH /clever_rabbit/orders/35bbeeca-705c-4589-90f7-858aee03c7c0
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
    "id": "35bbeeca-705c-4589-90f7-858aee03c7c0",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-07T14:49:42.557Z",
    "updatedAt": "2025-12-07T14:49:42.557Z",
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
DELETE /clever_rabbit/orders/21aff6e1-0b3b-4d18-a690-99fbcda116b1
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
PATCH /clever_rabbit/orders/7023963f-c596-40ea-b55c-d8d8f7dbf7fe
Content-Type: application/json

{
  "order": {
    "line_items": [
      {
        "id": "9764fcbd-2d8b-4a45-bcdd-959f8e8eb245",
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