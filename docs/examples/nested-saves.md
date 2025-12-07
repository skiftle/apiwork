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

<details>
<summary>Database Schema</summary>

<<< @/app/public/clever-rabbit/schema.md

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
      "id": "ee2eb017-431d-4aec-974b-2ab125017c06",
      "order_number": "ORD-001",
      "status": "pending",
      "total": null,
      "created_at": "2025-12-07T11:20:16.524Z",
      "updated_at": "2025-12-07T11:20:16.524Z",
      "line_items": null,
      "shipping_address": null
    },
    {
      "id": "e0e5e10e-b872-4378-9294-c98738239f5a",
      "order_number": "ORD-002",
      "status": "pending",
      "total": null,
      "created_at": "2025-12-07T11:20:16.526Z",
      "updated_at": "2025-12-07T11:20:16.526Z",
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
GET /clever-rabbit/orders/bece78ba-693c-4ca6-8bc2-95451c77156b
```

**Response** `200`

```json
{
  "order": {
    "id": "bece78ba-693c-4ca6-8bc2-95451c77156b",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T11:20:16.562Z",
    "updated_at": "2025-12-07T11:20:16.562Z",
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
    "id": "cbef07e3-f47d-40ea-bacc-7b7c74d1b718",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T11:20:16.601Z",
    "updated_at": "2025-12-07T11:20:16.601Z",
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
PATCH /clever-rabbit/orders/aef8c8c8-501c-42fa-8c87-5a80bddec6c5
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
    "id": "aef8c8c8-501c-42fa-8c87-5a80bddec6c5",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T11:20:16.606Z",
    "updated_at": "2025-12-07T11:20:16.606Z",
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
DELETE /clever-rabbit/orders/35c8fae8-95a8-41d1-ada3-7d039b0608a6
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