# Params

Params define the structure and types of data in your contract's input and output definitions. This guide covers all param types, options, and advanced patterns.

## Basic params

```ruby
action :create do
  input do
    param :title, type: :string, required: true
    param :published, type: :boolean, required: false
    param :views, type: :integer, default: 0
  end
end
```

Every param has:

- **Name** - The param key (`:title`, `:published`)
- **Type** - The data type (`:string`, `:boolean`, `:integer`)
- **Options** - `required`, `default`, `enum`, etc.

## Primitive types

### String

```ruby
param :title, type: :string
```

### Integer

```ruby
param :count, type: :integer
```

### Float / Decimal

```ruby
param :rating, type: :float
param :price, type: :decimal
```

Both map to `number` in OpenAPI and Zod.

### Boolean

```ruby
param :active, type: :boolean
```

### UUID

```ruby
param :id, type: :uuid, required: true
```

Validates UUID format.

### Date / DateTime

```ruby
param :birth_date, type: :date
param :created_at, type: :datetime
```

Expects ISO 8601 format.

### Literal

```ruby
param :status, type: :literal, value: 'archived'
param :version, type: :literal, value: 1
param :ok, type: :literal, value: true
```

A literal type validates that a parameter must be exactly the specified value. See [Literal Types](literal-types.md) for details.

## Param options

### required

```ruby
param :title, type: :string, required: true   # Must be present
param :body, type: :string, required: false   # Optional (default)
```

### default

```ruby
param :status, type: :string, default: 'draft'
param :count, type: :integer, default: 0
```

Applied when param is missing or nil.

### enum

```ruby
param :status, type: :string, enum: ['draft', 'published', 'archived']
```

Restricts values to specific options. See [Enums](enums.md) for complete documentation on inline enums, named enums, scoped enums, and built-in filter enums.

### nullable

```ruby
param :title, type: :string, nullable: false  # Reject null explicitly
```

By default, params can be null unless `required: true`.

## Arrays

Use `of:` to specify item type:

```ruby
# Array of primitives
param :tags, type: :array, of: :string

# Array of objects
param :items, type: :array, of: :object do
  param :name, type: :string, required: true
  param :quantity, type: :integer, required: true
end
```

## Nested objects

Use a block to define nested structure:

```ruby
param :user, type: :object, required: true do
  param :name, type: :string, required: true
  param :email, type: :string, required: true
  param :address, type: :object, required: false do
    param :street, type: :string, required: true
    param :city, type: :string, required: true
  end
end
```

Nesting can be arbitrarily deep.

## Custom types

Define reusable types:

```ruby
class PostContract < Apiwork::Contract::Base
  schema PostSchema

  # Global custom type
  type :address do
    param :street, type: :string, required: true
    param :city, type: :string, required: true
    param :zip, type: :string, required: false
  end

  action :create do
    input do
      param :shipping_address, type: :address, required: true
      param :billing_address, type: :address, required: false
    end
  end
end
```

### Arrays of custom types

```ruby
type :item do
  param :name, type: :string, required: true
  param :quantity, type: :integer, required: true
end

action :create do
  input do
    param :items, type: :array, of: :item, required: true
  end
end
```

## Union types

For fields that accept multiple types:

```ruby
param :content, type: :union, required: true do
  variant type: :string
  variant type: :integer
  variant type: :boolean
end
```

### Union with custom types

```ruby
type :text_data do
  param :text, type: :string, required: true
end

type :number_data do
  param :number, type: :integer, required: true
end

action :create do
  input do
    param :data, type: :union, required: true do
      variant type: :text_data
      variant type: :number_data
    end
  end
end
```

### Discriminated unions

For type-safe unions where one field determines the variant:

```ruby
param :payment, type: :union, discriminator: :method do
  variant tag: 'card', type: :card_payment
  variant tag: 'bank', type: :bank_payment
end
```

See [Discriminated Unions](discriminated-unions.md) for complete documentation.

### Variant options

Variants support these options:

```ruby
# Basic variant with custom type
variant type: :custom_type

# Variant with inline shape
variant type: :object do
  param :field, type: :string
end

# Variant with array
variant type: :array, of: :item_type

# Variant with enum
variant type: :string, enum: ['value1', 'value2']

# Variant with tag (for discriminated unions)
variant tag: 'tag_value', type: :variant_type
```

Complete variant signature:
```ruby
variant type: :type_name, of: :item_type, enum: :enum_ref, tag: 'discriminator_value', &block
```

## Lexical scoping

Custom types follow lexical scoping like JavaScript:

### Global scope

```ruby
# Available everywhere
type :timestamp do
  param :value, type: :datetime, required: true
end

action :create do
  input do
    param :created, type: :timestamp, required: true
  end
end

action :update do
  input do
    param :updated, type: :timestamp, required: true
  end
end
```

### Action scope

```ruby
# Global type
type :metadata do
  param :version, type: :string, required: true
end

action :create do
  # Action-scoped type (shadows global)
  type :metadata do
    param :source, type: :string, required: true
    param :version, type: :integer, required: true
  end

  input do
    # Uses action-scoped :metadata (integer version)
    param :meta, type: :metadata, required: true
  end
end

action :update do
  input do
    # Uses global :metadata (string version)
    param :meta, type: :metadata, required: true
  end
end
```

### Input/Output scope

```ruby
action :transform do
  # Action-scoped type
  type :data do
    param :raw, type: :string, required: true
  end

  input do
    # Input-scoped type (shadows action scope)
    type :data do
      param :value, type: :string, required: true
      param :format, type: :string, required: true
    end

    # Uses input-scoped :data
    param :input_data, type: :data, required: true
  end

  output do
    # Output-scoped type (shadows action scope)
    type :data do
      param :processed, type: :string, required: true
      param :checksum, type: :string, required: true
    end

    # Uses output-scoped :data
    param :output_data, type: :data, required: true
  end
end
```

### Scope resolution order

Types are resolved in this order:

1. **Input/Output scope** (highest priority)
2. **Action scope**
3. **Root/Global scope** (lowest priority)

This matches JavaScript's lexical scoping with `let`.

## Schema generation

params are used to generate schemas for frontend:

### OpenAPI 3.1.x

```ruby
param :title, type: :string, required: true
param :tags, type: :array, of: :string
```

Generates:

```json
{
  "type": "object",
  "properties": {
    "title": { "type": "string" },
    "tags": {
      "type": "array",
      "items": { "type": "string" }
    }
  },
  "required": ["title"]
}
```

### TypeScript (Transport)

Generates TypeScript interface-compatible schemas with key transformation:

```ruby
param :user_name, type: :string, required: true
param :email_address, type: :string, required: false
```

With `key_transform: :camelize_lower`:

```json
{
  "type": "object",
  "properties": {
    "userName": { "type": "string", "optional": false },
    "emailAddress": { "type": "string", "optional": true }
  }
}
```

### Zod (TypeScript validation)

```ruby
param :name, type: :string, required: true
param :age, type: :integer, required: false
param :tags, type: :array, of: :string
```

Generates:

```typescript
z.object({
  name: z.string(),
  age: z.number().int().optional(),
  tags: z.array(z.string()),
});
```

See [Schema Generation](../schema-generation/introduction.md) for details on exposing these schemas via API endpoints.

## Advanced patterns

### Reusable pagination type

```ruby
type :pagination do
  param :page, type: :integer, required: false, default: 1
  param :per_page, type: :integer, required: false, default: 20
end

action :index do
  input do
    param :pagination, type: :pagination, required: false
  end
end

action :search do
  input do
    param :query, type: :string, required: true
    param :pagination, type: :pagination, required: false
  end
end
```

### Type aliases with scoping

```ruby
# Global UUID type
type :id do
  param :value, type: :uuid, required: true
end

action :special_create do
  # Override for specific action - use integer IDs instead
  type :id do
    param :value, type: :integer, required: true
  end

  input do
    param :id, type: :id, required: true  # Uses integer version
  end
end
```

### Complex nested structures

```ruby
type :location do
  param :lat, type: :float, required: true
  param :lng, type: :float, required: true
end

type :address do
  param :street, type: :string, required: true
  param :city, type: :string, required: true
  param :location, type: :location, required: false
end

action :create do
  input do
    param :addresses, type: :array, of: :address, required: true
  end
end
```

Generates nested structure: `addresses → address → location`.

### Union types with mixed scopes

```ruby
type :text_payload do
  param :text, type: :string, required: true
end

action :process do
  type :number_payload do
    param :number, type: :integer, required: true
  end

  input do
    type :bool_payload do
      param :flag, type: :boolean, required: true
    end

    param :data, type: :union, required: true do
      variant type: :text_payload    # Global scope
      variant type: :number_payload  # Action scope
      variant type: :bool_payload    # Input scope
    end
  end
end
```

All variants resolve from correct scope.

## Troubleshooting

### Custom type not found

```ruby
# Problem: Type not in scope
action :create do
  input do
    param :data, type: :my_type, required: true  # Error!
  end
end

# Solution: Define type in correct scope
type :my_type do
  param :value, type: :string, required: true
end

# Or define in action scope
action :create do
  type :my_type do
    param :value, type: :string, required: true
  end

  input do
    param :data, type: :my_type, required: true  # Works!
  end
end
```

### Shadowing confusion

```ruby
# Problem: Using wrong version of type
type :data do
  param :version, type: :string, required: true
end

action :create do
  type :data do
    param :version, type: :integer, required: true  # Shadows global!
  end

  input do
    param :info, type: :data, required: true  # Uses INTEGER version
  end
end

# Solution: Use different names or understand scoping
action :create do
  type :create_data do  # Unique name
    param :version, type: :integer, required: true
  end

  input do
    param :info, type: :create_data, required: true
    param :global_info, type: :data, required: true  # Global version
  end
end
```

For complex validation beyond type checking and enums, use Active Record validations in your models.

## Next steps

- **[Literal Types](./literal-types.md)** - Exact value matching for type safety
- **[Discriminated Unions](./discriminated-unions.md)** - Type-safe unions with discriminators
- **[Enums](./enums.md)** - Complete guide to enums and scoping
- **[Actions](./actions.md)** - Defining action contracts
- **[Types](./types.md)** - Deep dive into custom and union types
- **[Introduction](./introduction.md)** - Back to contracts overview
