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

  enum :status, values: %w[pending active archived]
end
```

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

See [Type System](../type-system/introduction.md) for all available types and modifiers.

#### See also

- [API::Base reference](../../../reference/api-base.md) — `object`, `union`, `enum` methods
