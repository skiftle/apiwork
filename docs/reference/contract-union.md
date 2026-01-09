---
order: 19
prev: false
next: false
---

# Contract::Union

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union.rb#L22)

Defines variants in a union type.

Used inside union blocks in contracts and custom adapters.
The [#variant](#variant) method defines each possible type the union can hold.

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

`#variant(type:, of: nil, enum: nil, tag: nil, partial: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union.rb#L74)

Defines a variant in a union type.

Each variant represents one possible shape the union value can take.
Use `tag` with discriminated unions to identify which variant applies.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type` | `Symbol` | the variant type (:string, :integer, :object, etc.) |
| `of` | `Symbol` | element type for :array variants |
| `enum` | `Array, Symbol` | allowed values for this variant |
| `tag` | `String` | discriminator value (required when union has discriminator) |
| `partial` | `Boolean` | allow partial object (omit required fields) |

**See also**

- [Contract::Param#param](contract-param#param)
- [Introspection::Param::Union](introspection-param-union)

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

**Example: Array variant**

```ruby
param :data, type: :union do
  variant type: :object do
    param :name, type: :string
  end
  variant type: :array, of: :string
end
```

---
