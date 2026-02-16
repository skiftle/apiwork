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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L261)

Defines an array.

**Returns**

`void`

**Yields** [Element](/reference/api/element)

**Example: instance_eval style**

```ruby
array :matrix do
  array do
    integer
  end
end
```

**Example: yield style**

```ruby
array :matrix do |element|
  element.array do |inner|
    inner.integer
  end
end
```

---

### #binary

`#binary`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L211)

Defines a binary.

**Returns**

`void`

**Example**

```ruby
array :blobs do
  binary
end
```

---

### #boolean

`#boolean`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L146)

Defines a boolean.

**Returns**

`void`

**Example**

```ruby
array :flags do
  boolean
end
```

---

### #date

`#date`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L172)

Defines a date.

**Returns**

`void`

**Example**

```ruby
array :dates do
  date
end
```

---

### #datetime

`#datetime`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L159)

Defines a datetime.

**Returns**

`void`

**Example**

```ruby
array :timestamps do
  datetime
end
```

---

### #decimal

`#decimal(max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L111)

Defines a decimal.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `max` | `Numeric`, `nil` | `nil` | The maximum value. |
| `min` | `Numeric`, `nil` | `nil` | The minimum value. |

</div>

**Returns**

`void`

**Example: Basic decimal**

```ruby
array :amounts do
  decimal
end
```

**Example: With range constraints**

```ruby
array :prices do
  decimal min: 0
end
```

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L7)

**Returns**

`Symbol`, `nil` — the discriminator field name for unions

---

### #inner

`#inner`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L11)

**Returns**

[Element](/reference/api/element), `nil` — the inner element type for nested arrays

---

### #integer

`#integer(enum: nil, max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L89)

Defines an integer.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `enum` | `Array`, `Symbol`, `nil` | `nil` | The allowed values. |
| `max` | `Integer`, `nil` | `nil` | The maximum value. |
| `min` | `Integer`, `nil` | `nil` | The minimum value. |

</div>

**Returns**

`void`

**Example: Basic integer**

```ruby
array :counts do
  integer
end
```

**Example: With range constraints**

```ruby
array :scores do
  integer min: 0, max: 100
end
```

---

### #literal

`#literal(value:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L310)

Defines a literal value.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`value`** | `Object` |  | The literal value. |

</div>

**Returns**

`void`

**Example**

```ruby
variant tag: 'card' do
  literal value: 'card'
end
```

---

### #number

`#number(max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L133)

Defines a number.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `max` | `Numeric`, `nil` | `nil` | The maximum value. |
| `min` | `Numeric`, `nil` | `nil` | The minimum value. |

</div>

**Returns**

`void`

**Example: Basic number**

```ruby
array :coordinates do
  number
end
```

**Example: With range constraints**

```ruby
array :latitudes do
  number min: -90, max: 90
end
```

---

### #object

`#object(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L237)

Defines an object.

**Returns**

`void`

**Yields** `Object`

**Example: instance_eval style**

```ruby
array :items do
  object do
    string :name
    decimal :price
  end
end
```

**Example: yield style**

```ruby
array :items do |element|
  element.object do |object|
    object.string :name
    object.decimal :price
  end
end
```

---

### #of

`#of(type, discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/element.rb#L93)

Defines the element type.

Only complex types (:object, :array, :union) are allowed.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`type`** | `Symbol<:array, :object, :union>` |  | The element type. |
| `discriminator` | `Symbol`, `nil` | `nil` | The discriminator field name. Unions only. |

</div>

**Returns**

`void`

**Yields** [API::Object](/reference/api/object), [API::Union](/reference/api/union), [API::Element](/reference/api/element)

---

### #reference

`#reference(type_name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L325)

Defines a reference to a named type.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`type_name`** | `Symbol` |  | The type to reference. |

</div>

**Returns**

`void`

**Example**

```ruby
array :items do
  reference :item
end
```

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L15)

**Returns**

`Object`, `nil` — the nested shape for objects

---

### #string

`#string(enum: nil, format: nil, max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L65)

Defines a string.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `enum` | `Array`, `Symbol`, `nil` | `nil` | The allowed values. |
| `format` | `Symbol<:date, :datetime, :email, :hostname, :ipv4, :ipv6, :password, :url, :uuid>`, `nil` | `nil` | Format hint for exports. Does not change the type, but exports may add validation or documentation based on it. Valid formats by type: `:string`. |
| `max` | `Integer`, `nil` | `nil` | The maximum length. |
| `min` | `Integer`, `nil` | `nil` | The minimum length. |

</div>

**Returns**

`void`

**Example: Basic string**

```ruby
array :tags do
  string
end
```

**Example: With length constraints**

```ruby
array :tags do
  string min: 1, max: 50
end
```

---

### #time

`#time`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L198)

Defines a time.

**Returns**

`void`

**Example**

```ruby
array :times do
  time
end
```

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L19)

**Returns**

`Symbol`, `nil` — the element type

---

### #union

`#union(discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L295)

Defines a union.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `discriminator` | `Symbol`, `nil` | `nil` | The discriminator field name. |

</div>

**Returns**

`void`

**Yields** [Union](/reference/api/union)

**Example: instance_eval style**

```ruby
array :payments do
  union discriminator: :type do
    variant tag: 'card' do
      object do
        string :last_four
      end
    end
  end
end
```

**Example: yield style**

```ruby
array :payments do |element|
  element.union discriminator: :type do |union|
    union.variant tag: 'card' do |variant|
      variant.object do |object|
        object.string :last_four
      end
    end
  end
end
```

---

### #uuid

`#uuid`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L185)

Defines a UUID.

**Returns**

`void`

**Example**

```ruby
array :ids do
  uuid
end
```

---
