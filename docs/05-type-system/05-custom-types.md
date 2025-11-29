# Custom Types

Custom types are reusable object structures.

## Defining Types

```ruby
Apiwork::API.draw '/api/v1' do
  type :address do
    param :street, type: :string
    param :city, type: :string
    param :postal_code, type: :string
    param :country, type: :string
  end
end
```

## Generated Output

### Introspection

```json
{
  "address": {
    "type": "object",
    "shape": {
      "street": { "type": "string", "required": false },
      "city": { "type": "string", "required": false },
      "postal_code": { "type": "string", "required": false },
      "country": { "type": "string", "required": false }
    }
  }
}
```

### TypeScript

```typescript
export interface Address {
  city?: string;
  country?: string;
  postalCode?: string;
  street?: string;
}
```

### Zod

```typescript
export const AddressSchema = z.object({
  city: z.string().optional(),
  country: z.string().optional(),
  postalCode: z.string().optional(),
  street: z.string().optional(),
});
```

## Using Types

Reference by name:

```ruby
param :shipping_address, type: :address
param :billing_address, type: :address
```

## Type Metadata

```ruby
type :address,
     description: 'Physical address',
     example: { street: '123 Main St', city: 'New York' },
     format: 'postal-address',
     deprecated: false do
  param :street, type: :string
  param :city, type: :string
end
```

## Arrays of Custom Types

```ruby
param :addresses, type: :array, of: :address
```

```typescript
// TypeScript
addresses?: Address[];

// Zod
addresses: z.array(AddressSchema).optional()
```

## Nested Types

Types can reference other types:

```ruby
Apiwork::API.draw '/api/v1' do
  type :address do
    param :street, type: :string
    param :city, type: :string
  end

  type :person do
    param :name, type: :string
    param :home_address, type: :address
    param :work_address, type: :address
  end
end
```

```typescript
// TypeScript
export interface Address {
  city?: string;
  street?: string;
}

export interface Person {
  home_address?: Address;
  name?: string;
  work_address?: Address;
}

// Zod
export const AddressSchema = z.object({
  city: z.string().optional(),
  street: z.string().optional()
});

export const PersonSchema = z.object({
  home_address: AddressSchema.optional(),
  name: z.string().optional(),
  work_address: AddressSchema.optional()
});
```

## Contract-Scoped Types

Define types inside a contract:

```ruby
class OrderContract < Apiwork::Contract::Base
  type :line_item do
    param :product_id, type: :integer
    param :quantity, type: :integer
    param :unit_price, type: :float
  end

  action :create do
    request do
      body do
        param :items, type: :array, of: :line_item
      end
    end
  end
end
```

The type is scoped as `:order_line_item`.

```typescript
// TypeScript (note the prefixed name)
export interface OrderLineItem {
  product_id?: number;
  quantity?: number;
  unit_price?: number;
}

// Zod
export const OrderLineItemSchema = z.object({
  product_id: z.number().int().optional(),
  quantity: z.number().int().optional(),
  unit_price: z.number().optional()
});
```
