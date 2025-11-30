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

## Named vs Inline Types in Specs

When you define a custom type or enum, it becomes a **named type** in your generated specs. This affects how the type appears in OpenAPI, TypeScript, and Zod output.

### The Difference

Consider two ways to define the same data:

```ruby
# Option A: Inline (anonymous) type
action :create do
  request do
    body do
      param :address, type: :object do
        param :street, type: :string
        param :city, type: :string
      end
    end
  end
end

# Option B: Named type
type :address do
  param :street, type: :string
  param :city, type: :string
end

action :create do
  request do
    body do
      param :address, type: :address
    end
  end
end
```

Both options work identically at runtime. The difference is in the generated specs.

### OpenAPI Output

**Inline type** embeds the definition directly:

```yaml
paths:
  /orders:
    post:
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                address:
                  type: object          # Embedded here
                  properties:
                    street:
                      type: string
                    city:
                      type: string
```

**Named type** creates a reusable schema:

```yaml
paths:
  /orders:
    post:
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                address:
                  $ref: '#/components/schemas/Address'  # Reference

components:
  schemas:
    Address:                            # Defined once
      type: object
      properties:
        street:
          type: string
        city:
          type: string
```

### TypeScript Output

**Inline type:**

```typescript
export interface OrdersCreateRequest {
  address?: {
    street?: string;
    city?: string;
  };
}
```

**Named type:**

```typescript
export interface Address {
  street?: string;
  city?: string;
}

export interface OrdersCreateRequest {
  address?: Address;
}
```

### When to Use Named Types

Use named types when:

- **Reusability**: The same structure appears in multiple places
- **Documentation**: You want the type to appear in OpenAPI's `components/schemas`
- **Client code**: You want a dedicated TypeScript interface or Zod schema
- **Semantic meaning**: The type represents a domain concept (Address, Money, Coordinates)

Use inline types when:

- The structure is unique to one endpoint
- You don't need to reference it elsewhere
- It's a simple, one-off shape

### Enums Follow the Same Pattern

```ruby
# Named enum - appears in components/schemas
enum :status, values: %w[draft published archived]

action :update do
  request do
    body do
      param :status, type: :status  # References the enum
    end
  end
end
```

```yaml
# OpenAPI output
components:
  schemas:
    Status:
      type: string
      enum: [archived, draft, published]
```

### Introspection

Named types appear in the `types` section of introspection output:

```json
{
  "types": {
    "address": {
      "type": "object",
      "shape": {
        "street": { "type": "string" },
        "city": { "type": "string" }
      }
    }
  },
  "enums": {
    "status": {
      "values": ["archived", "draft", "published"]
    }
  }
}
```

This makes them discoverable by tooling and client generators.
