---
order: 8
prev: false
next: false
---

# API::Union

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/union.rb#L27)

Defines a union type with multiple variants.

A union represents a value that can be one of several types.
With a discriminator, variants are distinguished by a tag field.
Without a discriminator, validation tries each variant in order.

**Example: Simple union (no discriminator)**

```ruby
union :filter_value do
  variant type: :string
  variant type: :integer
end
```

**Example: Discriminated union**

```ruby
union :payment, discriminator: :kind do
  variant tag: 'card', type: :object do
    param :last_four, type: :string
  end
  variant tag: 'bank', type: :object do
    param :account, type: :string
  end
end
```

## Instance Methods

### #variant

`#variant(enum: nil, of: nil, partial: nil, tag: nil, type:, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/union.rb#L58)

Defines a variant within this union.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type` | `Symbol` | variant type (primitive, :object, or reference) |
| `tag` | `String` | discriminator value for this variant (required when union has discriminator) |
| `enum` | `Symbol, Array` | enum constraint for the variant |
| `of` | `Symbol` | element type when variant is an array |
| `partial` | `Boolean` | make all fields optional in this variant |

**Returns**

`void`

**Example: Primitive variant**

```ruby
variant type: :string
```

**Example: Reference to named object**

```ruby
variant type: :card_details, tag: 'card'
```

**Example: Inline object variant**

```ruby
variant tag: 'bank', type: :object do
  param :account, type: :string
end
```

---
