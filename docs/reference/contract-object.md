---
order: 21
prev: false
next: false
---

# Contract::Object

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L23)

Block context for defining request/response structure.

Accessed via `body do`, `query do`, or `object :x do`
inside contract actions. Use type methods to define fields.

**Example: Request body**

```ruby
body do
  string :title
  decimal :amount
end
```

**Example: Inline nested object**

```ruby
object :customer do
  string :name
end
```

## Instance Methods

### #array

`#array(name, default: nil, deprecated: nil, description: nil, nullable: nil, optional: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L611)

Defines an array field.

The block must define exactly one element type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `default` | `Array` | default value |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

**See also**

- [Contract::Element](contract-element)

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

### #binary

`#binary(name, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L489)

Defines a binary field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `default` | `String` | default value |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---

### #boolean

`#boolean(name, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L291)

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

`#date(name, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L393)

Defines a date field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `default` | `String` | default value |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---

### #datetime

`#datetime(name, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L361)

Defines a datetime field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `default` | `String` | default value |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---

### #decimal

`#decimal(name, default: nil, deprecated: nil, description: nil, example: nil, max: nil, min: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L253)

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

### #integer

`#integer(name, default: nil, deprecated: nil, description: nil, enum: nil, example: nil, max: nil, min: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L210)

Defines an integer field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `enum` | `Array, Symbol` | allowed values or enum reference |
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

`#literal(name, value:, as: nil, deprecated: nil, description: nil, optional: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L523)

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

### #meta

`#meta(optional: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L748)

Shorthand for `object :meta do ... end`.

Use for response data that doesn't belong to the resource itself.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `optional` | `Boolean` | whether meta can be omitted (default: false) |

**Example: Required meta (default)**

```ruby
response do
  body do
    meta do
      datetime :generated_at
    end
  end
end
```

**Example: Optional meta**

```ruby
response do
  body do
    meta optional: true do
      string :api_version
    end
  end
end
```

---

### #number

`#number(name, default: nil, deprecated: nil, description: nil, example: nil, max: nil, min: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L325)

Defines a number field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `default` | `Float` | default value |
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

### #object

`#object(name, deprecated: nil, description: nil, nullable: nil, optional: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L662)

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

- [Contract::Object](contract-object)

**Example**

```ruby
object :customer do
  string :name
  string :email
end
```

---

### #param

`#param(name, type = nil, as: nil, default: nil, deprecated: nil, description: nil, discriminator: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: nil, of: nil, optional: nil, required: nil, shape: nil, store: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L74)

Defines a field with explicit type.

This is the verbose form. Prefer sugar methods (string, integer, etc.)
for static definitions. Use `param` for dynamic field generation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `type` | `Symbol, nil` | field type (:string, :integer, :object, :array, :union, or custom type reference) |
| `as` | `Symbol, nil` | target attribute name for mapping to model |
| `default` | `Object, nil` | default value when field is omitted |
| `deprecated` | `Boolean, nil` | mark field as deprecated |
| `description` | `String, nil` | documentation description |
| `discriminator` | `Symbol, nil` | discriminator field name (unions only) |
| `enum` | `Array, Symbol, nil` | allowed values or enum reference (strings, integers only) |
| `example` | `Object, nil` | example value for documentation |
| `format` | `Symbol, nil` | format hint (strings only) |
| `max` | `Integer, nil` | maximum value or length (strings, integers, decimals, numbers, arrays only) |
| `min` | `Integer, nil` | minimum value or length (strings, integers, decimals, numbers, arrays only) |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `of` | `Symbol, Hash, nil` | element type (arrays only) |
| `optional` | `Boolean, nil` | whether field can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `shape` | `Contract::Object, Contract::Union, nil` | pre-built shape (objects, arrays, unions only) |
| `store` | `Boolean, nil` | whether to persist the value |
| `value` | `Object, nil` | literal value (literals only) |

**Returns**

`void`

**Example: Basic usage**

```ruby
param :title, :string
param :count, :integer, min: 0
```

**Example: With options**

```ruby
param :status, :string, enum: %w[pending active], description: 'Current status'
```

**Example: Extending existing param (type omitted)**

```ruby
param :name, description: 'Updated description'
```

---

### #reference

`#reference(name, to: nil, deprecated: nil, description: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L560)

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

`#string(name, default: nil, deprecated: nil, description: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L164)

Defines a string field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `enum` | `Array, Symbol` | allowed values or enum reference |
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

### #time

`#time(name, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L457)

Defines a time field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `default` | `String` | default value |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---

### #union

`#union(name, discriminator: nil, deprecated: nil, description: nil, nullable: nil, optional: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L702)

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

- [Contract::Union](contract-union)

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

`#uuid(name, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L425)

Defines a UUID field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `default` | `String` | default value |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---
