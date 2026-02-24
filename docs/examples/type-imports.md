---
order: 13
---

# Type Imports

Share type definitions between contracts with import

## API Definition

<small>`config/apis/calm_turtle.rb`</small>

<<< @/playground/config/apis/calm_turtle.rb

## Models

<small>`app/models/calm_turtle/customer.rb`</small>

<<< @/playground/app/models/calm_turtle/customer.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| billing_city | string | ✓ |  |
| billing_country | string | ✓ |  |
| billing_street | string | ✓ |  |
| created_at | datetime |  |  |
| name | string |  |  |
| updated_at | datetime |  |  |

:::

<small>`app/models/calm_turtle/order.rb`</small>

<<< @/playground/app/models/calm_turtle/order.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| customer_id | string |  |  |
| order_number | string |  |  |
| shipping_city | string | ✓ |  |
| shipping_country | string | ✓ |  |
| shipping_street | string | ✓ |  |
| updated_at | datetime |  |  |

:::

## Representations

<small>`app/representations/calm_turtle/customer_representation.rb`</small>

<<< @/playground/app/representations/calm_turtle/customer_representation.rb

<small>`app/representations/calm_turtle/order_representation.rb`</small>

<<< @/playground/app/representations/calm_turtle/order_representation.rb

## Contracts

<small>`app/contracts/calm_turtle/customer_contract.rb`</small>

<<< @/playground/app/contracts/calm_turtle/customer_contract.rb

<small>`app/contracts/calm_turtle/order_contract.rb`</small>

<<< @/playground/app/contracts/calm_turtle/order_contract.rb

## Controllers

<small>`app/controllers/calm_turtle/customers_controller.rb`</small>

<<< @/playground/app/controllers/calm_turtle/customers_controller.rb

<small>`app/controllers/calm_turtle/orders_controller.rb`</small>

<<< @/playground/app/controllers/calm_turtle/orders_controller.rb

## Request Examples

::: details Create customer

**Request**

```http
POST /calm_turtle/customers
Content-Type: application/json

{
  "customer": {
    "name": "Acme Corp",
    "billingStreet": "123 Main St",
    "billingCity": "Springfield",
    "billingCountry": "US"
  }
}
```

**Response** `201`

```json
{
  "customer": {
    "id": "75753994-5ee6-5196-ace1-7c3b6c63ed95",
    "name": "Acme Corp",
    "billingStreet": "123 Main St",
    "billingCity": "Springfield",
    "billingCountry": "US",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

::: details Create order

**Request**

```http
POST /calm_turtle/orders
Content-Type: application/json

{
  "order": {
    "orderNumber": "ORD-001",
    "customerId": "75753994-5ee6-5196-ace1-7c3b6c63ed95",
    "shippingStreet": "456 Oak Ave",
    "shippingCity": "Shelbyville",
    "shippingCountry": "US"
  }
}
```

**Response** `201`

```json
{
  "order": {
    "id": "f951f663-b887-5470-8c0c-03e090cd26eb",
    "orderNumber": "ORD-001",
    "customerId": "75753994-5ee6-5196-ace1-7c3b6c63ed95",
    "shippingStreet": "456 Oak Ave",
    "shippingCity": "Shelbyville",
    "shippingCountry": "US",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

::: details List orders

**Request**

```http
GET /calm_turtle/orders
```

**Response** `200`

```json
{
  "orders": [
    {
      "id": "f951f663-b887-5470-8c0c-03e090cd26eb",
      "orderNumber": "ORD-001",
      "customerId": "75753994-5ee6-5196-ace1-7c3b6c63ed95",
      "shippingStreet": "456 Oak Ave",
      "shippingCity": "Shelbyville",
      "shippingCountry": "US",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "2e6425b6-4cdb-5ca7-9764-8bd9171ba992",
      "orderNumber": "ORD-002",
      "customerId": "75753994-5ee6-5196-ace1-7c3b6c63ed95",
      "shippingStreet": "789 Elm Blvd",
      "shippingCity": "Capital City",
      "shippingCountry": "US",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
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

## Generated Output

::: details Introspection

<<< @/playground/public/calm-turtle/introspection.json

:::

::: details TypeScript

<<< @/playground/public/calm-turtle/typescript.ts

:::

::: details Zod

<<< @/playground/public/calm-turtle/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/calm-turtle/openapi.yml

:::