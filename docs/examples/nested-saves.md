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
      "id": "1052addb-564e-4e1f-a8cc-e8b61d46608e",
      "order_number": "ORD-001",
      "status": "pending",
      "total": null,
      "created_at": "2025-12-07T11:45:01.089Z",
      "updated_at": "2025-12-07T11:45:01.089Z",
      "line_items": null,
      "shipping_address": null
    },
    {
      "id": "a942de33-f1ff-44cf-a809-254c0d160ca1",
      "order_number": "ORD-002",
      "status": "pending",
      "total": null,
      "created_at": "2025-12-07T11:45:01.091Z",
      "updated_at": "2025-12-07T11:45:01.091Z",
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
GET /clever-rabbit/orders/3508d31a-98d5-4d21-896c-2e3be0cc7966
```

**Response** `200`

```json
{
  "order": {
    "id": "3508d31a-98d5-4d21-896c-2e3be0cc7966",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T11:45:01.115Z",
    "updated_at": "2025-12-07T11:45:01.115Z",
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
    "id": "d30f3982-06be-421d-b0bd-821aa946211f",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T11:45:01.136Z",
    "updated_at": "2025-12-07T11:45:01.136Z",
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
PATCH /clever-rabbit/orders/38b74b9e-2ac1-4c0a-80c3-49417558663a
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
    "id": "38b74b9e-2ac1-4c0a-80c3-49417558663a",
    "order_number": "ORD-001",
    "status": "pending",
    "total": null,
    "created_at": "2025-12-07T11:45:01.143Z",
    "updated_at": "2025-12-07T11:45:01.143Z",
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
DELETE /clever-rabbit/orders/8b99bb40-32d2-45cd-a437-1b18e9d5fc72
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