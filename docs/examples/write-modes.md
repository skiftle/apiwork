---
order: 8
---

# Write Modes

Control which fields are accepted on create vs update

## API Definition

<small>`config/apis/sharp_hawk.rb`</small>

<<< @/playground/config/apis/sharp_hawk.rb

## Models

<small>`app/models/sharp_hawk/account.rb`</small>

<<< @/playground/app/models/sharp_hawk/account.rb

::: details Database Table

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| created_at | datetime |  |  |
| email | string |  |  |
| name | string |  |  |
| role | string |  | member |
| updated_at | datetime |  |  |
| verified | boolean |  |  |

:::

## Representations

<small>`app/representations/sharp_hawk/account_representation.rb`</small>

<<< @/playground/app/representations/sharp_hawk/account_representation.rb

## Contracts

<small>`app/contracts/sharp_hawk/account_contract.rb`</small>

<<< @/playground/app/contracts/sharp_hawk/account_contract.rb

## Controllers

<small>`app/controllers/sharp_hawk/accounts_controller.rb`</small>

<<< @/playground/app/controllers/sharp_hawk/accounts_controller.rb

## Request Examples

::: details Create account

**Request**

```http
POST /sharp_hawk/accounts
Content-Type: application/json

{
  "account": {
    "email": "alice@example.com",
    "name": "Alice Johnson"
  }
}
```

**Response** `201`

```json
{
  "account": {
    "id": "8324758d-5d34-504c-922a-694658537a93",
    "email": "alice@example.com",
    "name": "Alice Johnson",
    "role": "member",
    "verified": false,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

::: details Update account

**Request**

```http
PATCH /sharp_hawk/accounts/8324758d-5d34-504c-922a-694658537a93
Content-Type: application/json

{
  "account": {
    "name": "Alice Smith",
    "role": "admin",
    "verified": true
  }
}
```

**Response** `200`

```json
{
  "account": {
    "id": "8324758d-5d34-504c-922a-694658537a93",
    "email": "alice@example.com",
    "name": "Alice Smith",
    "role": "admin",
    "verified": true,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

::: details Show account

**Request**

```http
GET /sharp_hawk/accounts/8324758d-5d34-504c-922a-694658537a93
```

**Response** `200`

```json
{
  "account": {
    "id": "8324758d-5d34-504c-922a-694658537a93",
    "email": "alice@example.com",
    "name": "Alice Johnson",
    "role": "admin",
    "verified": true,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

:::

## Generated Output

::: details Introspection

<<< @/playground/public/sharp-hawk/introspection.json

:::

::: details TypeScript

<<< @/playground/public/sharp-hawk/typescript.ts

:::

::: details Zod

<<< @/playground/public/sharp-hawk/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/sharp-hawk/openapi.yml

:::