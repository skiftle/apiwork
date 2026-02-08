---
order: 10
prev: false
next: false
---

# Union

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/union.rb#L41)

Block context for defining reusable union types.

Accessed via `union :name do` in API or contract definitions.
Use [#variant](#variant) to define possible types.

**Example: instance_eval style**

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

**Example: yield style**

```ruby
union :payment_method, discriminator: :type do |union|
  union.variant tag: 'card' do |variant|
    variant.object do |object|
      object.string :last_four
    end
  end
  union.variant tag: 'bank' do |variant|
    variant.object do |object|
      object.string :account_number
    end
  end
end
```

## Instance Methods

### #variant

`#variant(deprecated: false, description: nil, partial: false, tag: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/union.rb#L37)

Defines a union variant.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `deprecated` | `Boolean` | (default: false) |
| `description` | `String, nil` | documentation description |
| `partial` | `Boolean` | (default: false) |
| `tag` | `String, nil` | discriminator tag value (required when union has discriminator) |

**Returns**

`void`

**Yields** [Element](/reference/api/element)

**Example: instance_eval style**

```ruby
variant tag: 'card' do
  object do
    string :last_four
  end
end
```

**Example: yield style**

```ruby
variant tag: 'card' do |variant|
  variant.object do |object|
    object.string :last_four
  end
end
```

---
