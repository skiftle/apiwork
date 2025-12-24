---
order: 3
---

# Params

Params define what data your API accepts. When a request comes in, Apiwork validates it against your param definitions and coerces types where possible.

## Basic Types

Apiwork supports all the common primitives:

```ruby
param :title, type: :string
param :count, type: :integer
param :price, type: :float
param :active, type: :boolean
param :birth_date, type: :date
param :created_at, type: :datetime
param :start_time, type: :time
param :id, type: :uuid
```

[Types](../type-system/types.md) has the full list with formatting options.

## Required, Optional & Nullable

Three options control field presence:

| Option           | Field omitted | Field is `null` | Use case         |
| ---------------- | ------------- | --------------- | ---------------- |
| (default)        | Error         | Error           | Required fields  |
| `optional: true` | OK            | Error           | Optional fields  |
| `nullable: true` | Error         | OK              | Clearable fields |
| Both             | OK            | OK              | Fully optional   |

```ruby
param :title, type: :string                                     # required
param :notes, type: :string, optional: true                     # can omit
param :deleted_at, type: :datetime, nullable: true              # can be null
param :metadata, type: :object, optional: true, nullable: true  # can omit or null
```

### Defaults

When a field is omitted, use a default value:

```ruby
param :status, type: :string, default: 'draft'
param :count, type: :integer, default: 0
param :tags, type: :array, default: []
```

When validation fails, Apiwork returns a [contract error](../errors/contract-issues.md) with codes like `field_missing` or `value_null`.

## Enums

Restrict a param to specific values:

```ruby
param :status, type: :string, enum: %w[draft published archived]
```

Or reference an enum you've defined at the API level:

```ruby
# In API definition
enum :post_status, values: %w[draft published archived]

# In contract
param :status, type: :string, enum: :post_status
```

::: tip Reusable enums
Define enums at the [API level](../api-definitions/configuration.md#global-types-and-enums) when multiple contracts share the same values. This keeps them in sync and generates a single TypeScript type.
:::

## Min & Max

Set boundaries on numeric values:

```ruby
param :age, type: :integer, min: 0, max: 150
param :price, type: :float, min: 0.01
```

Or string length:

```ruby
param :title, type: :string, min: 1, max: 255
```

Or array size:

```ruby
param :tags, type: :array, min: 1, max: 10
```

See [contract errors](../errors/contract-issues.md) for the validation error codes (`string_too_short`, `array_too_large`, etc.).

## Arrays

Arrays use `of:` to specify element type:

```ruby
param :tags, type: :array, of: :string
param :ids, type: :array, of: :integer
```

For arrays of objects, use a block:

```ruby
param :posts, type: :array do
  param :title, type: :string
  param :body, type: :string
end
```

## Nested Objects

Objects can nest up to 10 levels deep:

```ruby
param :post, type: :object do
  param :title, type: :string
  param :body, type: :string
  param :author, type: :object do
    param :name, type: :string
    param :email, type: :string
  end
end
```

Requests exceeding the depth limit receive a `max_depth_exceeded` error.

## Alias

When the API name differs from your internal name, use `as:`:

```ruby
param :lines_attributes, type: :string, as: :lines
```

Clients send `lines`, but your code receives `lines_attributes`.

## Custom Types

You can reference types defined at the API level:

```ruby
# In API definition
type :address do
  param :street, type: :string
  param :city, type: :string
end

# In contract
param :shipping_address, type: :address
```

[Type System](../type-system/introduction.md) covers custom types, enums, unions, and scoping.

## Type Generation

Your params automatically generate types for spec output. Here's an example:

```ruby
param :title, type: :string, min: 1, max: 255
param :count, type: :integer, min: 0, max: 100, optional: true
param :tags, type: :array, of: :string, optional: true
param :author, type: :object do
  param :name, type: :string
  param :email, type: :string, optional: true
end
```

### Introspection

```json
{
  "title": {
    "type": "string",
    "min": 1,
    "max": 255
  },
  "count": {
    "type": "integer",
    "optional": true,
    "min": 0,
    "max": 100
  },
  "tags": {
    "type": "array",
    "of": "string",
    "optional": true
  },
  "author": {
    "type": "object",
    "shape": {
      "name": {
        "type": "string"
      },
      "email": {
        "type": "string",
        "optional": true
      }
    }
  }
}
```

### TypeScript

```typescript
export interface CreatePostRequest {
  title: string;
  count?: number;
  tags?: string[];
  author: {
    name: string;
    email?: string;
  };
}
```

### Zod

```typescript
export const CreatePostRequestSchema = z.object({
  title: z.string().min(1).max(255),
  count: z.number().int().min(0).max(100).optional(),
  tags: z.array(z.string()).optional(),
  author: z.object({
    name: z.string(),
    email: z.string().optional(),
  }),
});
```
