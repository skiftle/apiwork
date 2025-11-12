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

Restricts values to specific options. See [Enums](enums.md) for complete documentation on inline enums, named enums, and built-in filter enums.

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

### Importing types from other contracts

Reuse types and enums defined in other contracts with `import`:

```ruby
# UserContract defines shared types
class Api::V1::UserContract < Apiwork::Contract::Base
  type :address do
    param :street, type: :string, required: true
    param :city, type: :string, required: true
    param :country, type: :string, required: true
  end

  enum :role, %w[admin user guest]
end

# OrderContract imports and uses them
class Api::V1::OrderContract < Apiwork::Contract::Base
  import Api::V1::UserContract, as: :user

  action :create do
    input do
      # Reference imported type with alias prefix
      param :shipping_address, type: :user_address, required: true
      param :billing_address, type: :user_address, required: false

      # Reference imported enum
      param :creator_role, type: :string, enum: :user_role
    end
  end
end
```

**Key points:**
- Import syntax: `import ContractClass, as: :alias`
- Reference imported types with alias prefix: `:user_address` refers to `:address` from UserContract
- Works with both types and enums
- Supports multiple imports: `import UserContract, as: :user` and `import ProductContract, as: :product`
- Works with auto-generated schema-based contracts
- Circular import chains are detected and prevented

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

## Troubleshooting

### Custom type not found

```ruby
# Problem: Type not defined at contract level
action :create do
  input do
    param :data, type: :my_type, required: true  # Error!
  end
end

# Solution: Define type at contract level
type :my_type do
  param :value, type: :string, required: true
end

action :create do
  input do
    param :data, type: :my_type, required: true  # Works!
  end
end
```

For complex validation beyond type checking and enums, use Active Record validations in your models.

## Next steps

- **[Literal Types](./literal-types.md)** - Exact value matching for type safety
- **[Discriminated Unions](./discriminated-unions.md)** - Type-safe unions with discriminators
- **[Enums](./enums.md)** - Complete guide to enums
- **[Actions](./actions.md)** - Defining action contracts
- **[Types](./types.md)** - Deep dive into custom and union types
- **[Introduction](./introduction.md)** - Back to contracts overview
