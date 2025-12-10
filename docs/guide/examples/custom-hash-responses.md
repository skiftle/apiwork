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
<summary>Health check</summary>

**Request**

```http
GET /lazy_cow/status/health
```

**Response** `200`

```json
{
  "status": "ok",
  "timestamp": "2025-12-10T10:35:26.755Z",
  "version": "1.0.0"
}
```

</details>

<details>
<summary>System statistics</summary>

**Request**

```http
GET /lazy_cow/status/stats
```

**Response** `200`

```json
{
  "usersCount": 1234,
  "postsCount": 5678,
  "uptimeSeconds": 86400
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