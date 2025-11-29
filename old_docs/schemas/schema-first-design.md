# Schema-First Design

Apiwork follows a **schema-first** philosophy where Schemas are the single source of truth for your API structure, validation, and documentation.

## Core Principle

**In 90% of cases, you only need a Schema.** Contracts are optional and only needed for customization beyond standard CRUD operations.

## The Schema is Enough

For standard CRUD operations (index, show, create, update, destroy), defining a schema is all you need:

```ruby
# app/schemas/api/v1/user_schema.rb
module Api
  module V1
    class UserSchema < Apiwork::Schema::Base
      model User

      attribute :id
      attribute :email, writable: true
      attribute :name, writable: true
      attribute :created_at
    end
  end
end
```

**That's it!** This automatically provides:

✓ **Input validation** for POST/PATCH requests
✓ **Output serialization** for GET responses
✓ **Query parameters** (filter, sort, include, page)
✓ **Type safety** via TypeScript generation
✓ **Auto-generated OpenAPI** documentation

You must create a minimal contract class for each schema. For basic CRUD operations, this is a simple one-liner:

```ruby
class PostContract < Apiwork::Contract::Base
  schema PostSchema
end
```

## How It Works

When a controller action is invoked, Apiwork resolves a contract in this order:

1. **Explicit contract** from routing metadata (`contract: CustomContract`)
2. **Named convention** (UsersController → UserContract)
3. Error if none found

### What Gets Auto-Generated

For each CRUD action, Apiwork generates appropriate contracts:

#### `:index` Action
```ruby
# Input: query parameters
input do
  param :filter, type: :object  # From filterable attributes
  param :sort, type: :array     # From sortable attributes
  param :include, type: :array  # From associations
  param :page, type: :object    # Pagination
end

# Output: collection with meta
output do
  param :users, type: :array do
    # All schema attributes
  end
  param :meta, type: :object
end
```

#### `:create` Action
```ruby
# Input: writable attributes with root key
input do
  param :user, type: :object, required: true do
    param :email, type: :string, required: true  # From writable: true
    param :name, type: :string, required: true   # From writable: true
  end
end

# Output: single resource
output do
  param :user, type: :object do
    # All schema attributes
  end
end
```

#### `:update` Action
Same as create, but attributes are not required by default.

#### `:show` & `:destroy`
Simple single-resource output, no input validation needed.

## When Explicit Contract Definitions Are Optional

You **don't need** explicit action definitions in your contract for:

- ✓ Standard CRUD actions (index, show, create, update, destroy)
- ✓ Basic filtering and sorting
- ✓ Simple nested associations (writable or with include policy)
- ✓ Standard query parameters

These are automatically derived from your schema. You only need to add explicit `action` blocks when you have custom actions beyond CRUD.

### Development Workflow

**Step 1:** Create schema and minimal contract
```ruby
class PostContract < Apiwork::Contract::Base
  schema PostSchema
end
```

**Step 2:** Test your API
```bash
curl -X POST /api/v1/users \
  -d '{"user": {"email": "test@example.com", "name": "Test User"}}'
```

Works automatically with validation from schema.

## When to Add a Contract

Create an explicit contract **only when** you need:

### 1. Custom Actions

```ruby
# Schema alone can't handle custom actions
class UserContract < Apiwork::Contract::Base
  schema UserSchema

  action :search do
    input do
      param :q, type: :string
      param :filters, type: :object do
        param :role, type: :string, enum: %w[admin user guest]
        param :active, type: :boolean
      end
    end
  end
end
```

### 2. Override Default Behavior

```ruby
class UserContract < Apiwork::Contract::Base
  schema UserSchema

  action :create do
    # Override auto-generated input
    reset_input!

    input do
      param :email, type: :string
      param :password, type: :string
      # Skip name - require only email/password on signup
    end
  end
end
```

### 3. Complex Input Transformations

```ruby
class OrderContract < Apiwork::Contract::Base
  schema OrderSchema

  action :bulk_create do
    input do
      param :orders, type: :array do
        param :product_id, type: :integer
        param :quantity, type: :integer
        param :customer, type: :object do
          param :name, type: :string
          param :email, type: :string
        end
      end
    end
  end
end
```

### 4. Additional Validation Logic

```ruby
class ReservationContract < Apiwork::Contract::Base
  schema ReservationSchema

  action :create do
    input do
      # Add custom validations beyond schema
      param :start_date, type: :date
      param :end_date, type: :date
      # Note: Cross-field validation (end > start)
      # should still be in model validations
    end
  end
end
```

## Migration Guide

### Before (Required Contracts)

```ruby
# Had to create contract even for simple CRUD
class UserSchema < Schema::Base
  model User
  attribute :email, writable: true
end

class UserContract < Contract::Base  # ← Required, even if minimal
  schema UserSchema
end
```

### After (Schema-First)

```ruby
# Just the schema
class UserSchema < Schema::Base
  model User
  attribute :email, writable: true
end

# Contract auto-generated! ✨
# Only create explicit contract if you need customization
```

## Best Practices

### 1. Start with Schema Only

Always begin with just a schema. Add a contract later if needed:

```ruby
# Start here (90% of cases)
class PostSchema < Schema::Base
  model Post
  attribute :title, writable: true
  attribute :body, writable: true
end

# Add contract only if needed (10% of cases)
class PostContract < Contract::Base
  schema PostSchema

  action :publish do
    # Custom action
  end
end
```

### 2. Schema is Source of Truth

Define data structure in schema, not contract:

**Good:**
```ruby
# Schema defines the data
class UserSchema < Schema::Base
  attribute :email, writable: true, required: true
  attribute :name, writable: true, required: true
end

# Minimal contract for CRUD
class UserContract < Apiwork::Contract::Base
  schema UserSchema
end
```

**Bad:**
```ruby
# Don't define structure in contract
class UserContract < Contract::Base
  action :create do
    input do
      param :email, type: :string, required: true
      param :name, type: :string, required: true
    end
  end
end
```

### 3. Explicit Contracts for Custom Logic

Use contracts to **add** behavior, not duplicate schema:

```ruby
class UserContract < Contract::Base
  schema UserSchema  # ← Inherits standard CRUD

  # Add custom actions
  action :verify_email do
    input { param :token, type: :string }
  end

  action :reset_password do
    input { param :token, type: :string }
    input { param :password, type: :string }
  end
end
```

### 4. Override Sparingly

Only override auto-generated actions when truly necessary:

```ruby
class UserContract < Contract::Base
  schema UserSchema

  # Override only if default doesn't work
  action :create do
    reset_input!  # Opt out of auto-generation
    input do
      # Custom input structure
    end
  end

  # Other actions still use auto-generated contracts
end
```

## Benefits of Schema-First

### Less Boilerplate

**Before:** ~2 files per resource (schema + contract)
**After:** 1 file per resource (schema only)

### Single Source of Truth

Schema defines:
- Database structure (via model)
- API input/output (auto-derived)
- TypeScript types (generated)
- OpenAPI docs (generated)

### Faster Development

No need to write/maintain contracts for standard CRUD operations.

### Clearer Intent

Explicit contracts signal "this has custom behavior" to other developers.

## Examples

### Simple Resource (No Contract)

```ruby
# app/schemas/api/v1/tag_schema.rb
class Api::V1::TagSchema < Apiwork::Schema::Base
  model Tag

  attribute :id
  attribute :name, writable: true, sortable: true
end

# That's all! CRUD endpoints work automatically.
```

### Complex Resource (With Contract)

```ruby
# app/schemas/api/v1/post_schema.rb
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title, writable: true
  attribute :body, writable: true
  attribute :published, writable: true

  has_many :comments
end

# app/contracts/api/v1/post_contract.rb
class Api::V1::PostContract < Apiwork::Contract::Base
  schema PostSchema

  # Custom actions beyond CRUD
  action :publish do
    input { param :scheduled_at, type: :datetime, required: false }
  end

  action :search do
    input { param :q, type: :string }
  end

  action :bulk_update do
    input do
      param :post_ids, type: :array, of: :integer
      param :updates, type: :object do
        param :published, type: :boolean
      end
    end
  end
end
```

## Summary

**Schema-first design means:**
- Schemas are the primary building block (90% of the time, this is all you need)
- Contracts are optional customization (10% of the time, for special cases)
- Less boilerplate, faster development
- Single source of truth for API structure

**Remember:** Start with a schema. Add a contract only when you need custom behavior beyond standard CRUD.
