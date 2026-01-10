---
order: 21
prev: false
next: false
---

# Contract::Union

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union.rb#L22)

Block context for defining inline union types.

Accessed via `param :x, type: :union do` inside contract actions.
Use [#variant](#variant) to define possible types.

**Example: Discriminated union**

```ruby
param :payment_method, type: :union, discriminator: :type do
  variant tag: 'card', type: :object do
    param :last_four, type: :string
  end
  variant tag: 'bank', type: :object do
    param :account_number, type: :string
  end
end
```

## Instance Methods

### #variant

`#variant(enum: nil, of: nil, partial: nil, tag: nil, type:, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union.rb#L51)

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

**See also**

- [Contract::Object](contract-object)

**Example: Primitive variant**

```ruby
variant type: :decimal
```

**Example: Inline object variant**

```ruby
variant tag: 'card', type: :object do
  param :last_four, type: :string
end
```

---
