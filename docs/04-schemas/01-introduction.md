# Schemas

A schema is the bridge between your model, your contract, and the behavior of the endpoint.

It describes:

- Which attributes and relations are exposed
- How data is shaped when rendered
- The metadata that powers filtering, sorting, pagination and nested operations

If you've used Active Model Serializers, the DSL will feel familiar. But schemas in Apiwork go further: they don't just describe how to serialize a record — they describe how the API can query and interact with it.

## Why Schemas?

Contracts alone can take you far. But you're still hand-describing structures that already exist in your models.

Schemas change that. They map ActiveRecord models directly into Apiwork's metadata — column types, enums, associations, constraints. Instead of repeating what Rails already knows, Apiwork builds on it.

Contracts give you control. Schemas give you leverage.

## Basic Example

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  attribute :id
  attribute :number
  attribute :issued_on
  attribute :created_at

  has_many :lines
  belongs_to :customer
end
```

This tells Apiwork that:

- `id`, `number`, `issued_on`, `created_at` are scalar attributes on `Invoice`
- `lines` is a `has_many` relation that can be included
- `customer` is a `belongs_to` relation that can be included

## Model Inference

Every schema is backed by a model. By default, Apiwork infers the model from the schema's class name:

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  # Expects Invoice model
end
```

This works even when namespaced:

```ruby
module Api::V1
  class InvoiceSchema < Apiwork::Schema::Base
    # Still maps to Invoice model
  end
end
```

Override explicitly when needed:

```ruby
class AuthorSchema < Apiwork::Schema::Base
  model User
end
```

See [Inference](./07-inference.md) for complete details.

## Connecting to Contract

Use `schema!` to connect a contract to its schema:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!  # Connects to InvoiceSchema
end
```

With `schema!`, Apiwork auto-generates request bodies, response shapes, filter types, sort options and includes — all from the schema definition.

## Schemas as Behavior Hints

Beyond describing what to render, schemas act as behavior hints for the API layer. The same definitions that say "this field is exposed" also decide:

- Which fields are safe to filter on
- Which attributes can be sorted by
- Which relations can be eagerly loaded
- How nested writes should be handled

You describe your domain once — in a schema aligned with your model — and Apiwork uses that for both serialization and API behavior.

## Root Key

Override the default root key:

```ruby
class PostSchema < Apiwork::Schema::Base
  root :article, :articles
end
```

Responses use `article` for single objects and `articles` for collections.

## No Conditional Fields

Apiwork intentionally does not support conditional attributes:

```ruby
# ❌ NOT supported
attribute :email, if: :admin?
attribute :salary, unless: -> { guest? }
```

**Why?** Conditional fields break static analysis. Generated types cannot know whether a field will be present — it depends on runtime state. This makes TypeScript interfaces unreliable and API contracts unpredictable.

### Exception: Optional Associations

Associations with `include: :optional` are the one exception — but for a fundamentally different reason. Optional includes are **client-controlled**, not runtime-conditional:

```ruby
has_many :comments, include: :optional  # ✅ Client decides
attribute :salary, if: :admin?          # ❌ Server decides at runtime
```

| Aspect | `include: :optional` | Conditional fields |
|--------|---------------------|-------------------|
| Who controls | Client (query param) | Server (runtime state) |
| Predictable | Yes — client knows what they requested | No — depends on hidden logic |
| Type safety | Yes — types reflect optionality | No — impossible to type |

With optional includes, the client explicitly requests `?include[comments]=true`. They know whether they asked for comments or not. The generated types correctly mark the field as optional (`comments?: Comment[]`), and the client handles both cases.

Conditional fields based on server state (`if: :admin?`) are fundamentally different — the client has no way to know whether they'll receive the field.

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
