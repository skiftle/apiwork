---
order: 29
prev: false
next: false
---

# Contract::Element

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L26)

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

**Example: Variant with enum reference**

```ruby
variant { string enum: :status }
```

## Instance Methods

### #array

`#array(shape: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L136)

Defines an array.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | `Object, nil` | pre-built shape |

**Returns**

`void`

---

### #binary

`#binary`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L116)

Defines a binary.

**Returns**

`void`

---

### #boolean

`#boolean`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L76)

Defines a boolean.

**Returns**

`void`

---

### #date

`#date`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L92)

Defines a date.

**Returns**

`void`

---

### #datetime

`#datetime`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L84)

Defines a datetime.

**Returns**

`void`

---

### #decimal

`#decimal(max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L58)

Defines a decimal.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max` | `Numeric, nil` | maximum value |
| `min` | `Numeric, nil` | minimum value |

**Returns**

`void`

---

### #integer

`#integer(enum: nil, max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L48)

Defines an integer.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enum` | `Array, Symbol, nil` | allowed values |
| `max` | `Integer, nil` | maximum value |
| `min` | `Integer, nil` | minimum value |

**Returns**

`void`

---

### #literal

`#literal(value:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L156)

Defines a literal value.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Object` | the exact value (required) |

**Returns**

`void`

---

### #number

`#number(max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L68)

Defines a number.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max` | `Numeric, nil` | maximum value |
| `min` | `Numeric, nil` | minimum value |

**Returns**

`void`

---

### #object

`#object(shape: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L126)

Defines an object.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | `Object, nil` | pre-built shape |

**Returns**

`void`

---

### #of

`#of(type, discriminator: nil, enum: nil, format: nil, max: nil, min: nil, shape: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L49)

Defines the element type.

This is the verbose form. Prefer sugar methods (string, integer, etc.)
for static definitions. Use `of` for dynamic element generation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type` | `Symbol` | element type (:string, :integer, :object, :array, :union, or custom type reference) |
| `discriminator` | `Symbol, nil` | discriminator field name (unions only) |
| `enum` | `Array, Symbol, nil` | allowed values or enum reference (strings, integers only) |
| `format` | `Symbol, nil` | format hint (strings only) |
| `max` | `Integer, nil` | maximum value or length |
| `min` | `Integer, nil` | minimum value or length |
| `shape` | `Contract::Object, Contract::Union, nil` | pre-built shape |
| `value` | `Object, nil` | literal value (literals only) |

**Returns**

`void`

---

### #reference

`#reference(type_name, to: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L166)

Defines a reference to a named type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `Symbol` | type name |
| `to` | `Symbol, nil` | target type name (defaults to type_name) |

**Returns**

`void`

---

### #string

`#string(enum: nil, format: nil, max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L37)

Defines a string.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enum` | `Array, Symbol, nil` | allowed values |
| `format` | `Symbol, nil` | format hint |
| `max` | `Integer, nil` | maximum length |
| `min` | `Integer, nil` | minimum length |

**Returns**

`void`

---

### #time

`#time`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L108)

Defines a time.

**Returns**

`void`

---

### #union

`#union(discriminator: nil, shape: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L147)

Defines a union.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `discriminator` | `Symbol, nil` | discriminator field name |
| `shape` | `Union, nil` | pre-built shape |

**Returns**

`void`

---

### #uuid

`#uuid`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L100)

Defines a UUID.

**Returns**

`void`

---
