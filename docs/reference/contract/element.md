---
order: 41
prev: false
next: false
---

# Element

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L160)

Defines an array.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | `Object, nil` | pre-built shape |

**Returns**

`void`

**Yields** [Element](/reference/api/element)

**Example: instance_eval style**

```ruby
array do
  string
end
```

**Example: yield style**

```ruby
array do |element|
  element.string
end
```

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L199)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L139)

Defines an object.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | `Object, nil` | pre-built shape |

**Returns**

`void`

**Yields** `Object`

**Example: instance_eval style**

```ruby
object do
  string :name
  integer :count
end
```

**Example: yield style**

```ruby
object do |object|
  object.string :name
  object.integer :count
end
```

---

### #of

`#of(type, discriminator: nil, enum: nil, format: nil, max: nil, min: nil, shape: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L66)

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

**Yields** [Contract::Object](/reference/contract/object), [Contract::Union](/reference/contract/union), [Contract::Element](/reference/contract/element)

**Example: instance_eval style**

```ruby
array :tags do
  of :object do
    string :name
    string :color
  end
end
```

**Example: yield style**

```ruby
array :tags do |element|
  element.of :object do |object|
    object.string :name
    object.string :color
  end
end
```

---

### #reference

`#reference(type_name, to: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L209)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L190)

Defines a union.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `discriminator` | `Symbol, nil` | discriminator field name |
| `shape` | `Union, nil` | pre-built shape |

**Returns**

`void`

**Yields** [Union](/reference/api/union)

**Example: instance_eval style**

```ruby
union discriminator: :type do
  variant tag: 'card' do
    object do
      string :last_four
    end
  end
end
```

**Example: yield style**

```ruby
union discriminator: :type do |union|
  union.variant tag: 'card' do |variant|
    variant.object do |object|
      object.string :last_four
    end
  end
end
```

---

### #uuid

`#uuid`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L100)

Defines a UUID.

**Returns**

`void`

---
