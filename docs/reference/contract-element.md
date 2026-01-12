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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L258)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L189)

Defines a binary element.

**Returns**

`void`

---

### #boolean

`#boolean`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L139)

Defines a boolean element.

**Returns**

`void`

---

### #date

`#date`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L165)

Defines a date element.

**Returns**

`void`

---

### #datetime

`#datetime`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L157)

Defines a datetime element.

**Returns**

`void`

---

### #decimal

`#decimal(max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L131)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L149)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L121)

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

### #json

`#json`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L198)

Defines a JSON element for arbitrary/unstructured JSON data.
For structured data with known fields, use object with a block instead.

**Returns**

`void`

---

### #literal

`#literal(value:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L211)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L241)

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

### #reference

`#reference(type_name, to: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L225)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L110)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L181)

Defines a time element.

**Returns**

`void`

---

### #union

`#union(discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L275)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L173)

Defines a UUID element.

**Returns**

`void`

---
