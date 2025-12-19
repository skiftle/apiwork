---
order: 5
---

# Custom Types

Define reusable object structures once, use them everywhere.

## Defining a Type

```ruby
Apiwork::API.define '/api/v1' do
  type :address do
    param :street, type: :string
    param :city, type: :string
    param :postal_code, type: :string
    param :country, type: :string
  end
end
```

## Using It

Reference by name:

```ruby
param :shipping_address, type: :address
param :billing_address, type: :address
```

Arrays work too:

```ruby
param :addresses, type: :array, of: :address
```

## Generated Output

The same type definition produces:

**TypeScript:**
```typescript
export interface Address {
  city?: string;
  country?: string;
  postalCode?: string;
  street?: string;
}
```

**Zod:**
```typescript
export const AddressSchema = z.object({
  city: z.string().optional(),
  country: z.string().optional(),
  postalCode: z.string().optional(),
  street: z.string().optional(),
});
```

## Metadata

Add documentation:

```ruby
type :address,
     description: 'Physical address',
     example: { street: '123 Main St', city: 'New York' } do
  param :street, type: :string
  param :city, type: :string
end
```

## Nested Types

Types can reference other types:

```ruby
type :address do
  param :street, type: :string
  param :city, type: :string
end

type :person do
  param :name, type: :string
  param :home_address, type: :address
  param :work_address, type: :address
end
```

## Contract-Scoped Types

Types inside a contract get prefixed with the contract name:

```ruby
class OrderContract < Apiwork::Contract::Base
  type :line_item do
    param :product_id, type: :integer
    param :quantity, type: :integer
  end
end
```

This becomes `OrderLineItem` in TypeScript, `order_line_item` in specs.

## Named vs Inline

You can define a type once and reference it, or define it inline where you use it.

**Inline** — defined directly in the action:

```ruby
class OrderContract < Apiwork::Contract::Base
  action :show do
    response do
      body do
        param :order, type: :object do
          param :id, type: :integer
          param :total, type: :decimal
        end
      end
    end
  end
end
```

**Named** — defined once, referenced by name:

```ruby
class OrderContract < Apiwork::Contract::Base
  type :order do
    param :id, type: :integer
    param :total, type: :decimal
  end

  action :show do
    response do
      body { param :order, type: :order }
    end
  end
end
```

Both work the same at runtime. The difference is in the specs:
- Inline types embed the definition directly
- Named types create `$ref` references to `components/schemas`

## When to Use Named Types

**Use named types when:**
- The structure appears in multiple places
- You want it in OpenAPI's `components/schemas`
- You want a dedicated TypeScript interface
- It represents a domain concept (Address, Money, etc.)

**Use inline types when:**
- It's unique to one endpoint
- You don't need to reference it elsewhere
- It's a simple, one-off shape
