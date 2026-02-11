---
order: 41
prev: false
next: false
---

# Element

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L28)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L294)

Defines an array.

**Returns**

`void`

**Yields** [Element](/reference/element)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L244)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L179)

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

### #custom_type

`#custom_type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L51)

The custom type for this element.

**Returns**

`Symbol`, `nil`

---

### #date

`#date`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L205)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L192)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L144)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L51)

The discriminator for this element.

**Returns**

`Symbol`, `nil`

---

### #enum

`#enum`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L51)

The enum for this element.

**Returns**

`Array`, `Symbol`, `nil`

---

### #format

`#format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L51)

The format for this element.

**Returns**

`Symbol`, `nil`

---

### #integer

`#integer(enum: nil, max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L122)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L343)

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

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L51)

The maximum for this element.

**Returns**

`Numeric`, `nil`

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L51)

The minimum for this element.

**Returns**

`Numeric`, `nil`

---

### #number

`#number(max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L166)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L270)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/element.rb#L74)

Defines the element type.

This is the verbose form. Prefer sugar methods (string, integer, etc.)
for static definitions. Use `of` for dynamic element generation.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`type`** | `Symbol<:array, :binary, :boolean, :date, :datetime, :decimal, :integer, :literal, :number, :object, :string, :time, :union, :uuid>` |  | The element type. Custom type references are also allowed. |
| `discriminator` | `Symbol`, `nil` | `nil` | The discriminator field name. Unions only. |
| `enum` | `Array`, `Symbol`, `nil` | `nil` | The allowed values or enum reference. Strings and integers only. |
| `format` | `Symbol<:date, :datetime, :double, :email, :float, :hostname, :int32, :int64, :ipv4, :ipv6, :password, :url, :uuid>`, `nil` | `nil` | Format hint for exports. Does not change the type, but exports may add validation or documentation based on it. Valid formats by type: `:decimal`/`:number` (`:double`, `:float`), `:integer` (`:int32`, `:int64`), `:string` (`:date`, `:datetime`, `:email`, `:hostname`, `:ipv4`, `:ipv6`, `:password`, `:url`, `:uuid`). |
| `max` | `Integer`, `nil` | `nil` | The maximum. For `:decimal`, `:integer`, `:number`: value. For `:string`: length. |
| `min` | `Integer`, `nil` | `nil` | The minimum. For `:decimal`, `:integer`, `:number`: value. For `:string`: length. |
| `value` | `Object`, `nil` | `nil` | The literal value. Literals only. |

</div>

**Returns**

`void`

**Yields** [Contract::Object](/reference/contract/object), [Contract::Union](/reference/contract/union), [Contract::Element](/reference/contract/element)

**Example: Dynamic element type**

```ruby
element_type = :string
array :values do
  of element_type
end
```

**Example: Object with block**

```ruby
array :tags do
  of :object do
    string :name
    string :color
  end
end
```

---

### #reference

`#reference(type_name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L358)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L51)

The shape for this element.

**Returns**

`Object`, `nil`

---

### #string

`#string(enum: nil, format: nil, max: nil, min: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L98)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L231)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L51)

The type for this element.

**Returns**

`Symbol`, `nil`

---

### #union

`#union(discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L328)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/element.rb#L218)

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
