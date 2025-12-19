---
order: 68
prev: false
next: false
---

# UnionDefinition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union_definition.rb#L5)

## Instance Methods

### #contract_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union_definition.rb#L6)

Returns the value of attribute contract_class.

---

### #discriminator()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union_definition.rb#L6)

Returns the value of attribute discriminator.

---

### #initialize(contract_class, discriminator: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union_definition.rb#L10)

**Returns**

`UnionDefinition` — a new instance of UnionDefinition

---

### #serialize()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union_definition.rb#L65)

---

### #variant(type:, of: = nil, enum: = nil, tag: = nil, partial: = nil, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union_definition.rb#L43)

Defines a variant in a union type.

Each variant represents one possible shape the union can take.
For discriminated unions, each variant must have a unique tag.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type` | `Symbol` | variant type (:string, :integer, :object, :array, or custom type) |
| `of` | `Symbol` | element type for :array variants |
| `enum` | `Array` | allowed values for primitive variants |
| `tag` | `String, Symbol` | discriminator value (required for discriminated unions) |
| `partial` | `Boolean` | mark as partial variant |

**Example: Discriminated union**

```ruby
union :result, discriminator: :status do
  variant type: :object, tag: 'success' do
    param :data, type: :object
  end
  variant type: :object, tag: 'error' do
    param :message, type: :string
  end
end
```

**Example: Simple type union**

```ruby
union :id do
  variant type: :string
  variant type: :integer
end
```

---

### #variants()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/union_definition.rb#L6)

Returns the value of attribute variants.

---
