# Enums

Enums restrict a value to a predefined set.

## API-Level Enum

<!-- example: happy-zebra -->

```ruby
Apiwork::API.draw '/api/v1' do
  enum :status, values: %w[draft published archived]
end
```

<details>
<summary>View generated output</summary>

- [Introspection](../examples/happy-zebra/introspection.json)
- [TypeScript](../examples/happy-zebra/typescript.ts)
- [Zod](../examples/happy-zebra/zod.ts)
- [OpenAPI](../examples/happy-zebra/openapi.yml)

</details>

## Contract-Scoped Enum

<!-- example: lazy-cow -->

```ruby
class PostContract < Apiwork::Contract::Base
  enum :priority, values: %i[low medium high critical]
end
```

<details>
<summary>View generated output</summary>

- [Introspection](../examples/lazy-cow/introspection.json)
- [TypeScript](../examples/lazy-cow/typescript.ts)
- [Zod](../examples/lazy-cow/zod.ts)
- [OpenAPI](../examples/lazy-cow/openapi.yml)

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
