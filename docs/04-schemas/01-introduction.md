# Schemas

Schemas define how data is serialized for API responses.

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :id
  attribute :title
  attribute :body
  attribute :created_at

  has_many :comments, schema: CommentSchema
end
```

## Naming Convention

Apiwork infers the schema from the contract name:

| Contract | Schema |
|----------|--------|
| `Api::V1::PostContract` | `Api::V1::PostSchema` |
| `Api::V1::CommentContract` | `Api::V1::CommentSchema` |

## Model Auto-Detection

Schemas auto-detect their model from the class name:

```ruby
class PostSchema < Apiwork::Schema::Base
  # Automatically connects to Post model
end
```

Explicit declaration:

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post
end
```

See [Auto-Discovery](./07-auto-discovery.md) for all auto-detection features.

## Root Key

Override the default root key:

```ruby
class PostSchema < Apiwork::Schema::Base
  root :article, :articles
end
```

Responses use `article` for single objects and `articles` for collections.

## Connecting to Contract

In the contract, use `schema!` to enable serialization:

```ruby
class PostContract < Apiwork::Contract::Base
  schema!  # Connects to PostSchema
end
```

## No Conditional Fields

Apiwork intentionally does not support conditional attributes:

```ruby
# ❌ NOT supported
attribute :email, if: :admin?
attribute :salary, unless: -> { guest? }
```

**Why?** Conditional fields break static analysis. Generated types cannot know whether a field will be present — it depends on runtime state. This makes TypeScript interfaces unreliable and API contracts unpredictable.

### Use Nullable Instead

Instead of conditionally hiding fields, always include them and return `null` when not applicable:

```ruby
class UserSchema < Apiwork::Schema::Base
  attribute :name
  attribute :email
  attribute :salary, type: :decimal, nullable: true  # null for non-admins

  def salary
    current_user.admin? ? model.salary : nil
  end
end
```

```typescript
// Generated type - predictable structure
interface User {
  name?: string;
  email?: string;
  salary?: number | null;  // Always present, may be null
}
```

### Benefits

| Approach | Type Safety | API Predictability | Client Complexity |
|----------|-------------|-------------------|-------------------|
| Conditional fields | ❌ Impossible | ❌ Unpredictable | High |
| Nullable fields | ✅ Full | ✅ Consistent | Low |

With nullable fields:
- Clients always know the response structure
- TypeScript types are accurate
- No runtime surprises about missing keys
- Explicit `null` communicates "not available" vs "not requested"

### Alternative: Separate Associations

For complex permission-based data, consider a separate association:

```ruby
class UserSchema < Apiwork::Schema::Base
  attribute :name
  attribute :email
  has_one :admin_details, schema: AdminDetailsSchema, include: :optional
end

class AdminDetailsSchema < Apiwork::Schema::Base
  attribute :salary
  attribute :permissions
end
```

Clients explicitly request admin details when needed:

```
GET /api/v1/users/1?include[admin_details]=true
```
