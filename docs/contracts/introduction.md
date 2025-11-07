# Contracts

> **Note:** Contracts are **optional** in Apiwork. In most cases (90%+), you only need a [Schema](../schemas/introduction.md). Apiwork automatically derives contracts from schemas for standard CRUD operations.
>
> Only create an explicit contract when you need:
>
> - Custom actions beyond CRUD
> - Override auto-generated validation
> - Complex input transformations
>
> See [Schema-First Design](../schemas/schema-first-design.md) for the recommended approach.

---

Contracts define and validate your API's inputs and outputs. What shape data must have, what's required, what types are allowed.

When you create a schema, Apiwork automatically generates a contract for all standard CRUD actions. You only need to create an explicit contract file when you want to customize this behavior.

## When you need a contract

Let's start with a simple manual contract:

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

The contract validates:

- **Input** - Request params must match input definition
- **Output** - Response data must match output definition

If validation fails, Apiwork returns a 400 error with details.

## Auto-generation from schemas

**In most cases, you don't need to create a contract file at all!**

Just create a schema, and Apiwork automatically generates contracts for all CRUD actions:

```ruby
# app/schemas/api/v1/post_schema.rb
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id, filterable: true, sortable: true
  attribute :title, writable: true
  attribute :body, writable: true
end

# No contract file needed! ✨
# Apiwork creates it automatically from the schema
```

**Only if you need custom behavior**, create an explicit contract:

```ruby
# app/contracts/api/v1/post_contract.rb (optional!)
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema

  # Add custom actions
  action :publish do
    input { param :scheduled_at, type: :datetime }
  end
end
```

### What this generates

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

Apiwork generates **5 complete action contracts**. If you were to write them manually, it would look like this:

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
- `:object` - JSON objects (use with block for nested params)
- `:array` - Arrays (use `of:` for item type)

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

### Union types

For fields that accept multiple types:

```ruby
param :metadata, type: :union do
  variant :object do
    param :key, type: :string
    param :value, type: :string
  end
  variant :string
end
```

## Validation errors

Invalid input returns 422 with detailed errors:

```json
{
  "ok": false,
  "errors": [
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

## Next steps

- **[Actions](./actions.md)** - Defining action contracts in detail
- **[Schemas](../schemas/introduction.md)** - How schemas drive auto-generation
- **[Controllers](../controllers/introduction.md)** - Using contracts in controllers
