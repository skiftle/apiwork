---
order: 4
---

# Types

Define types available to all contracts in your API.

## Global Types

```ruby
Apiwork::API.define '/api/v1' do
  object :address do
    string :street
    string :city
    string :country
  end

  union :payment_method, discriminator: :type do
    variant tag: 'card' do
      object do
        string :last_four
      end
    end
    variant tag: 'bank' do
      object do
        string :routing_number
      end
    end
  end

  fragment :timestamps do
    datetime :created_at
    datetime :updated_at
  end

  enum :status, values: %w[pending active archived]
end
```

Fragments are invisible in exports — they exist for [composition](../types/type-reuse.md#fragments) via `merge`.

Any contract in this API can reference these:

```ruby
class OrderContract < Apiwork::Contract::Base
  action :create do
    request do
      body do
        reference :shipping_address, to: :address
        string :status, enum: :status
      end
    end
  end
end
```

---

See [Types](../types/) for all available types and modifiers.

#### See also

- [API::Base reference](../../reference/api/base.md) — `object`, `union`, `enum`, `fragment` methods
- [Type Reuse](../types/type-reuse.md) — extends, merge, and fragments
