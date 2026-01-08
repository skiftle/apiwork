---
order: 18
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union.rb#L53)

Defines a variant in a union type.

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

**Example: Simple variants**

```ruby
variant type: :string
variant type: :integer
```

**Example: Discriminated union**

```ruby
variant type: :object, tag: 'card' do
  param :card_number, type: :string
end
```

---
