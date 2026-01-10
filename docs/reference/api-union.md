---
order: 8
prev: false
next: false
---

# API::Union

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/union.rb#L28)

Block context for defining reusable union types.

Accessed via `union :name do` in API or contract definitions.
Use [#variant](#variant) to define possible types.

**Example: Discriminated union**

```ruby
union :payment_method, discriminator: :type do
  variant tag: 'card', type: :object do
    param :last_four, type: :string
  end
  variant tag: 'bank', type: :object do
    param :account_number, type: :string
  end
end
```

**Example: Simple union**

```ruby
union :amount do
  variant type: :integer
  variant type: :decimal
end
```

## Instance Methods

### #variant

`#variant(enum: nil, of: nil, partial: nil, shape: nil, tag: nil, type:, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/union.rb#L55)

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

**See also**

- [API::Object](api-object)

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
