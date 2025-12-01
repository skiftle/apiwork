---
order: 5
---

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
  street: z.string().optional(),
});

export const PersonSchema = z.object({
  home_address: AddressSchema.optional(),
  name: z.string().optional(),
  work_address: AddressSchema.optional(),
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
  unit_price: z.number().optional(),
});
```

## Named vs Inline Types in Specs

When you define a custom type or enum, it becomes a **named type** in your generated specs. This affects how the type appears in OpenAPI, TypeScript, and Zod output.

### The Difference

Consider two ways to define the same data. These examples use two playground APIs:

- [grumpy-panda](../../examples/grumpy-panda/openapi.yml) uses inline types
- [friendly-tiger](../../examples/friendly-tiger/openapi.yml) uses named types

<!-- example: grumpy-panda -->

**Inline type** — the address is defined directly in the action:

<<< @/app/app/contracts/grumpy_panda/order_contract.rb

<details>
<summary>Introspection</summary>

<<< @/examples/grumpy-panda/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/examples/grumpy-panda/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/examples/grumpy-panda/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/examples/grumpy-panda/openapi.yml

</details>

<!-- example: friendly-tiger -->

**Named type** — the address is a reusable type referenced by name:

<<< @/app/app/contracts/friendly_tiger/order_contract.rb

::: info Generated Artifacts

<details>
  <summary>Introspection</summary>

<<< @/examples/friendly-tiger/introspection.json

</details>

<details>
  <summary>TypeScript</summary>

<<< @/examples/friendly-tiger/typescript.ts

</details>

<details>
  <summary>Zod</summary>

<<< @/examples/friendly-tiger/zod.ts

</details>

<details>
  <summary>OpenAPI</summary>

<<< @/examples/friendly-tiger/openapi.yml

</details>

:::

Both options work identically at runtime. The difference is in the generated specs — expand the OpenAPI details above to compare how inline types embed the definition directly while named types create `$ref` references to `components/schemas`.

Note: Types defined inside a contract are prefixed with the resource name (`order_address` instead of `address`).

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

Named enums are expanded inline in OpenAPI. The friendly-tiger example above includes an `enum :priority` — expand its OpenAPI output to see how enum values are inlined.

### Introspection

Named types appear in the `types` and `enums` sections of introspection output, making them discoverable by tooling and client generators. Expand the Introspection details above to see how types and enums are structured.
