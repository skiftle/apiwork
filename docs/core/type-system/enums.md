---
order: 3
---

# Enums

Enums restrict a value to a predefined set.

## API-Level Enum

<!-- example: happy-zebra -->

<<< @/app/config/apis/happy_zebra.rb

<details>
<summary>Introspection</summary>

<<< @/examples/happy-zebra/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/examples/happy-zebra/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/examples/happy-zebra/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/examples/happy-zebra/openapi.yml

</details>

## Contract-Scoped Enum

<!-- example: lazy-cow -->

<<< @/app/app/contracts/lazy_cow/post_contract.rb

<details>
<summary>Introspection</summary>

<<< @/examples/lazy-cow/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/examples/lazy-cow/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/examples/lazy-cow/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/examples/lazy-cow/openapi.yml

</details>

## Using Enums

### In params

```ruby
param :status, type: :string, enum: :status
```

### Inline validation

Without defining a separate enum:

```ruby
param :status, type: :string, enum: %w[draft published archived]
```

## Enum Metadata

```ruby
enum :status,
     values: %w[draft published archived],
     description: 'Publication status',
     example: 'published',
     deprecated: false
```

## Generated Output

Enums are reflected in OpenAPI, TypeScript, and Zod.

### Introspection

```json
{
  "status": {
    "type": "enum",
    "values": ["draft", "published", "archived"],
    "description": "Publication status",
    "example": "published"
  }
}
```

### TypeScript

```typescript
type Status = "draft" | "published" | "archived";
```

### Zod

```typescript
const StatusSchema = z.enum(["draft", "published", "archived"]);
```
