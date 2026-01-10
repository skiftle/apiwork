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

**Example: Define a reusable address type**

```ruby
object :address do
  param :street, type: :string
  param :city, type: :string
end
```

**Example: Reference in contract**

```ruby
param :shipping, type: :address
```

## Instance Methods

### #param

`#param(name, type: nil, optional: false, as: nil, default: nil, deprecated: nil, description: nil, discriminator: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: nil, of: nil, required: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L63)

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

**Example: Required string parameter**

```ruby
param :title, type: :string
```

**Example: Optional with default**

```ruby
param :status, type: :string, optional: true, default: 'draft'
```

**Example: Array of objects**

```ruby
param :items, type: :array, of: :line_item
```

**Example: Inline object**

```ruby
param :metadata, type: :object do
  param :source, type: :string
end
```

---
