---
order: 8
prev: false
next: false
---

# API::Object

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L25)

Block context for defining reusable object types.

Accessed via `object :name do` in API or contract definitions.
Use type methods to define fields: [#string](#string), [#integer](#integer), [#decimal](#decimal),
[#boolean](#boolean), [#array](#array), [#object](#object), [#union](#union), [#reference](#reference).

**Example: Define a reusable type**

```ruby
object :item do
  string :description
  decimal :amount
end
```

**Example: Reference in contract**

```ruby
array :items do
  reference :item
end
```

## Instance Methods

### #array

`#array(name, deprecated: nil, description: nil, nullable: nil, optional: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L500)

Defines an array field.

The block must define exactly one element type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

**See also**

- [API::Element](api-element)

**Example: Array of integers**

```ruby
array :ids do
  integer
end
```

**Example: Array of references**

```ruby
array :items do
  reference :item
end
```

**Example: Array of inline objects**

```ruby
array :lines do
  object do
    string :description
    decimal :amount
  end
end
```

---

### #boolean

`#boolean(name, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L263)

Defines a boolean field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `Boolean` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

**Example**

```ruby
boolean :active
```

---

### #date

`#date(name, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L356)

Defines a date field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---

### #datetime

`#datetime(name, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L327)

Defines a datetime field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---

### #decimal

`#decimal(name, deprecated: nil, description: nil, example: nil, max: nil, min: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L227)

Defines a decimal field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `Numeric` | example value for documentation |
| `max` | `Numeric` | maximum value |
| `min` | `Numeric` | minimum value |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

**Example**

```ruby
decimal :amount
decimal :price, min: 0
```

---

### #float

`#float(name, deprecated: nil, description: nil, example: nil, max: nil, min: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L294)

Defines a float field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `Float` | example value for documentation |
| `max` | `Float` | maximum value |
| `min` | `Float` | minimum value |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---

### #integer

`#integer(name, deprecated: nil, description: nil, enum: nil, example: nil, max: nil, min: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L186)

Defines an integer field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `enum` | `Array` | allowed values |
| `example` | `Integer` | example value for documentation |
| `max` | `Integer` | maximum value |
| `min` | `Integer` | minimum value |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

**Example**

```ruby
integer :count
integer :age, min: 0, max: 150
```

---

### #literal

`#literal(name, value:, deprecated: nil, description: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L417)

Defines a literal value field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `value` | `Object` | the exact value (required) |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

**Example**

```ruby
literal :type, value: 'card'
literal :version, value: 1
```

---

### #object

`#object(name, deprecated: nil, description: nil, nullable: nil, optional: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L544)

Defines an inline object field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

**See also**

- [API::Object](api-object)

**Example**

```ruby
object :customer do
  string :name
  string :email
end
```

---

### #param

`#param(name, type: nil, as: nil, default: nil, deprecated: nil, description: nil, discriminator: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: nil, of: nil, optional: false, required: nil, shape: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L75)

Defines a parameter within this object.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | parameter name |
| `type` | `Symbol` | primitive type or reference to named object/union |
| `as` | `Symbol` | internal name transformation |
| `default` | `Object` | default value when omitted |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `discriminator` | `Symbol` | discriminator field for inline unions |
| `enum` | `Symbol, Array` | enum reference or inline values |
| `example` | `Object` | example value for documentation |
| `format` | `String` | format hint for documentation |
| `internal` | `Hash` | internal metadata for adapters |
| `max` | `Numeric` | maximum value constraint |
| `min` | `Numeric` | minimum value constraint |
| `nullable` | `Boolean` | whether the value can be null |
| `of` | `Symbol` | element type for arrays |
| `optional` | `Boolean` | whether the parameter can be omitted |
| `required` | `Boolean` | alias for optional: false |
| `shape` | `Object` | pre-built shape for arrays |
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

### #reference

`#reference(name, to: nil, deprecated: nil, description: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L450)

Defines a reference to a named type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `to` | `Symbol` | target type name (defaults to field name) |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

**Example: Same name**

```ruby
reference :invoice
```

**Example: Different name**

```ruby
reference :shipping_address, to: :address
```

---

### #string

`#string(name, deprecated: nil, description: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L142)

Defines a string field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `enum` | `Array` | allowed values |
| `example` | `String` | example value for documentation |
| `format` | `String` | format hint |
| `max` | `Integer` | maximum length |
| `min` | `Integer` | minimum length |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

**Example**

```ruby
string :title
string :status, enum: %w[pending active]
```

---

### #union

`#union(name, discriminator: nil, deprecated: nil, description: nil, nullable: nil, optional: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L584)

Defines an inline union field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `discriminator` | `Symbol` | discriminator field for tagged unions |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

**See also**

- [API::Union](api-union)

**Example**

```ruby
union :payment_method, discriminator: :type do
  variant tag: 'card' do
    object do
      string :last_four
    end
  end
end
```

---

### #uuid

`#uuid(name, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L385)

Defines a UUID field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---
