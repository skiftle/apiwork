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

</details>

<details>
<summary>show</summary>

**Request**

```http
GET /clever-rabbit/orders/53e8ba8c-9300-4b3f-abbe-a74710b5caf8
```

**Response** `200`

```json
{
  "order": {
    "id": "53e8ba8c-9300-4b3f-abbe-a74710b5caf8",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T08:42:27.112Z",
    "updated_at": "2025-12-07T08:42:27.112Z",
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
    "line_items_fields": [
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
    "shipping_address_fields": {
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
        "line_items_fields"
      ],
      "pointer": "/order/line_items_fields",
      "meta": {
        "field": "line_items_fields",
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
        "shipping_address_fields"
      ],
      "pointer": "/order/shipping_address_fields",
      "meta": {
        "field": "shipping_address_fields",
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

</details>

<details>
<summary>update</summary>

**Request**

```http
PATCH /clever-rabbit/orders/fa5aaad2-e6cf-4273-b5ca-c8b9af6a28d1
Content-Type: application/json

{
  "order": {
    "line_items_fields": [
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
        "line_items_fields"
      ],
      "pointer": "/order/line_items_fields",
      "meta": {
        "field": "line_items_fields",
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

</details>

<details>
<summary>destroy</summary>

**Request**

```http
DELETE /clever-rabbit/orders/9af15b45-638b-44d5-bd1b-bb5d2ec9ce17
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