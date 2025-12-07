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

### Index

**Request**

```http
GET /clever-rabbit/orders
```

**Response** `200`

```json
{
  "orders": [],
  "pagination": {
    "current": 1,
    "next": null,
    "prev": null,
    "total": 0,
    "items": 0
  }
}
```

### Show

**Request**

```http
GET /clever-rabbit/orders/630e6144-a106-4a55-be86-42ef1799f224
```

**Response** `200`

```json
{
  "order": {
    "id": "630e6144-a106-4a55-be86-42ef1799f224",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T08:33:55.516Z",
    "updated_at": "2025-12-07T08:33:55.516Z",
    "line_items": null,
    "shipping_address": null
  }
}
```

### Create

**Request**

```http
POST /clever-rabbit/orders
Content-Type: application/json

{
  "order": {
    "order_number": "ORD-001",
    "line_items_attributes": [
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
    "shipping_address_attributes": {
      "street": "123 Main St",
      "city": "Springfield",
      "postal_code": "12345",
      "country": "USA"
    }
  }
}
```

**Response** `400`

```json
{
  "issues": [
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "path": [
        "order",
        "line_items_attributes"
      ],
      "pointer": "/order/line_items_attributes",
      "meta": {
        "field": "line_items_attributes",
        "allowed": [
          "order_number",
          "line_items",
          "shipping_address"
        ]
      }
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "path": [
        "order",
        "shipping_address_attributes"
      ],
      "pointer": "/order/shipping_address_attributes",
      "meta": {
        "field": "shipping_address_attributes",
        "allowed": [
          "order_number",
          "line_items",
          "shipping_address"
        ]
      }
    }
  ]
}
```

### Update

**Request**

```http
PATCH /clever-rabbit/orders/f960a5a2-0f1a-4e2f-9b11-e0bb5905e9fa
Content-Type: application/json

{
  "order": {
    "line_items_attributes": [
      {
        "product_name": "New Item",
        "quantity": 3,
        "unit_price": 19.99
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
    },
    {
      "code": "field_unknown",
      "detail": "Unknown field",
      "path": [
        "order",
        "line_items_attributes"
      ],
      "pointer": "/order/line_items_attributes",
      "meta": {
        "field": "line_items_attributes",
        "allowed": [
          "order_number",
          "line_items",
          "shipping_address"
        ]
      }
    }
  ]
}
```

### Destroy

**Request**

```http
DELETE /clever-rabbit/orders/6c4e225a-72ad-4256-bd13-d84bb4d6a0ad
```

**Response** `200`

```json
{
  "meta": {}
}
```

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