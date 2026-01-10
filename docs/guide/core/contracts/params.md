---
order: 3
---

# Params

Params define what data your API accepts. When a request comes in, Apiwork validates it against your param definitions and coerces types.

## Basic Types

Apiwork supports common primitives:

```ruby
string :title
integer :count
float :price
boolean :active
date :birth_date
datetime :created_at
time :start_time
uuid :id
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
string :title                                     # required
string :notes, optional: true                     # can omit
datetime :deleted_at, nullable: true              # can be null
object :metadata, optional: true, nullable: true  # can omit or null
```

### Defaults

When a field is omitted, use a default value:

```ruby
string :status, default: 'draft'
integer :count, default: 0
array :tags, default: []
```

When validation fails, Apiwork returns a [contract error](../errors/contract-issues.md) with codes like `field_missing` or `value_null`.

## Enums

Restrict a param to specific values:

```ruby
string :status, enum: %w[draft published archived]
```

Or reference an enum you've defined at the API level:

```ruby
# In API definition
enum :post_status, values: %w[draft published archived]

# In contract
string :status, enum: :post_status
```

::: tip Reusable enums
Define enums at the [API level](../api-definitions/configuration.md#global-types-and-enums) when multiple contracts share the same values. This keeps them in sync and generates a single TypeScript type.
:::

## Min & Max

Set boundaries on numeric values:

```ruby
integer :age, min: 0, max: 150
float :price, min: 0.01
```

Or string length:

```ruby
string :title, min: 1, max: 255
```

Or array size:

```ruby
array :tags, min: 1, max: 10
```

See [contract errors](../errors/contract-issues.md) for the validation error codes (`string_too_short`, `array_too_large`, etc.).

## Arrays

Arrays use a block to specify element type:

```ruby
array :tags do
  string
end

array :ids do
  integer
end
```

For arrays of objects:

```ruby
array :posts do
  object do
    string :title
    string :body
  end
end
```

## Nested Objects

Objects can nest up to 10 levels deep:

```ruby
object :post do
  string :title
  string :body
  object :author do
    string :name
    string :email
  end
end
```

Requests exceeding the depth limit receive a `depth_exceeded` error.

## Alias

When the API name differs from your internal name, use `as:`:

```ruby
object :lines_attributes, as: :lines
```

Clients send `lines`, but your code receives `lines_attributes`.

## Named Objects

You can reference objects defined at the API level:

```ruby
# In API definition
object :address do
  string :street
  string :city
end

# In contract
reference :shipping_address, to: :address
```

[Type System](../type-system/introduction.md) covers objects, unions, enums, and scoping.

## Type Generation

Your params automatically generate types for export output:

```ruby
string :title, min: 1, max: 255
integer :count, min: 0, max: 100, optional: true
array :tags, optional: true do
  string
end
object :author do
  string :name
  string :email, optional: true
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

#### See also

- [Contract::Object reference](../../../reference/contract-object.md) — all param options
