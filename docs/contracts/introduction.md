# Contracts

Contracts are the heart of Apiwork. They define the exact shape your API data must have - what types are allowed, what's required, what's optional. Every input is validated against a contract before reaching your controller. Every output is validated before being sent to the client (in development).

**But here's the key:** you almost never write contracts manually.

Instead, Apiwork generates them automatically from [Schemas](../schemas/introduction.md), which in turn read type information directly from your Rails models and database. You define what attributes to expose, and Apiwork figures out the rest - types from database columns, required fields from `null: false` constraints, defaults from the database, enums from Rails enums.

> **In 90%+ of cases, you never create a contract file.** Just define a schema, and Apiwork generates complete contracts for all CRUD actions automatically.

Only create an explicit contract when you need:
- Custom actions beyond CRUD (like `publish`, `archive`, `bulk_create`)
- Override auto-generated validation with custom logic
- Complex input transformations

See [Schema-First Design](../schemas/schema-first-design.md) for the recommended workflow.

---

## The Contract DSL: Describing shapes

At its core, the contract DSL is a language for describing object shapes. It answers questions like:

- What fields exist?
- What type is each field? (string, integer, literal value, union of types?)
- Is it required or optional?
- Does it have a default value?
- Is it restricted to specific values (enums)?
- Does it have nested structure (objects, arrays)?

Here's a simple contract written by hand:

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  action :create do
    input do
      param :title, type: :string, required: true
      param :body, type: :string, required: true
      param :published, type: :boolean, default: false
    end

    output do
      param :id, type: :integer, required: true
      param :title, type: :string, required: true
      param :body, type: :string, required: true
      param :published, type: :boolean, required: true
      param :created_at, type: :datetime, required: true
    end
  end
end
```

This contract matches your controller action:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def create
    post = Post.create(action_params)
    respond_with post
  end
end
```

This contract validates:

- **Input** - Request params must match the input definition (runtime validation)
- **Output** - Response data must match the output definition (development only)

If validation fails, Apiwork returns a 422 error with details.

**But writing this by hand is tedious and error-prone.** And that's not how you use Apiwork.

## The real workflow: Schemas → Contracts → Schemas

In practice, you almost never write contracts manually. Here's how it actually works:

### 1. Define a schema (what to expose)

```ruby
# app/schemas/api/v1/post_schema.rb
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post  # Points to your Rails model

  attribute :id, filterable: true, sortable: true
  attribute :title, writable: true, filterable: true, sortable: true
  attribute :body, writable: true
  attribute :published, writable: true
end
```

That's it. No contract file needed.

### 2. Apiwork reads your database schema

```ruby
# Your database migration
create_table :posts do |t|
  t.string :title, null: false          # → type: :string, required: true
  t.text :body, null: false             # → type: :string, required: true
  t.boolean :published, default: false  # → type: :boolean, default: false
  t.timestamps                          # → type: :datetime
end
```

Apiwork reads:
- **Column types** → Contract types (`:string`, `:integer`, `:boolean`, `:datetime`)
- **`null: false`** → `required: true` in contracts
- **`default: value`** → `default: value` in contracts
- **Rails enums** → Contract enums with allowed values

### 3. Contracts are auto-generated

Apiwork generates complete contracts for **all 5 CRUD actions** (index, show, create, update, destroy) - with full filtering, sorting, pagination, eager loading, and discriminated union responses.

**Query params are generated from schema flags:**
- `filterable: true` → Generates filter params with type-specific operators
- `sortable: true` → Generates sort params with asc/desc options
- `serializable: true` → Generates include params for eager loading
- Pagination params always included for index routes

**You write zero contract code.** Apiwork creates it all from your schema + database.

### 4. Generated schemas for frontends

The auto-generated contracts are then serialized to OpenAPI, TypeScript, Zod, etc. for your frontend:

```bash
GET /api/v1/.schema/openapi
```

Returns the complete contract as an OpenAPI schema, ready for code generation.

**The complete flow:**
```
Database schema (null: false, default:, column types)
    ↓
Rails model (enums, associations, validations)
    ↓
Apiwork Schema (what to expose: writable, filterable, sortable)
    ↓
Contract (auto-generated: types, required, defaults, enums, filters)
    ↓
OpenAPI / TypeScript / Zod (for frontends)
```

**You define once (schema), validate everywhere (backend contracts + frontend types).**

---

## When you DO write contracts manually

You only create an explicit contract file when you need custom behavior:

```ruby
# app/contracts/api/v1/post_contract.rb (optional!)
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema  # Still auto-generates CRUD actions

  # Add custom action beyond CRUD
  action :publish do
    input { param :scheduled_at, type: :datetime, required: false }
  end

  # Override auto-generated create action
  action :create do
    input do
      param :title, type: :string, required: true
      param :slug, type: :string, required: true  # Custom validation
      param :body, type: :string, required: true
    end
  end
end
```

Even when you write a contract, you still reference the schema with `schema Api::V1::PostSchema`. This keeps CRUD actions auto-generated unless you explicitly override them.

### What gets auto-generated

From your schema:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id, filterable: true, sortable: true
  attribute :title, filterable: true, sortable: true, writable: true
  attribute :body, writable: true
  attribute :published, filterable: true, writable: true
  attribute :created_at, sortable: true
  attribute :updated_at, sortable: true
end
```

Apiwork generates **5 complete action contracts**. The index action gets special treatment with full query params (filter, sort, page, include) based on your schema flags.

If you were to write them manually, it would look like this:

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  # This is what schema Api::V1::PostSchema generates for you:

  action :index do
    input do
      # Filter params (from filterable: true)
      param :filter, type: :object, required: false do
        param :id, type: :union, required: false do
          variant :integer
          variant :object do
            param :equal, type: :integer
            param :not_equal, type: :integer
            param :greater_than, type: :integer
            param :less_than, type: :integer
            param :in, type: :array, of: :integer
            # ... more operators
          end
        end
        param :title, type: :union, required: false do
          variant :string
          variant :object do
            param :equal, type: :string
            param :contains, type: :string
            param :starts_with, type: :string
            param :in, type: :array, of: :string
            # ... more operators
          end
        end
        param :published, type: :union, required: false do
          variant :boolean
          variant :object do
            param :equal, type: :boolean
          end
        end
      end

      # Sort params (from sortable: true)
      param :sort, type: :union, required: false do
        variant :object do
          param :id, type: :string, enum: ['asc', 'desc']
          param :title, type: :string, enum: ['asc', 'desc']
          param :created_at, type: :string, enum: ['asc', 'desc']
          param :updated_at, type: :string, enum: ['asc', 'desc']
        end
        variant :array, of: :object do
          param :id, type: :string, enum: ['asc', 'desc'], required: false
          param :title, type: :string, enum: ['asc', 'desc'], required: false
          # ... other sortable fields
        end
      end

      # Pagination params
      param :page, type: :object, required: false do
        param :number, type: :integer, required: false
        param :size, type: :integer, required: false
      end
    end

    output do
      param :ok, type: :boolean, required: true
      param :posts, type: :array, required: true, of: :object do
        param :id, type: :integer, required: true
        param :title, type: :string, required: true
        param :body, type: :string, required: true
        param :published, type: :boolean, required: true
        param :created_at, type: :datetime, required: true
        param :updated_at, type: :datetime, required: true
      end
      param :meta, type: :object, required: true do
        param :page, type: :object, required: true do
          param :current, type: :integer, required: true
          param :next, type: :integer, required: false
          param :prev, type: :integer, required: false
          param :total, type: :integer, required: true
          param :items, type: :integer, required: true
        end
      end
    end
  end

  action :show do
    # No input (strict mode)

    output do
      param :ok, type: :boolean, required: true
      param :post, type: :object, required: true do
        param :id, type: :integer, required: true
        param :title, type: :string, required: true
        param :body, type: :string, required: true
        param :published, type: :boolean, required: true
        param :created_at, type: :datetime, required: true
        param :updated_at, type: :datetime, required: true
      end
    end
  end

  action :create do
    input do
      param :post, type: :object, required: true do
        # Based on writable: true + DB constraints
        param :title, type: :string, required: true      # null: false in DB
        param :body, type: :string, required: true       # null: false in DB
        param :published, type: :boolean, required: false # has default in DB
      end
    end

    output do
      param :ok, type: :boolean, required: true
      param :post, type: :object, required: true do
        param :id, type: :integer, required: true
        param :title, type: :string, required: true
        param :body, type: :string, required: true
        param :published, type: :boolean, required: true
        param :created_at, type: :datetime, required: true
        param :updated_at, type: :datetime, required: true
      end
    end
  end

  action :update do
    input do
      param :post, type: :object, required: true do
        # All writable fields become optional in updates
        param :title, type: :string, required: false
        param :body, type: :string, required: false
        param :published, type: :boolean, required: false
      end
    end

    output do
      param :ok, type: :boolean, required: true
      param :post, type: :object, required: true do
        param :id, type: :integer, required: true
        param :title, type: :string, required: true
        param :body, type: :string, required: true
        param :published, type: :boolean, required: true
        param :created_at, type: :datetime, required: true
        param :updated_at, type: :datetime, required: true
      end
    end
  end

  action :destroy do
    # No input

    output do
      param :ok, type: :boolean, required: true
    end
  end
end
```

**All of that from one line: `schema Api::V1::PostSchema`.**

That's why you rarely write contracts manually!

**Query params in detail:**
- Filter operators are type-specific (string gets `contains`, integers get `greater_than`, etc.)
- Both shorthand (`filter[title]=value`) and full syntax (`filter[title][contains]=value`) supported
- See [Querying](../querying/introduction.md) for complete documentation on how these query params work at runtime

### Auto-generated outputs are discriminated unions

You might notice `param :ok, type: :boolean, required: true` in every output. This isn't just a status flag - it's the discriminator for a type-safe union.

Auto-generated outputs are actually discriminated unions with two variants:

**Success variant** (`ok: true`):
```ruby
{
  ok: true,          # literal type
  post: { ... },     # the resource
  meta: { ... }      # optional metadata (pagination, etc.)
}
```

**Error variant** (`ok: false`):
```ruby
{
  ok: false,         # literal type
  errors: [...]      # array of error objects
}
```

When serialized for code generators, this becomes a proper discriminated union with `ok` as the discriminator field. The `ok` field in each variant is a [literal type](literal-types.md) - not just boolean, but exactly `true` or exactly `false`.

This means TypeScript clients can do type-safe branching:

```typescript
const response = await api.posts.create({ title: "Hello" });

if (response.ok) {
  // TypeScript knows: response.post exists here
  console.log(response.post.id);
} else {
  // TypeScript knows: response.errors exists here
  console.log(response.errors);
}
```

See [Discriminated Unions](discriminated-unions.md) for how this works and how to use it in your own contracts.

## How schemas drive contracts

Apiwork uses schema flags to generate contracts:

```ruby
attribute :title,
  filterable: true,  # → Appears in index filter params
  sortable: true,    # → Appears in index sort params
  writable: true     # → Appears in create/update inputs
```

Required fields come from your database:

```ruby
# Database migration
create_table :posts do |t|
  t.string :title, null: false  # → required in create
  t.text :body, null: false     # → required in create
  t.boolean :published, default: false  # → optional in create
end
```

Apiwork reads `null: false` and makes those fields `required: true` in the contract.

## Overriding auto-generated actions

Need custom validation? Just define the action explicitly:

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema  # Still auto-generates other actions

  # Override create with custom validation
  action :create do
    input do
      param :title, type: :string, required: true
      param :slug, type: :string, required: true
      param :body, type: :string, required: true
      param :published, type: :boolean, default: false
      param :tags, type: :array, of: :string  # Extra field not in schema
    end

    # Output still auto-generated from schema unless you override it too
  end
end
```

Other actions (show, index, update, destroy) still auto-generate.

## Custom actions

For actions beyond CRUD, define them manually:

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema  # CRUD actions auto-generated

  action :publish do
    # No input needed
    output do
      param :id, type: :integer, required: true
      param :published, type: :boolean, required: true
      param :published_at, type: :datetime, required: true
    end
  end

  action :bulk_create do
    input do
      param :posts, type: :array, required: true, of: :object do
        param :title, type: :string, required: true
        param :body, type: :string, required: true
      end
    end

    output do
      param :posts, type: :array, required: true, of: :object do
        param :id, type: :integer, required: true
        param :title, type: :string, required: true
      end
    end
  end
end
```

Your controller implements these actions:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def publish
    post = Post.find(params[:id])
    post.update(published: true, published_at: Time.current)
    respond_with post
  end

  def bulk_create
    posts = params[:posts].map { |attrs| Post.create(attrs) }
    respond_with posts, status: :created
  end
end
```

## Input and output

Every action can have:

**Input** - Validates request params:

```ruby
input do
  param :title, type: :string, required: true
  param :published, type: :boolean, default: false
end
```

**Output** - Validates response data:

```ruby
output do
  param :id, type: :integer, required: true
  param :title, type: :string, required: true
end
```

Both are optional. For example, `show` has no input validation, and some actions might not need output validation.

## Root keys

Input expects a root key matching the resource name:

```ruby
# Correct
POST /api/v1/posts
{
  "post": {
    "title": "My Post"
  }
}

# Wrong - missing root key
{
  "title": "My Post"
}
```

This is configured globally:

```ruby
# config/initializers/apiwork.rb
Apiwork.configure do |config|
  config.require_root_key = false  # Allow flat inputs globally
end
```

## Parameter options

Available options for `param`:

```ruby
param :title,
  type: :string,           # Type (required)
  required: true,          # Field must be present
  default: "Untitled",     # Default value if nil
  enum: ['draft', 'published'],  # Restrict to specific values
  nullable: false          # Explicitly reject null values
```

### Types

- `:string` - Text
- `:integer` - Whole numbers
- `:float` / `:decimal` - Decimals
- `:boolean` - true/false
- `:date` - ISO 8601 date
- `:datetime` - ISO 8601 datetime
- `:uuid` - UUID format
- `:literal` - Exact value matching (e.g., `type: :literal, value: 'archived'`)
- `:object` - JSON objects (use with block for nested params)
- `:array` - Arrays (use `of:` for item type)
- `:union` - Multiple possible types (optionally discriminated)

### Arrays

Use `of:` to specify item type:

```ruby
param :tags, type: :array, of: :string
param :items, type: :array, of: :object do
  param :id, type: :integer, required: true
  param :quantity, type: :integer, required: true
end
```

### Nested objects

Use a block for nested structure:

```ruby
param :address, type: :object, required: true do
  param :street, type: :string, required: true
  param :city, type: :string, required: true
  param :zip, type: :string, required: true
end
```

### Custom types

Define reusable types:

```ruby
class PostContract < Apiwork::Contract::Base
  schema PostSchema

  type :address do
    param :street, type: :string, required: true
    param :city, type: :string, required: true
    param :zip, type: :string, required: true
  end

  action :create do
    input do
      param :shipping_address, type: :address, required: true
      param :billing_address, type: :address, required: false
    end
  end
end
```

### Importing types from other contracts

When you need to reuse types or enums from other contracts, use `import`:

```ruby
class Api::V1::UserContract < Apiwork::Contract::Base
  type :address do
    param :street, type: :string, required: true
    param :city, type: :string, required: true
    param :country, type: :string, required: true
  end

  enum :status, %w[active inactive suspended]
end

class Api::V1::OrderContract < Apiwork::Contract::Base
  import Api::V1::UserContract, as: :user

  action :create do
    input do
      param :shipping_address, type: :user_address, required: true
      param :account_status, type: :string, enum: :user_status
    end
  end
end
```

**How it works:**
- Use `import ContractClass, as: :alias` to import types and enums from another contract
- Reference imported types with the alias prefix: `:user_address` references `:address` from `UserContract`
- Reference imported enums the same way: `:user_status` references `:status` from `UserContract`
- Works with both explicit contracts and auto-generated schema-based contracts
- Multiple imports are supported: `import UserContract, as: :user` and `import ProductContract, as: :product`

**Common use cases:**
- Sharing address types across User, Order, and Vendor contracts
- Reusing status enums across multiple resources
- Importing types from schema-generated contracts in custom contracts
- Building modular contracts with shared vocabularies

**Important:**
- Always use the Class constant, not a string: `import UserContract` not `import 'UserContract'`
- The alias must be a Symbol: `as: :user` not `as: 'user'`
- Circular imports are detected and prevented (A imports B, B imports C, C imports A would error)

### Union types

For fields that accept multiple types:

```ruby
param :metadata, type: :union do
  variant type: :object do
    param :key, type: :string
    param :value, type: :string
  end
  variant type: :string
end
```

For type-safe unions where one field determines the variant, use discriminated unions:

```ruby
param :payment, type: :union, discriminator: :method do
  variant tag: 'card', type: :card_payment
  variant tag: 'bank', type: :bank_payment
end
```

See [Discriminated Unions](discriminated-unions.md) for details.

## Validation errors

Invalid input returns 422 with detailed errors:

```json
{
  "ok": false,
  "issues": [
    {
      "code": "field_missing",
      "path": "/post/title",
      "message": "is required"
    },
    {
      "code": "invalid_type",
      "path": "/post/published",
      "message": "must be boolean"
    }
  ]
}
```

Error codes:

- `field_missing` - Required field is missing
- `invalid_type` - Wrong type
- `invalid_value` - Value not in enum
- `field_unknown` - Extra field not in contract
- `array_too_large` - Array exceeds max_items
- `max_depth_exceeded` - Nested too deeply
- `value_null` - Null value when nullable: false

## What Apiwork does NOT support

These validation features are **not supported**:

- ❌ String length validation (`min_length`, `max_length`) - Validate in your model
- ❌ Pattern matching (`pattern: /regex/`) - Validate in your model
- ❌ Number ranges (`minimum`, `maximum`) - Validate in your model
- ❌ `description` on params - Not part of contract DSL
- ❌ `root_key false` per-action - Only global config

For complex validation beyond type checking and enums, use Active Record validations in your models.

## The big picture

**The Contract DSL is the heart of Apiwork** - it's a precise language for describing object shapes with rich type information including:

- Primitive types (string, integer, boolean, datetime, uuid, etc.)
- [Literal types](literal-types.md) (exact values like `status: "archived"`)
- [Enums](enums.md) (restricted value sets)
- [Discriminated unions](discriminated-unions.md) (type-safe polymorphism)
- [Custom types](params.md#custom-types) (reusable shapes)
- Nested objects and arrays
- Required/optional fields, defaults, nullable constraints

**But you rarely write contracts manually.** Instead:

1. **Write a Schema** - Declare what attributes to expose (`writable`, `filterable`, `sortable`)
2. **Apiwork reads Rails** - Types from database columns, constraints from migrations, enums from models
3. **Contracts auto-generate** - Complete CRUD actions with filtering, sorting, pagination
4. **Schemas export** - OpenAPI, TypeScript, Zod for frontend code generation

```
You write:        10 lines of schema code
Apiwork generates: Hundreds of lines of contract code
Frontend gets:     Fully typed API client with autocomplete and compile-time safety
```

**This is the point:** Define your data shape once (in your database and schema), validate everywhere (backend runtime + frontend compile-time).

The contract DSL is powerful when you need it (custom actions, complex validation, discriminated unions), but invisible when you don't (90% of the time).

## Next steps

- **[Params](./params.md)** - Complete guide to parameter types and options
- **[Literal Types](./literal-types.md)** - Exact value matching for type safety
- **[Discriminated Unions](./discriminated-unions.md)** - Type-safe unions with discriminators
- **[Enums](./enums.md)** - Restricting values to specific options
- **[Actions](./actions.md)** - Defining action contracts in detail
- **[Schemas](../schemas/introduction.md)** - How schemas drive auto-generation (recommended starting point!)
- **[Controllers](../controllers/introduction.md)** - Using contracts in controllers
