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

<small>`app/contracts/clever_rabbit/line_item_contract.rb`</small>

<<< @/playground/app/contracts/clever_rabbit/line_item_contract.rb

<small>`app/contracts/clever_rabbit/shipping_address_contract.rb`</small>

<<< @/playground/app/contracts/clever_rabbit/shipping_address_contract.rb

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
      "id": "38948b8f-2c00-5384-8f16-b1105fcd31fb",
      "orderNumber": "ORD-001",
      "status": "pending",
      "total": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "lineItems": [],
      "shippingAddress": null
    },
    {
      "id": "4c65a30e-5d9c-5523-b6bd-25e85ed94165",
      "orderNumber": "ORD-002",
      "status": "pending",
      "total": null,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z",
      "lineItems": [],
      "shippingAddress": null
    }
  ],
  "pagination": {
    "items": 2,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
  }
}
```

</details>

<details>
<summary>Get order details</summary>

**Request**

```http
GET /clever_rabbit/orders/d6afdfea-1e99-5a7c-98e0-f05896dbe62f
```

**Response** `200`

```json
{
  "order": {
    "id": "d6afdfea-1e99-5a7c-98e0-f05896dbe62f",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "lineItems": [],
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

**Response** `400`

```json
{
  "layer": "contract",
  "issues": [
    {
      "code": "field_missing",
      "detail": "Required",
      "meta": {
        "field": "_type"
      },
      "path": [
        "order",
        "shipping_address",
        "_type"
      ],
      "pointer": "/order/shipping_address/_type"
    }
  ]
}
```

</details>

<details>
<summary>Update order with new items</summary>

**Request**

```http
PATCH /clever_rabbit/orders/3870eeb2-49db-5e22-857a-ca2bcd2e4612
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
    "id": "3870eeb2-49db-5e22-857a-ca2bcd2e4612",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "lineItems": [
      {
        "id": "ad73acbb-0926-5060-9b75-5888bde61fc7",
        "productName": "New Item",
        "quantity": 3,
        "unitPrice": "19.99"
      }
    ],
    "shippingAddress": null
  }
}
```

</details>

<details>
<summary>Delete an order</summary>

**Request**

```http
DELETE /clever_rabbit/orders/099aec9e-6aec-5782-9315-9bc452881440
```

**Response** `204`


</details>

<details>
<summary>Remove nested record</summary>

**Request**

```http
PATCH /clever_rabbit/orders/d7b4402f-dd0a-5398-982d-dacd5b07955c
Content-Type: application/json

{
  "order": {
    "line_items": [
      {
        "id": "855dd577-4696-5477-8c71-4e8debd866be",
        "_destroy": true
      }
    ]
  }
}
```

**Response** `400`

```json
{
  "layer": "contract",
  "issues": [
    {
      "code": "type_invalid",
      "detail": "Invalid type",
      "meta": {
        "actual": "string",
        "expected": "integer",
        "field": "id"
      },
      "path": [
        "order",
        "line_items",
        "0",
        "id"
      ],
      "pointer": "/order/line_items/0/id"
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