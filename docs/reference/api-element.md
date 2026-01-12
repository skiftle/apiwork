---
order: 3
prev: false
next: false
---

# API::Element

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L26)

Block context for defining a single type expression.

Used inside `array do` and `variant do` blocks where
exactly one element type must be defined.

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

**Example: Variant with options**

```ruby
variant { string enum: %w[pending active] }
```

## Instance Methods

### #array

`#array(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L249)

Defines an array element.

The block must define exactly one element type.

**Returns**

`void`

**Example: Array of integers**

```ruby
array { integer }
```

**Example: Array of references**

```ruby
array { reference :item }
```

---

### #binary

`#binary`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L180)

Defines a binary element.

**Returns**

`void`

---

### #boolean

`#boolean`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L130)

Defines a boolean element.

**Returns**

`void`

---

### #date

`#date`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L156)

Defines a date element.

**Returns**

`void`

---

### #datetime

`#datetime`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L148)

Defines a datetime element.

**Returns**

`void`

---

### #decimal

`#decimal(max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L122)

Defines a decimal element.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max` | `Numeric` | maximum value |
| `min` | `Numeric` | minimum value |

**Returns**

`void`

---

### #float

`#float(max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L140)

Defines a float element.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max` | `Numeric` | maximum value |
| `min` | `Numeric` | minimum value |

**Returns**

`void`

---

### #integer

`#integer(enum: nil, max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L112)

Defines an integer element.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enum` | `Array` | allowed values |
| `max` | `Integer` | maximum value |
| `min` | `Integer` | minimum value |

**Returns**

`void`

---

### #json

`#json`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L189)

Defines a JSON element for arbitrary/unstructured JSON data.
For structured data with known fields, use object with a block instead.

**Returns**

`void`

---

### #literal

`#literal(value:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L202)

Defines a literal value element.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Object` | the exact value (required) |

**Returns**

`void`

**Example**

```ruby
literal value: 'card'
literal value: 42
```

---

### #object

`#object(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L232)

Defines an inline object element.

**Returns**

`void`

**See also**

- [API::Object](api-object)

**Example**

```ruby
object do
  string :name
  decimal :amount
end
```

---

### #reference

`#reference(type_name, to: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L216)

Defines a reference to a named type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `Symbol` | type name (also used as default target) |
| `to` | `Symbol` | explicit target type name |

**Returns**

`void`

**Example**

```ruby
reference :item
reference :shipping_address, to: :address
```

---

### #string

`#string(enum: nil, format: nil, max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L101)

Defines a string element.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enum` | `Array` | allowed values |
| `format` | `String` | format hint |
| `max` | `Integer` | maximum length |
| `min` | `Integer` | minimum length |

**Returns**

`void`

---

### #time

`#time`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L172)

Defines a time element.

**Returns**

`void`

---

### #union

`#union(discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L266)

Defines an inline union element.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `discriminator` | `Symbol` | discriminator field for tagged unions |

**Returns**

`void`

**See also**

- [API::Union](api-union)

**Example**

```ruby
union do
  variant { integer }
  variant { string }
end
```

---

### #uuid

`#uuid`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L164)

Defines a UUID element.

**Returns**

`void`

---
