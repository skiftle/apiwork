---
order: 82
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

`#array(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L158)

Defines an array.

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

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `max` | `Numeric`, `nil` | `nil` | maximum value |
| `min` | `Numeric`, `nil` | `nil` | minimum value |

</div>

**Returns**

`void`

---

### #integer

`#integer(enum: nil, max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L48)

Defines an integer.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `enum` | `Array`, `Symbol`, `nil` | `nil` | allowed values |
| `max` | `Integer`, `nil` | `nil` | maximum value |
| `min` | `Integer`, `nil` | `nil` | minimum value |

</div>

**Returns**

`void`

---

### #literal

`#literal(value:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L196)

Defines a literal value.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`value`** | `Object` |  | the exact value (required) |

</div>

**Returns**

`void`

---

### #number

`#number(max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L68)

Defines a number.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `max` | `Numeric`, `nil` | `nil` | maximum value |
| `min` | `Numeric`, `nil` | `nil` | minimum value |

</div>

**Returns**

`void`

---

### #object

`#object(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L138)

Defines an object.

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

`#of(type, discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/element.rb#L96)

Defines the element type.

Only complex types (:object, :array, :union) are allowed.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`type`** | `Symbol<:object, :array, :union>` |  | element type |
| `discriminator` | `Symbol`, `nil` | `nil` | discriminator field name (unions only) |

</div>

**Returns**

`void`

**Yields** [API::Object](/reference/api/object), [API::Union](/reference/api/union), [API::Element](/reference/api/element)

---

### #reference

`#reference(type_name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L205)

Defines a reference to a named type.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`type_name`** | `Symbol` |  | The type to reference. |

</div>

**Returns**

`void`

---

### #string

`#string(enum: nil, format: nil, max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L37)

Defines a string.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `enum` | `Array`, `Symbol`, `nil` | `nil` | allowed values |
| `format` | `Symbol`, `nil` | `nil` | format hint |
| `max` | `Integer`, `nil` | `nil` | maximum length |
| `min` | `Integer`, `nil` | `nil` | minimum length |

</div>

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

`#union(discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L187)

Defines a union.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `discriminator` | `Symbol`, `nil` | `nil` | discriminator field name |

</div>

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
