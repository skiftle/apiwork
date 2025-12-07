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
  "orders": [
    {
      "id": "b44b163f-8f42-40f5-9335-0b283e0d22ce",
      "order_number": "ORD-001",
      "status": "pending",
      "total": null,
      "created_at": "2025-12-07T10:25:48.777Z",
      "updated_at": "2025-12-07T10:25:48.777Z",
      "line_items": null,
      "shipping_address": null
    },
    {
      "id": "cfa3c81b-9c63-4e03-b1e5-f3f80a3e3a20",
      "order_number": "ORD-002",
      "status": "pending",
      "total": null,
      "created_at": "2025-12-07T10:25:48.778Z",
      "updated_at": "2025-12-07T10:25:48.778Z",
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
<summary>show</summary>

**Request**

```http
GET /clever-rabbit/orders/59b980b3-2e2c-4863-be00-533529f2f76d
```

**Response** `200`

```json
{
  "order": {
    "id": "59b980b3-2e2c-4863-be00-533529f2f76d",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T10:25:48.800Z",
    "updated_at": "2025-12-07T10:25:48.800Z",
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
    "id": "13806e22-8a51-4214-b189-2b3761ebeb0b",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T10:25:48.818Z",
    "updated_at": "2025-12-07T10:25:48.818Z",
    "line_items": null,
    "shipping_address": null
  }
}
```

</details>

<details>
<summary>update</summary>

**Request**

```http
PATCH /clever-rabbit/orders/a712fc8b-e74e-49a5-8863-3e7ea0581de2
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
    "id": "a712fc8b-e74e-49a5-8863-3e7ea0581de2",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T10:25:48.823Z",
    "updated_at": "2025-12-07T10:25:48.823Z",
    "line_items": null,
    "shipping_address": null
  }
}
```

</details>

<details>
<summary>destroy</summary>

**Request**

```http
DELETE /clever-rabbit/orders/40cde02e-ea9a-441e-8dfb-5fb2739be700
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