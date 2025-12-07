---
order: 8
---

# Custom Hash Responses

Using respond_with with plain hashes instead of ActiveRecord models

## API Definition

<small>`config/apis/lazy_cow.rb`</small>

<<< @/app/config/apis/lazy_cow.rb

## Contracts

<small>`app/contracts/lazy_cow/status_contract.rb`</small>

<<< @/app/app/contracts/lazy_cow/status_contract.rb

## Controllers

<small>`app/controllers/lazy_cow/statuses_controller.rb`</small>

<<< @/app/app/controllers/lazy_cow/statuses_controller.rb

---



## Request Examples

<details>
<summary>health</summary>

**Request**

```http
GET /lazy-cow/status/health
```

**Response** `200`

```json
{
  "status": "ok",
  "timestamp": "2025-12-07T09:46:47.434Z",
  "version": "1.0.0"
}
```

</details>

<details>
<summary>stats</summary>

**Request**

```http
GET /lazy-cow/status/stats
```

**Response** `200`

```json
{
  "users_count": 1234,
  "posts_count": 5678,
  "uptime_seconds": 86400
}
```

</details>

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/app/public/lazy-cow/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/app/public/lazy-cow/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/app/public/lazy-cow/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/app/public/lazy-cow/openapi.yml

</details>