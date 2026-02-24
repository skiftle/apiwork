---
order: 4
---

# Objects

Objects are named structures that can be referenced by name.

## Defining an Object

```ruby
object :address do
  string :street
  string :city
  string :postal_code
  string :country_code
end
```

## Using It

Objects are referenced by name:

```ruby
reference :address
reference :billing_address, to: :address
```

Arrays work too:

```ruby
array :addresses do
  reference :address
end
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
  city: string;
  countryCode: string;
  postalCode: string;
  street: string;
}
```

### Zod

```typescript
export const AddressSchema = z.object({
  city: z.string(),
  countryCode: z.string(),
  postalCode: z.string(),
  street: z.string(),
});
```

### OpenAPI

```yaml
Address:
  type: object
  required:
    - street
    - city
    - postalCode
    - countryCode
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

Metadata adds documentation:

```ruby
object :address,
       description: 'Physical address',
       example: { street: '123 Main St', city: 'New York' } do
  string :street
  string :city
end
```

## Nested Objects

Objects can reference other objects:

```ruby
object :address do
  string :street
  string :city
end

object :person do
  string :name
  reference :home_address, to: :address
  reference :work_address, to: :address
end
```

## Recursive Objects

Objects can reference themselves. This is useful for tree structures or nested filters.

```ruby
object :category do
  string :name
  array :children do
    reference :category
  end
end
```

Apiwork detects self-references automatically. No special syntax is needed.

### Generated Output

In Zod, recursive types use `z.lazy()` to avoid infinite loops:

```typescript
export const CategoryRepresentation: z.ZodType<Category> = z.lazy(() =>
  z.object({
    name: z.string(),
    children: z.array(CategoryRepresentation),
  })
);
```

TypeScript interfaces handle recursion naturally:

```typescript
export interface Category {
  name: string;
  children: Category[];
}
```

OpenAPI uses `$ref`:

```yaml
Category:
  type: object
  required:
    - name
    - children
  properties:
    name:
      type: string
    children:
      type: array
      items:
        $ref: "#/components/schemas/Category"
```

## Contract-Scoped Objects

Objects inside a contract get prefixed with the contract name:

```ruby
class OrderContract < Apiwork::Contract::Base
  object :line_item do
    integer :product_id
    integer :quantity
  end
end
```

This becomes `OrderLineItem` in TypeScript, `order_line_item` in exports.

## Named vs Inline

An object can be defined once and reference it, or define it inline where you use it.

**Inline** — defined directly in the action:

```ruby
class OrderContract < Apiwork::Contract::Base
  action :show do
    response do
      body do
        object :order do
          integer :id
          decimal :total
        end
      end
    end
  end
end
```

**Named** — defined once, referenced by name:

```ruby
class OrderContract < Apiwork::Contract::Base
  object :order do
    integer :id
    decimal :total
  end

  action :show do
    response do
      body { reference :order }
    end
  end
end
```

Both work the same at runtime. The difference is in the exports:

- Inline objects embed the definition directly
- Named objects create `$ref` references to `components/schemas`

## When to Use Named Objects

**Use named objects when:**

- The shape appears in multiple places
- You want it in OpenAPI's `components/schemas`
- You want a dedicated TypeScript interface
- It represents a domain concept (Address, Money, etc.)

**Use inline objects when:**

- It's unique to one endpoint
- You don't need to reference it elsewhere
- It's a simple, one-off shape

#### See also

- [Contract::Base reference](../../reference/contract/base.md) — `object` method
