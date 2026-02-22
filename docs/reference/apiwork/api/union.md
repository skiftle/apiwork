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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/union.rb#L41)

Defines a union variant.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `partial` | `Boolean` | `false` | Whether partial. Partial variants include only the specified fields. |
| `tag` | `String`, `nil` | `nil` | The discriminator tag value. Required when union has a discriminator. |

</div>

**Returns**

`void`

**Yields** [Element](/reference/apiwork/api/element)

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
