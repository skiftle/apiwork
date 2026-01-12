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

`#array(name, as: nil, deprecated: nil, description: nil, nullable: nil, optional: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L599)

Defines an array field.

The block must define exactly one element type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
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

### #binary

`#binary(name, as: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L440)

Defines a binary field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---

### #boolean

`#boolean(name, as: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L242)

Defines a boolean field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
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

`#date(name, as: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L344)

Defines a date field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---

### #datetime

`#datetime(name, as: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L312)

Defines a datetime field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---

### #decimal

`#decimal(name, as: nil, deprecated: nil, description: nil, example: nil, max: nil, min: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L203)

Defines a decimal field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
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

`#float(name, as: nil, deprecated: nil, description: nil, example: nil, max: nil, min: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L276)

Defines a float field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
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

`#integer(name, as: nil, deprecated: nil, description: nil, enum: nil, example: nil, max: nil, min: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L159)

Defines an integer field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
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

### #json

`#json(name, as: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L473)

Defines a JSON field for arbitrary/unstructured JSON data.
For structured data with known fields, use object with a block instead.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `Object` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---

### #literal

`#literal(name, value:, as: nil, deprecated: nil, description: nil, optional: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L508)

Defines a literal value field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `value` | `Object` | the exact value (required) |
| `as` | `Symbol` | target attribute name |
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

`#object(name, as: nil, deprecated: nil, description: nil, nullable: nil, optional: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L651)

Defines an inline object field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
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

### #reference

`#reference(name, to: nil, as: nil, deprecated: nil, description: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L546)

Defines a reference to a named type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `to` | `Symbol` | target type name (defaults to field name) |
| `as` | `Symbol` | target attribute name |
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

`#string(name, as: nil, deprecated: nil, description: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L112)

Defines a string field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
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

### #time

`#time(name, as: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L408)

Defines a time field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---

### #union

`#union(name, discriminator: nil, as: nil, deprecated: nil, description: nil, nullable: nil, optional: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L694)

Defines an inline union field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `discriminator` | `Symbol` | discriminator field for tagged unions |
| `as` | `Symbol` | target attribute name |
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

`#uuid(name, as: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L376)

Defines a UUID field.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `as` | `Symbol` | target attribute name |
| `deprecated` | `Boolean` | mark as deprecated |
| `description` | `String` | documentation description |
| `example` | `String` | example value for documentation |
| `nullable` | `Boolean` | whether null is allowed |
| `optional` | `Boolean` | whether field can be omitted |

**Returns**

`void`

---
