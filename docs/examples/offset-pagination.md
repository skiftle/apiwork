---
order: 4
---

# Offset Pagination

Offset-based pagination with page number and page size query parameters

## API Definition

<small>`config/apis/steady_horse.rb`</small>

<<< @/playground/config/apis/steady_horse.rb

## Models

<small>`app/models/steady_horse/product.rb`</small>

<<< @/playground/app/models/steady_horse/product.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| category | string |  |  |
| created_at | datetime |  |  |
| name | string |  |  |
| price | decimal |  |  |
| updated_at | datetime |  |  |

:::

## Representations

<small>`app/representations/steady_horse/product_representation.rb`</small>

<<< @/playground/app/representations/steady_horse/product_representation.rb

## Contracts

<small>`app/contracts/steady_horse/product_contract.rb`</small>

<<< @/playground/app/contracts/steady_horse/product_contract.rb

## Controllers

<small>`app/controllers/steady_horse/products_controller.rb`</small>

<<< @/playground/app/controllers/steady_horse/products_controller.rb

## Request Examples

::: details First page (default)

**Request**

```http
GET /steady_horse/products
```

**Response** `200`

```json
{
  "products": [
    {
      "id": "267adb6a-d0b4-54a7-a389-3b98a9eaa28c",
      "name": "Wireless Keyboard",
      "price": "49.99",
      "category": "electronics",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "03df3eee-f5c2-5936-833e-1428b7014046",
      "name": "USB-C Cable",
      "price": "12.99",
      "category": "electronics",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "9b201354-c4da-5ac1-b1af-277760ef44ae",
      "name": "Desk Lamp",
      "price": "34.99",
      "category": "office",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "5ce18568-b578-5e99-b0fa-807d16a49d0f",
      "name": "Notebook",
      "price": "8.99",
      "category": "office",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "de39e4db-cbc3-5392-a6d0-467af1c5b29d",
      "name": "Monitor Stand",
      "price": "79.99",
      "category": "office",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "040ac486-238a-5942-abec-ad251c0cbb51",
      "name": "Webcam",
      "price": "59.99",
      "category": "electronics",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "cb8c0234-a0a3-589a-9dba-12e95296dc98",
      "name": "Mouse Pad",
      "price": "14.99",
      "category": "accessories",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "bf56b805-7bca-54ee-a90b-c9ebf84d9bec",
      "name": "Headphones",
      "price": "89.99",
      "category": "electronics",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 8,
    "total": 1,
    "current": 1,
    "next": null,
    "prev": null
  }
}
```

:::

::: details Specific page

**Request**

```http
GET /steady_horse/products?page[number]=2&page[size]=3
```

**Response** `200`

```json
{
  "products": [
    {
      "id": "5ce18568-b578-5e99-b0fa-807d16a49d0f",
      "name": "Notebook",
      "price": "8.99",
      "category": "office",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "de39e4db-cbc3-5392-a6d0-467af1c5b29d",
      "name": "Monitor Stand",
      "price": "79.99",
      "category": "office",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "040ac486-238a-5942-abec-ad251c0cbb51",
      "name": "Webcam",
      "price": "59.99",
      "category": "electronics",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 8,
    "total": 3,
    "current": 2,
    "next": 3,
    "prev": 1
  }
}
```

:::

::: details Custom page size

**Request**

```http
GET /steady_horse/products?page[size]=2
```

**Response** `200`

```json
{
  "products": [
    {
      "id": "267adb6a-d0b4-54a7-a389-3b98a9eaa28c",
      "name": "Wireless Keyboard",
      "price": "49.99",
      "category": "electronics",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    },
    {
      "id": "03df3eee-f5c2-5936-833e-1428b7014046",
      "name": "USB-C Cable",
      "price": "12.99",
      "category": "electronics",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "items": 5,
    "total": 3,
    "current": 1,
    "next": 2,
    "prev": null
  }
}
```

:::

## Generated Output

::: details Introspection

<<< @/playground/public/steady-horse/introspection.json

:::

::: details TypeScript

<<< @/playground/public/steady-horse/typescript.ts

:::

::: details Zod

<<< @/playground/public/steady-horse/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/steady-horse/openapi.yml

:::