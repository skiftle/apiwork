---
order: 42
prev: false
next: false
---

# Object

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L24)

Block context for defining request/response structure.

Accessed via `body do` and `query do` inside contract actions,
or `object :name do` at contract level to define reusable types.

**Example: instance_eval style**

```ruby
body do
  string :title
  decimal :amount
end
```

**Example: yield style**

```ruby
body do |body|
  body.string :title
  body.decimal :amount
end
```

## Instance Methods

### #array

`#array(name, as: nil, default: nil, deprecated: false, description: nil, nullable: false, optional: false, required: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L195)

Defines an array param with element type.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The param name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Yields** [Contract::Element](/reference/contract/element)

**Example: instance_eval style**

```ruby
array :tags do
  string
end
```

**Example: yield style**

```ruby
array :tags do |element|
  element.string
end
```

---

### #array?

`#array?(name, as: nil, default: nil, deprecated: false, description: nil, nullable: false, of: nil, required: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1323)

Defines an optional array.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `of` | `Symbol`, `Hash`, `nil` | `nil` | The element type. Arrays only. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional array of labels**

```ruby
array? :labels do
  string
end
```

---

### #binary

`#binary(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1060)

Defines a binary.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `String`, `nil` | `nil` | The example value. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: File content**

```ruby
binary :content
```

---

### #binary?

`#binary?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1108)

Defines an optional binary.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `String`, `nil` | `nil` | The example value. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional attachment**

```ruby
binary? :attachment
```

---

### #boolean

`#boolean(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L575)

Defines a boolean.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Boolean`, `nil` | `nil` | The example value. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Active flag**

```ruby
boolean :active
```

**Example: With default**

```ruby
boolean :published, default: false
```

---

### #boolean?

`#boolean?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L623)

Defines an optional boolean.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Boolean`, `nil` | `nil` | The example value. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional notification flag**

```ruby
boolean? :notify, default: true
```

---

### #date

`#date(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L769)

Defines a date.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `String`, `nil` | `nil` | The example value. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Birth date**

```ruby
date :birth_date
```

---

### #date?

`#date?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L817)

Defines an optional date.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `String`, `nil` | `nil` | The example value. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional expiry date**

```ruby
date? :expires_on
```

---

### #datetime

`#datetime(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L672)

Defines a datetime.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `String`, `nil` | `nil` | The example value. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Timestamp**

```ruby
datetime :created_at
```

---

### #datetime?

`#datetime?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L720)

Defines an optional datetime.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `String`, `nil` | `nil` | The example value. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional deletion timestamp**

```ruby
datetime? :deleted_at
```

---

### #decimal

`#decimal(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, max: nil, min: nil, nullable: false, optional: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L350)

Defines a decimal.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Numeric`, `nil` | `nil` | The example value. Metadata included in exports. |
| `max` | `Numeric`, `nil` | `nil` | The maximum value. |
| `min` | `Numeric`, `nil` | `nil` | The minimum value. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Price with minimum**

```ruby
decimal :amount, min: 0
```

**Example: Percentage with range**

```ruby
decimal :discount, min: 0, max: 100
```

---

### #decimal?

`#decimal?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, max: nil, min: nil, nullable: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L406)

Defines an optional decimal.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Numeric`, `nil` | `nil` | The example value. Metadata included in exports. |
| `max` | `Numeric`, `nil` | `nil` | The maximum value. |
| `min` | `Numeric`, `nil` | `nil` | The minimum value. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional tax rate**

```ruby
decimal? :tax_rate, min: 0, max: 1
```

---

### #extends

`#extends(type_name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L34)

Inherits all properties from another type.
Can be called multiple times to inherit from multiple types.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `type_name` | `Symbol`, `nil` | `nil` | The type to inherit from. |

</div>

**Returns**

`Array<Symbol>`

**Example: Single inheritance**

```ruby
object :admin do
  extends :user
  boolean :superuser
end
```

**Example: Multiple inheritance**

```ruby
object :employee do
  extends :person
  extends :contactable
  string :employee_id
end
```

---

### #integer

`#integer(name, as: nil, default: nil, deprecated: false, description: nil, enum: nil, example: nil, max: nil, min: nil, nullable: false, optional: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L228)

Defines an integer.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `enum` | `Array`, `Symbol`, `nil` | `nil` | The allowed values. |
| `example` | `Integer`, `nil` | `nil` | The example value. Metadata included in exports. |
| `max` | `Integer`, `nil` | `nil` | The maximum value. |
| `min` | `Integer`, `nil` | `nil` | The minimum value. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Basic integer**

```ruby
integer :quantity
```

**Example: With range constraints**

```ruby
integer :age, min: 0, max: 150
```

---

### #integer?

`#integer?(name, as: nil, default: nil, deprecated: false, description: nil, enum: nil, example: nil, max: nil, min: nil, nullable: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L288)

Defines an optional integer.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `enum` | `Array`, `Symbol`, `nil` | `nil` | The allowed values. |
| `example` | `Integer`, `nil` | `nil` | The example value. Metadata included in exports. |
| `max` | `Integer`, `nil` | `nil` | The maximum value. |
| `min` | `Integer`, `nil` | `nil` | The minimum value. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional page number**

```ruby
integer? :page, min: 1, default: 1
```

---

### #literal

`#literal(name, value:, as: nil, default: nil, deprecated: false, description: nil, optional: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1495)

Defines a literal value.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| **`value`** | `Object` |  | The exact value. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |

</div>

**Returns**

`void`

**Example: Fixed version number**

```ruby
literal :version, value: '1.0'
```

---

### #merge

`#merge(type_name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L52)

Includes all properties from another type.
Can be called multiple times to merge from multiple types.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `type_name` | `Symbol`, `nil` | `nil` | The type to merge from. |

</div>

**Returns**

`Array<Symbol>`

**Example**

```ruby
object :admin do
  merge :user
  boolean :superuser
end
```

---

### #number

`#number(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, max: nil, min: nil, nullable: false, optional: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L463)

Defines a number.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Numeric`, `nil` | `nil` | The example value. Metadata included in exports. |
| `max` | `Numeric`, `nil` | `nil` | The maximum value. |
| `min` | `Numeric`, `nil` | `nil` | The minimum value. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Coordinate value**

```ruby
number :latitude, min: -90, max: 90
```

---

### #number?

`#number?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, max: nil, min: nil, nullable: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L519)

Defines an optional number.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `Numeric`, `nil` | `nil` | The example value. Metadata included in exports. |
| `max` | `Numeric`, `nil` | `nil` | The maximum value. |
| `min` | `Numeric`, `nil` | `nil` | The minimum value. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional score**

```ruby
number? :score, min: 0, max: 100
```

---

### #object

`#object(name, as: nil, default: nil, deprecated: false, description: nil, nullable: false, optional: false, required: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1160)

Defines an object.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Nested address object**

```ruby
object :address do
  string :street
  string :city
  string :country
end
```

---

### #object?

`#object?(name, as: nil, default: nil, deprecated: false, description: nil, nullable: false, required: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1210)

Defines an optional object.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional metadata**

```ruby
object? :metadata do
  string :key
  string :value
end
```

---

### #param

`#param(name, type: nil, as: nil, default: nil, deprecated: false, description: nil, discriminator: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: false, of: nil, optional: false, required: false, shape: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L93)

Defines a param with explicit type.

This is the verbose form. Prefer sugar methods (string, integer, etc.)
for static definitions.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The param name. |
| `type` | `Symbol<:array, :binary, :boolean, :date, :datetime, :decimal, :integer, :literal, :number, :object, :string, :time, :union, :uuid>`, `nil` | `nil` | The param type. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `discriminator` | `Symbol`, `nil` | `nil` | The discriminator param name. Unions only. |
| `enum` | `Array`, `Symbol`, `nil` | `nil` | The allowed values or enum reference. |
| `example` | `Object`, `nil` | `nil` | The example value. Metadata included in exports. |
| `format` | `Symbol<:date, :datetime, :double, :email, :float, :hostname, :int32, :int64, :ipv4, :ipv6, :password, :url, :uuid>`, `nil` | `nil` | Format hint for exports. Does not change the type, but exports may add validation or documentation based on it. Valid formats by type: `:decimal`/`:number` (`:double`, `:float`), `:integer` (`:int32`, `:int64`), `:string` (`:date`, `:datetime`, `:email`, `:hostname`, `:ipv4`, `:ipv6`, `:password`, `:url`, `:uuid`). |
| `max` | `Integer`, `nil` | `nil` | The maximum. For `:array`: size. For `:decimal`, `:integer`, `:number`: value. For `:string`: length. |
| `min` | `Integer`, `nil` | `nil` | The minimum. For `:array`: size. For `:decimal`, `:integer`, `:number`: value. For `:string`: length. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `of` | `Symbol`, `Hash`, `nil` | `nil` | The element type. Arrays only. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |
| `shape` | `Contract::Object`, `Contract::Union`, `nil` | `nil` | The pre-built shape. |
| `value` | `Object`, `nil` | `nil` | The literal value. |

</div>

**Returns**

`void`

**Yields** [Contract::Object](/reference/contract/object), [Contract::Union](/reference/contract/union), [Contract::Element](/reference/contract/element)

**Example: Dynamic param generation**

```ruby
param_type = :string
param :title, type: param_type
```

**Example: Object with block**

```ruby
param :address, type: :object do
  string :street
  string :city
end
```

---

### #reference

`#reference(name, to: nil, as: nil, default: nil, deprecated: false, description: nil, nullable: false, optional: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1544)

Defines a reference to a named type.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `to` | `Symbol`, `nil` | `nil` | The target type name. Defaults to name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Reference to customer type**

```ruby
reference :customer
```

**Example: Reference with different param name**

```ruby
reference :billing_address, to: :address
```

---

### #reference?

`#reference?(name, to: nil, as: nil, default: nil, deprecated: false, description: nil, nullable: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1591)

Defines an optional reference to a named type.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `to` | `Symbol`, `nil` | `nil` | The target type name. Defaults to name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional shipping address**

```ruby
reference? :shipping_address, to: :address
```

---

### #string

`#string(name, as: nil, default: nil, deprecated: false, description: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: false, optional: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L97)

Defines a string.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `enum` | `Array`, `Symbol`, `nil` | `nil` | The allowed values. |
| `example` | `String`, `nil` | `nil` | The example value. Metadata included in exports. |
| `format` | `Symbol<:date, :datetime, :email, :hostname, :ipv4, :ipv6, :password, :url, :uuid>`, `nil` | `nil` | Format hint for exports. Does not change the type, but exports may add validation or documentation based on it. Valid formats by type: `:string`. |
| `max` | `Integer`, `nil` | `nil` | The maximum length. |
| `min` | `Integer`, `nil` | `nil` | The minimum length. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Basic string**

```ruby
string :name
```

**Example: With format validation**

```ruby
string :email, format: :email
```

**Example: With length constraints**

```ruby
string :title, min: 1, max: 100
```

---

### #string?

`#string?(name, as: nil, default: nil, deprecated: false, description: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L162)

Defines an optional string.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `enum` | `Array`, `Symbol`, `nil` | `nil` | The allowed values. |
| `example` | `String`, `nil` | `nil` | The example value. Metadata included in exports. |
| `format` | `Symbol<:date, :datetime, :email, :hostname, :ipv4, :ipv6, :password, :url, :uuid>`, `nil` | `nil` | Format hint for exports. Does not change the type, but exports may add validation or documentation based on it. Valid formats by type: `:string`. |
| `max` | `Integer`, `nil` | `nil` | The maximum length. |
| `min` | `Integer`, `nil` | `nil` | The minimum length. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional string with default**

```ruby
string? :nickname, default: 'Anonymous'
```

---

### #time

`#time(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L963)

Defines a time.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `String`, `nil` | `nil` | The example value. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Opening time**

```ruby
time :opens_at
```

---

### #time?

`#time?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1011)

Defines an optional time.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `String`, `nil` | `nil` | The example value. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional closing time**

```ruby
time? :closes_at
```

---

### #union

`#union(name, as: nil, default: nil, deprecated: false, description: nil, discriminator: nil, nullable: false, optional: false, required: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1386)

Defines a union.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `discriminator` | `Symbol`, `nil` | `nil` | The discriminator field name. Unions only. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Payment method union**

```ruby
union :payment_method, discriminator: :type do
  variant tag: 'card' do
    object do
      string :last_four
    end
  end
  variant tag: 'bank' do
    object do
      string :account_number
    end
  end
end
```

---

### #union?

`#union?(name, as: nil, default: nil, deprecated: false, description: nil, discriminator: nil, nullable: false, required: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1448)

Defines an optional union.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `discriminator` | `Symbol`, `nil` | `nil` | The discriminator field name. Unions only. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional notification preference**

```ruby
union? :notification, discriminator: :type do
  variant tag: 'email' do
    object do
      string :address
    end
  end
  variant tag: 'sms' do
    object do
      string :phone
    end
  end
end
```

---

### #uuid

`#uuid(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L866)

Defines a UUID.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `String`, `nil` | `nil` | The example value. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Primary key**

```ruby
uuid :id
```

---

### #uuid?

`#uuid?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L914)

Defines an optional UUID.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The name. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `example` | `String`, `nil` | `nil` | The example value. Metadata included in exports. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `required` | `Boolean` | `false` | Whether the param is required. |

</div>

**Returns**

`void`

**Example: Optional parent reference**

```ruby
uuid? :parent_id
```

---
