---
order: 8
prev: false
next: false
---

# Object

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L26)

Block context for defining reusable object types.

Accessed via `object :name do` in API or contract definitions.
Use type methods to define fields: [#string](#string), [#integer](#integer), [#decimal](#decimal),
[#boolean](#boolean), [#array](#array), [#object](#object), [#union](#union), [#reference](#reference).

**Example: instance_eval style**

```ruby
object :item do
  string :description
  decimal :amount
end
```

**Example: yield style**

```ruby
object :item do |object|
  object.string :description
  object.decimal :amount
end
```

## Instance Methods

### #array

`#array(name, as: nil, default: nil, deprecated: false, description: nil, nullable: false, optional: false, required: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L176)

Defines an array field with element type.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The field name. |
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

**Yields** [API::Element](/reference/api/element)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1331)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1068)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1116)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L583)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L631)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L777)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L825)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L680)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L728)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L358)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L414)

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
| **`type_name`** | `Symbol` |  | The type to inherit from. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L236)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L296)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1503)

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
| **`type_name`** | `Symbol` |  | The type to merge from. |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L471)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L527)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1168)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1218)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/object.rb#L85)

Defines a field with explicit type.

This is the verbose form. Prefer sugar methods (string, integer, etc.)
for static definitions. Use `param` for dynamic field generation.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The field name. |
| `type` | `Symbol<:array, :binary, :boolean, :date, :datetime, :decimal, :integer, :literal, :number, :object, :string, :time, :union, :uuid>`, `nil` | `nil` | The field type. |
| `as` | `Symbol`, `nil` | `nil` | The target attribute name. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `deprecated` | `Boolean` | `false` | Whether deprecated. Metadata included in exports. |
| `description` | `String`, `nil` | `nil` | The description. Metadata included in exports. |
| `discriminator` | `Symbol`, `nil` | `nil` | The discriminator field name. Unions only. |
| `enum` | `Array`, `nil` | `nil` | The allowed values. |
| `example` | `Object`, `nil` | `nil` | The example value. Metadata included in exports. |
| `format` | `Symbol<:date, :datetime, :email, :hostname, :ipv4, :ipv6, :password, :url, :uuid>`, `nil` | `nil` | Format hint for exports. Does not change the type, but exports may add validation or documentation based on it. Strings only. |
| `max` | `Integer`, `nil` | `nil` | The maximum. For `:array`: size. For `:decimal`, `:integer`, `:number`: value. For `:string`: length. |
| `min` | `Integer`, `nil` | `nil` | The minimum. For `:array`: size. For `:decimal`, `:integer`, `:number`: value. For `:string`: length. |
| `nullable` | `Boolean` | `false` | Whether the value can be `null`. |
| `of` | `Symbol`, `Hash`, `nil` | `nil` | The element type. Arrays only. |
| `optional` | `Boolean` | `false` | Whether the param is optional. |
| `required` | `Boolean` | `false` | Whether the param is required. |
| `shape` | `API::Object`, `API::Union`, `nil` | `nil` | The pre-built shape. |
| `value` | `Object`, `nil` | `nil` | The literal value. |

</div>

**Returns**

`void`

**Yields** [API::Object](/reference/api/object), [API::Union](/reference/api/union), [API::Element](/reference/api/element)

**Example: Object with block (instance_eval style)**

```ruby
param :metadata, type: :object do
  string :key
  string :value
end
```

**Example: Object with block (yield style)**

```ruby
param :metadata, type: :object do |metadata|
  metadata.string :key
  metadata.string :value
end
```

---

### #reference

`#reference(name, to: nil, as: nil, default: nil, deprecated: false, description: nil, nullable: false, optional: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1552)

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

**Example: Reference with different field name**

```ruby
reference :billing_address, to: :address
```

---

### #reference?

`#reference?(name, to: nil, as: nil, default: nil, deprecated: false, description: nil, nullable: false, required: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1599)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L106)

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
| `format` | `Symbol<:date, :datetime, :email, :hostname, :ipv4, :ipv6, :password, :url, :uuid>`, `nil` | `nil` | Format hint for exports. Does not change the type, but exports may add validation or documentation based on it. |
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L170)

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
| `format` | `Symbol<:date, :datetime, :email, :hostname, :ipv4, :ipv6, :password, :url, :uuid>`, `nil` | `nil` | Format hint for exports. Does not change the type, but exports may add validation or documentation based on it. |
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L971)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1019)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1394)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1456)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L874)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L922)

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
