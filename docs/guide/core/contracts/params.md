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

## Required & Optional

Fields are required by default, matching TypeScript conventions.

```ruby
# Required (default)
param :title, type: :string

# Explicitly optional
param :notes, type: :string, optional: true

# Works the same in query blocks
query do
  param :id, type: :uuid                        # required
  param :page, type: :integer, optional: true   # optional
end
```

## Default Values

When a param is omitted, use a default:

```ruby
param :published, type: :boolean, default: false
param :status, type: :string, default: 'draft'
param :tags, type: :array, default: []
```

## Nullable

Sometimes you want to explicitly accept `null`:

```ruby
param :archived_at, type: :datetime, nullable: true
```

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

Objects can nest as deep as you need:

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

## Alias

When the API name differs from your internal name, use `as:`:

```ruby
param :userName, type: :string, as: :user_name
```

Clients send `userName`, but your code receives `user_name`.

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

Your params automatically generate types for spec output. Here's what they look like:

### Introspection

```json
{
  "title": {
    "type": "string"
  },
  "count": {
    "type": "integer",
    "optional": true
  },
  "tags": {
    "type": "array",
    "of": "string",
    "optional": true
  },
  "author": {
    "type": "object",
    "shape": {
      "name": { "type": "string" },
      "email": { "type": "string", "optional": true }
    }
  }
}
```

### TypeScript

```typescript
interface CreatePostRequest {
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
const CreatePostRequestSchema = z.object({
  title: z.string().min(1).max(255),
  count: z.number().int().min(0).max(100).optional(),
  tags: z.array(z.string()).optional(),
  author: z.object({
    name: z.string(),
    email: z.string().optional(),
  }),
});
```
