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
      "id": "433d39a8-9b67-4f2e-9e3b-e8102c0e729d",
      "orderNumber": "ORD-001",
      "status": "pending",
      "total": null,
      "createdAt": "2025-12-18T13:29:03.794Z",
      "updatedAt": "2025-12-18T13:29:03.794Z",
      "lineItems": null,
      "shippingAddress": null
    },
    {
      "id": "1bc8b8cf-28ca-4ee2-b357-3a8a5c4178d7",
      "orderNumber": "ORD-002",
      "status": "pending",
      "total": null,
      "createdAt": "2025-12-18T13:29:03.795Z",
      "updatedAt": "2025-12-18T13:29:03.795Z",
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
GET /clever_rabbit/orders/4f6b3505-587b-41ea-b0d3-bab7e6d60924
```

**Response** `200`

```json
{
  "order": {
    "id": "4f6b3505-587b-41ea-b0d3-bab7e6d60924",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-18T13:29:03.818Z",
    "updatedAt": "2025-12-18T13:29:03.818Z",
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
    "id": "b5e64b77-eb8d-43f8-b1a1-9742b9929e0c",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-18T13:29:03.841Z",
    "updatedAt": "2025-12-18T13:29:03.841Z",
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
PATCH /clever_rabbit/orders/4d53f92b-6b46-4d7f-8477-6ecbbc91429d
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
    "id": "4d53f92b-6b46-4d7f-8477-6ecbbc91429d",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-18T13:29:03.847Z",
    "updatedAt": "2025-12-18T13:29:03.847Z",
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
DELETE /clever_rabbit/orders/4c0599e2-fcea-4429-9a19-df767fc59c91
```

**Response** `204`


</details>

<details>
<summary>Remove nested record</summary>

**Request**

```http
PATCH /clever_rabbit/orders/a162242c-9f80-41fe-8985-27ed67c13254
Content-Type: application/json

{
  "order": {
    "line_items": [
      {
        "id": "d884b481-8f65-446c-be60-9c35ed239bf1",
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