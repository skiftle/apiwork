---
order: 2
---

# Manual Contract

This example shows how to define a contract manually without schemas.

## API Definition

<small>`config/apis/funny_snake.rb`</small>

<<< @/app/config/apis/funny_snake.rb

## Contracts

<small>`app/contracts/funny_snake/invoice_contract.rb`</small>

<<< @/app/app/contracts/funny_snake/invoice_contract.rb

---

## Generated Output

<details>
<summary>Introspection</summary>

<<< @/generated/funny-snake/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/generated/funny-snake/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/generated/funny-snake/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/generated/funny-snake/openapi.yml

</details>
