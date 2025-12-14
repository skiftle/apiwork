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
| order_number | string |  |  |
| status | string | ✓ | pending |
| total | decimal | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

<small>`app/models/clever_rabbit/line_item.rb`</small>

<<< @/playground/app/models/clever_rabbit/line_item.rb

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

<<< @/playground/app/models/clever_rabbit/shipping_address.rb

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
      "id": "ce4da3f0-327a-4e31-be90-0fa7cb9e5fb0",
      "orderNumber": "ORD-001",
      "status": "pending",
      "total": null,
      "createdAt": "2025-12-10T10:35:26.143Z",
      "updatedAt": "2025-12-10T10:35:26.143Z",
      "lineItems": null,
      "shippingAddress": null
    },
    {
      "id": "9d15dfc3-99a8-4097-8502-d22cf6b565f7",
      "orderNumber": "ORD-002",
      "status": "pending",
      "total": null,
      "createdAt": "2025-12-10T10:35:26.145Z",
      "updatedAt": "2025-12-10T10:35:26.145Z",
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
GET /clever_rabbit/orders/432b1f0d-45fe-419b-80ab-42e621ab3c42
```

**Response** `200`

```json
{
  "order": {
    "id": "432b1f0d-45fe-419b-80ab-42e621ab3c42",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-10T10:35:26.161Z",
    "updatedAt": "2025-12-10T10:35:26.161Z",
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
    "id": "5d86a89b-f091-4f47-ab7e-4a77d9efca95",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-10T10:35:26.186Z",
    "updatedAt": "2025-12-10T10:35:26.186Z",
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
PATCH /clever_rabbit/orders/b3b8f8d4-5a52-407e-8e05-4925ec157767
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
    "id": "b3b8f8d4-5a52-407e-8e05-4925ec157767",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2025-12-10T10:35:26.192Z",
    "updatedAt": "2025-12-10T10:35:26.192Z",
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
DELETE /clever_rabbit/orders/696a4d09-abe3-4488-932b-23d23736beee
```

**Response** `204`


</details>

<details>
<summary>Remove nested record</summary>

**Request**

```http
PATCH /clever_rabbit/orders/37729a24-cbcb-42b0-9b2a-373d1ac12224
Content-Type: application/json

{
  "order": {
    "line_items": [
      {
        "id": "7cdb6979-00e4-4a9c-9757-06b8c7c3b0b4",
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