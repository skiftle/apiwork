---
order: 80
prev: false
next: false
---

# Element

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/element.rb#L75)

Block context for defining JSON blob structure in representation attributes.

Used inside attribute blocks to define the shape of JSON/JSONB columns,
Rails store attributes, or any serialized data structure.

Only complex types are allowed at the top level:
- [#object](#object) for key-value structures
- [#array](#array) for ordered collections
- [#union](#union) for polymorphic structures

Inside these blocks, the full type DSL is available including
nested objects, arrays, primitives, and unions.

**Example: Object structure**

```ruby
attribute :settings do
  object do
    string :theme
    boolean :notifications
    integer :max_items, min: 1, max: 100
  end
end
```

**Example: Array of objects**

```ruby
attribute :addresses do
  array do
    object do
      string :street
      string :city
      string :zip
      boolean :primary
    end
  end
end
```

**Example: Nested structures**

```ruby
attribute :config do
  object do
    string :name
    array :tags do
      string
    end
    object :metadata do
      datetime :created_at
      datetime :updated_at
    end
  end
end
```

**Example: Union for polymorphic data**

```ruby
attribute :payment_details do
  union discriminator: :type do
    variant tag: 'card' do
      object do
        string :last_four
        string :brand
      end
    end
    variant tag: 'bank' do
      object do
        string :account_number
        string :routing_number
      end
    end
  end
end
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

`#of(type, discriminator: nil, shape: nil, **_options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/element.rb#L97)

Defines the element type.

Only complex types (:object, :array, :union) are allowed.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type` | `Symbol` | element type (:object, :array, :union) |
| `discriminator` | `Symbol, nil` | discriminator field name (unions only) |
| `shape` | `API::Object, API::Union, nil` | pre-built shape |

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
