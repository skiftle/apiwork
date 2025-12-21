---
order: 5
---

# Custom Types

Custom types are named object structures that can be referenced by name.

## Defining a Type

```ruby
type :address do
  param :street, type: :string
  param :city, type: :string
  param :postal_code, type: :string
  param :country_code, type: :string
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

### Introspection

```json
{
  "address": {
    "type": "object",
    "shape": {
      "street": {
        "type": "string"
      },
      "city": {
        "type": "string"
      },
      "postal_code": {
        "type": "string"
      },
      "country_code": {
        "type": "string"
      }
    }
  }
}
```

### TypeScript

```typescript
export interface Address {
  city?: string;
  countryCode?: string;
  postalCode?: string;
  street?: string;
}
```

### Zod

```typescript
export const AddressSchema = z.object({
  city: z.string().optional(),
  countryCode: z.string().optional(),
  postalCode: z.string().optional(),
  street: z.string().optional(),
});
```

### OpenAPI

```yaml
Address:
  type: object
  properties:
    street:
      type: string
    city:
      type: string
    postalCode:
      type: string
    countryCode:
      type: string
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

## Recursive Types

Types can reference themselves. This is useful for tree structures or nested filters.

```ruby
type :category do
  param :name, type: :string
  param :children, type: :array, of: :category
end
```

Apiwork detects self-references automatically. No special syntax is needed.

### Generated Output

In Zod, recursive types use `z.lazy()` to avoid infinite loops:

```typescript
export const CategorySchema: z.ZodType<Category> = z.lazy(() => z.object({
  name: z.string().optional(),
  children: z.array(CategorySchema).optional(),
}));
```

TypeScript interfaces handle recursion naturally:

```typescript
export interface Category {
  name?: string;
  children?: Category[];
}
```

OpenAPI uses `$ref`:

```yaml
Category:
  type: object
  properties:
    name:
      type: string
    children:
      type: array
      items:
        $ref: '#/components/schemas/Category'
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
