---
order: 3
prev: false
next: false
---

# Element

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L28)

Block context for defining a single type expression.

Used inside `array do` and `variant do` blocks where
exactly one element type must be defined.

**Example: instance_eval style**

```ruby
array :ids do
  integer
end
```

**Example: yield style**

```ruby
array :ids do |element|
  element.integer
end
```

**Example: Array of references**

```ruby
array :items do |element|
  element.reference :item
end
```

## Instance Methods

### #array

`#array(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L247)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L197)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L132)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L158)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L145)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L97)

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

### #integer

`#integer(enum: nil, max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L75)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L296)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L119)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L223)

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

`#of(type, discriminator: nil, enum: nil, format: nil, max: nil, min: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/element.rb#L66)

Defines the element type.

This is the verbose form. Prefer sugar methods (string, integer, etc.)
for static definitions. Use `of` for dynamic element generation.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`type`** | `Symbol<:array, :binary, :boolean, :date, :datetime, :decimal, :integer, :literal, :number, :object, :string, :time, :union, :uuid>` |  | The element type. Custom type references are also allowed. |
| `discriminator` | `Symbol`, `nil` | `nil` | The discriminator field name. Unions only. |
| `enum` | `Array`, `Symbol`, `nil` | `nil` | The allowed values. Strings and integers only. |
| `format` | `Symbol<:date, :datetime, :email, :hostname, :ipv4, :ipv6, :password, :url, :uuid>`, `nil` | `nil` | Format hint for exports. Strings only. |
| `max` | `Integer`, `nil` | `nil` | The maximum value or length. |
| `min` | `Integer`, `nil` | `nil` | The minimum value or length. |
| `value` | `Object`, `nil` | `nil` | The literal value. Literals only. |

</div>

**Returns**

`void`

**Yields** [API::Object](/reference/api/object), [API::Union](/reference/api/union), [API::Element](/reference/api/element)

**Example: instance_eval style**

```ruby
array :tags do
  of :object do
    string :name
  end
end
```

**Example: yield style**

```ruby
array :tags do |element|
  element.of :object do |object|
    object.string :name
  end
end
```

---

### #reference

`#reference(type_name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L311)

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

### #string

`#string(enum: nil, format: nil, max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L51)

Defines a string.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `enum` | `Array`, `Symbol`, `nil` | `nil` | The allowed values. |
| `format` | `Symbol<:date, :datetime, :email, :hostname, :ipv4, :ipv6, :password, :url, :uuid>`, `nil` | `nil` | Format hint for exports. Does not change the type, but exports may add validation or documentation based on it. |
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L184)

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

### #union

`#union(discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L281)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L171)

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
