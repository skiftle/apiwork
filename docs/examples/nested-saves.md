---
order: 7
---

# Nested Saves

Create, update, and delete nested records in a single request

## API Definition

<small>`config/apis/clever_rabbit.rb`</small>

<<< @/playground/config/apis/clever_rabbit.rb

## Models

<small>`app/models/clever_rabbit/order.rb`</small>

<<< @/playground/app/models/clever_rabbit/order.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| order_number | string |  |  |
| status | string | ✓ | pending |
| total | decimal | ✓ |  |
| updated_at | datetime |  |  |

:::

<small>`app/models/clever_rabbit/line_item.rb`</small>

<<< @/playground/app/models/clever_rabbit/line_item.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| order_id | string |  |  |
| product_name | string |  |  |
| quantity | integer | ✓ | 1 |
| unit_price | decimal | ✓ |  |
| updated_at | datetime |  |  |

:::

<small>`app/models/clever_rabbit/shipping_address.rb`</small>

<<< @/playground/app/models/clever_rabbit/shipping_address.rb

::: details Database Table

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

:::

## Representations

<small>`app/representations/clever_rabbit/order_representation.rb`</small>

<<< @/playground/app/representations/clever_rabbit/order_representation.rb

<small>`app/representations/clever_rabbit/line_item_representation.rb`</small>

<<< @/playground/app/representations/clever_rabbit/line_item_representation.rb

<small>`app/representations/clever_rabbit/shipping_address_representation.rb`</small>

<<< @/playground/app/representations/clever_rabbit/shipping_address_representation.rb

## Contracts

<small>`app/contracts/clever_rabbit/order_contract.rb`</small>

<<< @/playground/app/contracts/clever_rabbit/order_contract.rb

## Controllers

<small>`app/controllers/clever_rabbit/orders_controller.rb`</small>

<<< @/playground/app/controllers/clever_rabbit/orders_controller.rb

## Request Examples

::: details List all orders

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

:::

::: details Get order details

**Request**

```http
GET /clever_rabbit/orders/38948b8f-2c00-5384-8f16-b1105fcd31fb
```

**Response** `200`

```json
{
  "order": {
    "id": "38948b8f-2c00-5384-8f16-b1105fcd31fb",
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

:::

::: details Create order with nested records

**Request**

```http
POST /clever_rabbit/orders
Content-Type: application/json

{
  "order": {
    "orderNumber": "ORD-001",
    "lineItems": [
      {
        "productName": "Widget",
        "quantity": 2,
        "unitPrice": 29.99
      },
      {
        "productName": "Gadget",
        "quantity": 1,
        "unitPrice": 49.99
      }
    ],
    "shippingAddress": {
      "street": "123 Main St",
      "city": "Springfield",
      "postalCode": "12345",
      "country": "USA"
    }
  }
}
```

**Response** `201`

```json
{
  "order": {
    "id": "38948b8f-2c00-5384-8f16-b1105fcd31fb",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "lineItems": [
      {
        "id": "ad73acbb-0926-5060-9b75-5888bde61fc7",
        "productName": "Widget",
        "quantity": 2,
        "unitPrice": "29.99"
      },
      {
        "id": "987c1624-9b7b-5467-910c-4dc0035b91ee",
        "productName": "Gadget",
        "quantity": 1,
        "unitPrice": "49.99"
      }
    ],
    "shippingAddress": {
      "id": "3cb3bbd4-ed44-5c37-a3bf-f77ea95a7e5a",
      "street": "123 Main St",
      "city": "Springfield",
      "postalCode": "12345",
      "country": "USA"
    }
  }
}
```

:::

::: details Update order with new items

**Request**

```http
PATCH /clever_rabbit/orders/38948b8f-2c00-5384-8f16-b1105fcd31fb
Content-Type: application/json

{
  "order": {
    "lineItems": [
      {
        "productName": "New Item",
        "quantity": 3,
        "unitPrice": 19.99
      }
    ]
  }
}
```

**Response** `200`

```json
{
  "order": {
    "id": "38948b8f-2c00-5384-8f16-b1105fcd31fb",
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

:::

::: details Delete an order

**Request**

```http
DELETE /clever_rabbit/orders/38948b8f-2c00-5384-8f16-b1105fcd31fb
```

**Response** `204`


:::

::: details Remove nested record

**Request**

```http
PATCH /clever_rabbit/orders/38948b8f-2c00-5384-8f16-b1105fcd31fb
Content-Type: application/json

{
  "order": {
    "lineItems": [
      {
        "OP": "delete",
        "id": "987c1624-9b7b-5467-910c-4dc0035b91ee"
      }
    ]
  }
}
```

**Response** `200`

```json
{
  "order": {
    "id": "38948b8f-2c00-5384-8f16-b1105fcd31fb",
    "orderNumber": "ORD-001",
    "status": "pending",
    "total": null,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z",
    "lineItems": [
      {
        "id": "ad73acbb-0926-5060-9b75-5888bde61fc7",
        "productName": "Widget to Keep",
        "quantity": 2,
        "unitPrice": "19.99"
      }
    ],
    "shippingAddress": null
  }
}
```

:::

## Generated Output

::: details Introspection

<<< @/playground/public/clever-rabbit/introspection.json

:::

::: details TypeScript

<<< @/playground/public/clever-rabbit/typescript.ts

:::

::: details Zod

<<< @/playground/public/clever-rabbit/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/clever-rabbit/openapi.yml

:::