---
order: 999
---

# Curious Cat

Complete example with API, models, schemas, contracts, and controllers.

## API Definition

<small>`config/apis/curious_cat.rb`</small>

<<< @/playground/config/apis/curious_cat.rb

## Models

<small>`app/models/curious_cat/profile.rb`</small>

<<< @/playground/app/models/curious_cat/profile.rb

<details>
<summary>Database Table</summary>

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | string |  |  |
| name | string |  |  |
| email | string |  |  |
| settings | json | ✓ |  |
| tags | json | ✓ |  |
| addresses | json | ✓ |  |
| preferences | json | ✓ |  |
| metadata | json | ✓ |  |
| created_at | datetime |  |  |
| updated_at | datetime |  |  |

</details>

## Schemas

<small>`app/schemas/curious_cat/profile_schema.rb`</small>

<<< @/playground/app/schemas/curious_cat/profile_schema.rb

## Contracts

<small>`app/contracts/curious_cat/profile_contract.rb`</small>

<<< @/playground/app/contracts/curious_cat/profile_contract.rb

## Controllers

<small>`app/controllers/curious_cat/profiles_controller.rb`</small>

<<< @/playground/app/controllers/curious_cat/profiles_controller.rb

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/playground/public/curious-cat/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/playground/public/curious-cat/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/playground/public/curious-cat/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/playground/public/curious-cat/openapi.yml

</details>