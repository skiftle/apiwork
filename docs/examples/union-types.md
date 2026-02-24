---
order: 11
---

# Union Types

Discriminated unions for polymorphic request and response shapes

## API Definition

<small>`config/apis/bright_parrot.rb`</small>

<<< @/playground/config/apis/bright_parrot.rb

## Contracts

<small>`app/contracts/bright_parrot/notification_contract.rb`</small>

<<< @/playground/app/contracts/bright_parrot/notification_contract.rb

## Controllers

<small>`app/controllers/bright_parrot/notifications_controller.rb`</small>

<<< @/playground/app/controllers/bright_parrot/notifications_controller.rb

## Request Examples

::: details Create email preference

**Request**

```http
POST /bright_parrot/notifications
Content-Type: application/json

{
  "preference": {
    "channel": "email",
    "address": "alice@example.com",
    "digest": true
  }
}
```

**Response** `201`

```json
{
  "address": "alice@example.com",
  "digest": true,
  "channel": "email"
}
```

:::

::: details Create SMS preference

**Request**

```http
POST /bright_parrot/notifications
Content-Type: application/json

{
  "preference": {
    "channel": "sms",
    "phoneNumber": "+1234567890"
  }
}
```

**Response** `201`

```json
{
  "phoneNumber": "+1234567890",
  "channel": "sms"
}
```

:::

::: details List preferences

**Request**

```http
GET /bright_parrot/notifications
```

**Response** `500`

```json
{
  "status": 500,
  "error": "Internal Server Error"
}
```

:::

## Generated Output

::: details Introspection

<<< @/playground/public/bright-parrot/introspection.json

:::

::: details TypeScript

<<< @/playground/public/bright-parrot/typescript.ts

:::

::: details Zod

<<< @/playground/public/bright-parrot/zod.ts

:::

::: details OpenAPI

<<< @/playground/public/bright-parrot/openapi.yml

:::