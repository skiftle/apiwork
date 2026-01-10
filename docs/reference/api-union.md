---
order: 9
prev: false
next: false
---

# API::Union

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/union.rb#L33)

Block context for defining reusable union types.

Accessed via `union :name do` in API or contract definitions.
Use [#variant](#variant) to define possible types.

**Example: Discriminated union**

```ruby
union :payment_method, discriminator: :type do
  variant tag: 'card' do
    object do
      string :last_four
    end
  end
  variant tag: 'bank' do
    object do
      string :account_number
    end
  end
end
```

**Example: Simple union**

```ruby
union :amount do
  variant { integer }
  variant { decimal }
end
```

## Instance Methods

### #variant

`#variant(deprecated: nil, description: nil, partial: nil, tag: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/union.rb#L63)

Defines a variant within this union.

The block must define exactly one type using type methods.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | `String` | discriminator value (required when union has discriminator) |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `partial` | `Boolean` | mark variant shape as partial |

**Returns**

`void`

**See also**

- [API::Element](api-element)

**Example: Primitive variant**

```ruby
variant { decimal }
```

**Example: Object variant**

```ruby
variant tag: 'card' do
  object do
    string :last_four
  end
end
```

---
