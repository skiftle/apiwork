---
order: 1
---

# Schema-Driven Contract

This example shows how `schema!` generates a complete contract from schema definitions.

## API Definition

<small>`config/apis/eager_lion.rb`</small>

<<< @/app/config/apis/eager_lion.rb

## Models

<small>`app/models/eager_lion/customer.rb`</small>

<<< @/app/app/models/eager_lion/customer.rb

<small>`app/models/eager_lion/invoice.rb`</small>

<<< @/app/app/models/eager_lion/invoice.rb

<small>`app/models/eager_lion/line.rb`</small>

<<< @/app/app/models/eager_lion/line.rb

## Schemas

<small>`app/schemas/eager_lion/customer_schema.rb`</small>

<<< @/app/app/schemas/eager_lion/customer_schema.rb

<small>`app/schemas/eager_lion/invoice_schema.rb`</small>

<<< @/app/app/schemas/eager_lion/invoice_schema.rb

<small>`app/schemas/eager_lion/line_schema.rb`</small>

<<< @/app/app/schemas/eager_lion/line_schema.rb

## Contracts

<small>`app/contracts/eager_lion/invoice_contract.rb`</small>

<<< @/app/app/contracts/eager_lion/invoice_contract.rb

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/generated/eager-lion/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/generated/eager-lion/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/generated/eager-lion/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/generated/eager-lion/openapi.yml

</details>
