---
order: 3
---

# Enums

Enums restrict a value to a predefined set.

## API-Level Enum

Define enums at the API level to share across contracts:

```ruby
Apiwork::API.define '/api/v1' do
  enum :status, values: %w[draft published archived]

  resources :posts
end
```

## Contract-Scoped Enum

Define enums inside a contract for local use:

```ruby
class PostContract < Apiwork::Contract::Base
  enum :status, values: %w[draft published archived]

  type :post do
    param :id, type: :uuid
    param :title, type: :string
    param :status, type: :status
  end
end
```

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

### Introspection

```json
{
  "status": {
    "values": ["draft", "published", "archived"],
    "description": "Publication status",
    "example": "published"
  }
}
```

### TypeScript

```typescript
export type Status = 'archived' | 'draft' | 'published';
```

### Zod

```typescript
export const StatusSchema = z.enum(['archived', 'draft', 'published']);
```

### OpenAPI

```yaml
Status:
  type: string
  enum: [draft, published, archived]
  description: Publication status
  example: published
```
