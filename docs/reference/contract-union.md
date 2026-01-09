---
order: 22
prev: false
next: false
---

# Contract::Union

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union.rb#L22)

Union shape builder with contract context.

Wraps [API::Union](api-union) and adds contract-specific functionality
like enum validation.

**Example: In a contract**

```ruby
param :payment, type: :union, discriminator: :type do
  variant type: :object, tag: 'card' do
    param :card_number, type: :string
  end
  variant type: :object, tag: 'bank' do
    param :account_number, type: :string
  end
end
```

## Instance Methods

### #variant

`#variant(enum: nil, of: nil, partial: nil, tag: nil, type:, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union.rb#L63)

Defines a variant in this union.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type` | `Symbol` | the variant type (:string, :integer, :object, etc.) |
| `of` | `Symbol` | element type for :array variants |
| `enum` | `Array, Symbol` | allowed values for this variant |
| `tag` | `String` | discriminator value (required when union has discriminator) |
| `partial` | `Boolean` | allow partial object (omit required fields) |

**Returns**

`void`

**Example: Simple union (string or integer)**

```ruby
param :value, type: :union do
  variant type: :string
  variant type: :integer
end
```

**Example: Discriminated union with object variants**

```ruby
param :payment, type: :union, discriminator: :type do
  variant type: :object, tag: 'card' do
    param :card_number, type: :string
    param :expiry, type: :string
  end
  variant type: :object, tag: 'bank' do
    param :account_number, type: :string
    param :routing_number, type: :string
  end
end
```

---
