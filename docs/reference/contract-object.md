---
order: 20
prev: false
next: false
---

# Contract::Object

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L23)

Block context for defining request/response structure.

Accessed via `body do`, `query do`, or `param :x, type: :object do`
inside contract actions. Use [#param](#param) to define fields.

**Example: Request body**

```ruby
body do
  param :title, type: :string
  param :amount, type: :decimal
end
```

**Example: Inline nested object**

```ruby
param :customer, type: :object do
  param :name, type: :string
end
```

## Instance Methods

### #array

`#array(name, deprecated: nil, description: nil, nullable: nil, optional: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L552)

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

### #boolean

`#boolean(name, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L315)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L408)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L379)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L279)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L346)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L238)

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

`#literal(name, value:, deprecated: nil, description: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L469)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L682)

Shorthand for `param :meta, type: :object do ... end`.

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
      param :generated_at, type: :datetime
    end
  end
end
```

**Example: Optional meta**

```ruby
response do
  body do
    meta optional: true do
      param :api_version, type: :string
    end
  end
end
```

---

### #object

`#object(name, deprecated: nil, description: nil, nullable: nil, optional: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L596)

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

`#param(name, as: nil, default: nil, deprecated: nil, description: nil, discriminator: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: nil, of: nil, optional: nil, required: nil, shape: nil, type: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L79)

Defines a parameter/field in a request or response body.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `type` | `Symbol` | data type (:string, :integer, :boolean, :datetime, :date, :uuid, :object, :array, :decimal, :float, :literal, :union, or custom type) |
| `optional` | `Boolean` | whether field can be omitted (default: false) |
| `default` | `Object` | value when field is nil |
| `enum` | `Array, Symbol` | allowed values, or reference to registered enum |
| `of` | `Symbol` | element type for :array |
| `as` | `Symbol` | serialize field under different name |
| `discriminator` | `Symbol` | discriminator field for :union type |
| `value` | `Object` | exact value for :literal type |
| `deprecated` | `Boolean` | mark field as deprecated |
| `description` | `String` | field description for docs |
| `example` | `Object` | example value for docs |
| `format` | `String` | format hint (e.g. 'email', 'uri') |
| `max` | `Integer` | maximum value (numeric) or length (string/array) |
| `min` | `Integer` | minimum value (numeric) or length (string/array) |
| `nullable` | `Boolean` | whether null is allowed |
| `required` | `Boolean` | alias for optional: false (for readability) |

**Returns**

`void`

**See also**

- [Contract::Object](contract-object)
- [Contract::Union](contract-union)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L502)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L194)

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

### #union

`#union(name, discriminator: nil, deprecated: nil, description: nil, nullable: nil, optional: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L636)

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

`#uuid(name, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L437)

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
