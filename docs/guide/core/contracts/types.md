---
order: 3
---

# Types

Contracts can define reusable types that are referenced across actions. These types are scoped to the contract and automatically prefixed with the contract's identifier.

For the full type system — primitives, modifiers, and scoping — see [Types](../types/).

## Objects

An object defines a named structure:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  object :address do
    string :street
    string :city
    string :postal_code
    string :country
  end

  action :create do
    request do
      body do
        reference :billing_address, to: :address
        reference :shipping_address, to: :address
      end
    end
  end
end
```

The `:address` type is registered as `:invoice_address` in the API's type system. Within the contract, you reference it by its short name.

## Unions

A union defines a set of alternative shapes distinguished by a discriminator field:

```ruby
class PaymentContract < Apiwork::Contract::Base
  union :method, discriminator: :kind do
    variant tag: 'card' do
      object do
        string :last_four
        string :exp_month
        string :exp_year
      end
    end
    variant tag: 'bank' do
      object do
        string :routing_number
        string :account_number
      end
    end
  end

  action :create do
    request do
      body do
        reference :payment_method, to: :method
      end
    end
  end
end
```

The `kind` field determines which variant is validated against.

## Enums

An enum restricts a field to a fixed set of values:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  enum :status, values: %w[draft sent paid overdue]

  action :create do
    request do
      body do
        string :status, enum: :status
      end
    end
  end
end
```

Enums can also be declared inline without a named definition:

```ruby
string :status, enum: %w[draft sent paid overdue]
```

Named enums are preferable when the same set of values is used in multiple places or when you want them to appear as distinct types in exports.

## Fragments

A fragment defines a reusable group of fields that can be merged into objects. Unlike objects, fragments are invisible in exports — they exist purely for composition:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  fragment :timestamps do
    datetime :created_at
    datetime :updated_at
  end

  action :show do
    response do
      body do
        object :invoice do
          string :number
          merge :timestamps
        end
      end
    end
  end
end
```

The fields from `:timestamps` are inlined into the `:invoice` object. No separate type appears in your OpenAPI, TypeScript, or Zod exports.

## Metadata

All named types accept metadata for export generation:

```ruby
object :address, description: "A physical mailing address", deprecated: true do
  string :street
  string :city
end

enum :status, values: %w[draft sent paid], description: "Invoice lifecycle state"

union :payment_method, discriminator: :kind, description: "Accepted payment methods" do
  # ...
end
```

| Option | Purpose |
|--------|---------|
| `description` | Human-readable text in generated exports |
| `deprecated` | Marks the type as deprecated in exports |
| `example` | Example value shown in generated exports |

## Scoping

Types defined inside a contract are prefixed with the contract's identifier. The identifier is derived from the class name:

| Contract | Identifier | `:address` becomes |
|----------|------------|--------------------|
| `InvoiceContract` | `:invoice` | `:invoice_address` |
| `Api::V1::OrderContract` | `:order` | `:order_address` |

Override the identifier explicitly when needed:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  identifier :invoice_item
end
```

Types defined at the [API level](../api-definitions/types.md) are not prefixed.

#### See also

- [Types](../types/) — the full type system
- [Imports](./imports.md) — sharing types between contracts
