---
order: 7
prev: false
next: false
---

# API::Object

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L21)

Block context for defining reusable object types.

Accessed via `object :name do` in API or contract definitions.
Use [#param](#param) to define fields.

**Example: Define a reusable type**

```ruby
object :item do
  param :description, type: :string
  param :amount, type: :decimal
end
```

**Example: Reference in contract**

```ruby
param :items, type: :array, of: :item
```

## Instance Methods

### #param

`#param(name, type: nil, optional: false, as: nil, default: nil, deprecated: nil, description: nil, discriminator: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: nil, of: nil, required: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L68)

Defines a parameter within this object.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | parameter name |
| `type` | `Symbol` | primitive type or reference to named object/union |
| `optional` | `Boolean` | whether the parameter can be omitted |
| `as` | `Symbol` | internal name transformation |
| `default` | `Object` | default value when omitted |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `discriminator` | `Symbol` | discriminator field for inline unions |
| `enum` | `Symbol, Array` | enum reference or inline values |
| `example` | `Object` | example value for documentation |
| `format` | `String` | format hint for documentation |
| `max` | `Numeric` | maximum value constraint |
| `min` | `Numeric` | minimum value constraint |
| `nullable` | `Boolean` | whether the value can be null |
| `of` | `Symbol` | element type for arrays |
| `value` | `Object` | literal value constraint |

**Returns**

`void`

**See also**

- [API::Object](api-object)
- [API::Union](api-union)

**Example: Basic param**

```ruby
param :amount, type: :decimal
```

**Example: Inline object**

```ruby
param :customer, type: :object do
  param :name, type: :string
end
```

**Example: Inline union**

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

---
