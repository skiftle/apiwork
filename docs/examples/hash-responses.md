---
order: 19
---

# Hash Responses

Expose plain hashes instead of ActiveRecord models

## API Definition

<small>`config/apis/lazy_cow.rb`</small>

<<< @/playground/config/apis/lazy_cow.rb

## Contracts

<small>`app/contracts/lazy_cow/status_contract.rb`</small>

<<< @/playground/app/contracts/lazy_cow/status_contract.rb

## Controllers

<small>`app/controllers/lazy_cow/statuses_controller.rb`</small>

<<< @/playground/app/controllers/lazy_cow/statuses_controller.rb

## Request Examples

::: details Health check

**Request**

```http
GET /lazy_cow/status/health
```

**Response** `200`

```json
{
  "status": "ok",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "version": "1.0.0"
}
```

:::

::: details System statistics

**Request**

```http
GET /lazy_cow/status/stats
```

**Response** `200`

```json
{
  "postsCount": 5678,
  "uptimeSeconds": 86400,
  "usersCount": 1234
}
```

:::

## Generated Output

::: details Introspection

<<< @/playground/public/lazy-cow/introspection.json

:::

::: details TypeScript

<<< @/playground/public/lazy-cow/typescript.ts

:::

::: details Zod

<<< @/playground/public/lazy-cow/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/lazy-cow/openapi.yml

:::