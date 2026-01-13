---
order: 20
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

`#array(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L291)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L231)

Defines a binary element.

**Returns**

`void`

---

### #boolean

`#boolean`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L181)

Defines a boolean element.

**Returns**

`void`

---

### #date

`#date`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L207)

Defines a date element.

**Returns**

`void`

---

### #datetime

`#datetime`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L199)

Defines a datetime element.

**Returns**

`void`

---

### #decimal

`#decimal(max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L173)

Defines a decimal element.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L163)

Defines an integer element.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enum` | `Array, Symbol` | allowed values or enum reference |
| `max` | `Integer` | maximum value |
| `min` | `Integer` | minimum value |

**Returns**

`void`

---

### #literal

`#literal(value:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L244)

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

### #number

`#number(max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L191)

Defines a number element.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max` | `Numeric` | maximum value |
| `min` | `Numeric` | minimum value |

**Returns**

`void`

---

### #object

`#object(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L274)

Defines an inline object element.

**Returns**

`void`

**See also**

- [Contract::Object](contract-object)

**Example**

```ruby
object do
  string :name
  decimal :amount
end
```

---

### #of

`#of(type, discriminator: nil, enum: nil, format: nil, max: nil, min: nil, shape: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L81)

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
| `max` | `Integer, nil` | maximum value or length (strings, integers, decimals, numbers, arrays only) |
| `min` | `Integer, nil` | minimum value or length (strings, integers, decimals, numbers, arrays only) |
| `shape` | `Contract::Object, Contract::Union, nil` | pre-built shape (objects, arrays, unions only) |
| `value` | `Object, nil` | literal value (literals only) |

**Returns**

`void`

**Example: Basic usage**

```ruby
of :string
of :string, enum: %w[a b c]
```

**Example: With pre-built shape**

```ruby
of :object, shape: prebuilt_shape
```

---

### #reference

`#reference(type_name, to: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L258)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L152)

Defines a string element.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enum` | `Array, Symbol` | allowed values or enum reference |
| `format` | `String` | format hint |
| `max` | `Integer` | maximum length |
| `min` | `Integer` | minimum length |

**Returns**

`void`

---

### #time

`#time`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L223)

Defines a time element.

**Returns**

`void`

---

### #union

`#union(discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L308)

Defines an inline union element.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `discriminator` | `Symbol` | discriminator field for tagged unions |

**Returns**

`void`

**See also**

- [Contract::Union](contract-union)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L215)

Defines a UUID element.

**Returns**

`void`

---
