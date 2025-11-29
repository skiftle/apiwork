# Enums

Enums restrict a value to a predefined set.

## API-Level Enum

```ruby
Apiwork::API.draw '/api/v1' do
  enum :status, values: %w[draft published archived]
end
```

## Contract-Scoped Enum

```ruby
class PostContract < Apiwork::Contract::Base
  enum :priority, values: %i[low medium high critical]
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

Enums are reflected in:

- OpenAPI specs as `enum` constraints
- TypeScript as union types
- Zod as `z.enum()`

```typescript
// TypeScript
type Status = 'draft' | 'published' | 'archived';

// Zod
const StatusSchema = z.enum(['draft', 'published', 'archived']);
```
