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

`#array(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L170)

Defines an array param with element type.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | param name |
| `options` | `Hash` |  | additional param options |

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

`#array?(name, as: nil, default: nil, deprecated: false, description: nil, nullable: false, of: nil, required: false, store: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1069)

Defines an optional array.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `nullable` | `Boolean` | `false` |  |
| `of` | `Symbol`, `Hash`, `nil` | `nil` | element type |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #binary

`#binary(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L865)

Defines a binary.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `String`, `nil` | `nil` | example value |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #binary?

`#binary?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L905)

Defines an optional binary.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `String`, `nil` | `nil` | example value |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #boolean

`#boolean(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L465)

Defines a boolean.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `Boolean`, `nil` | `nil` | example value |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #boolean?

`#boolean?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L505)

Defines an optional boolean.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `Boolean`, `nil` | `nil` | example value |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #date

`#date(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L625)

Defines a date.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `String`, `nil` | `nil` | example value |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #date?

`#date?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L665)

Defines an optional date.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `String`, `nil` | `nil` | example value |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #datetime

`#datetime(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L545)

Defines a datetime.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `String`, `nil` | `nil` | example value |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #datetime?

`#datetime?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L585)

Defines an optional datetime.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `String`, `nil` | `nil` | example value |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #decimal

`#decimal(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, max: nil, min: nil, nullable: false, optional: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L283)

Defines a decimal.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `Numeric`, `nil` | `nil` | example value |
| `max` | `Numeric`, `nil` | `nil` | maximum value |
| `min` | `Numeric`, `nil` | `nil` | minimum value |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #decimal?

`#decimal?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, max: nil, min: nil, nullable: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L329)

Defines an optional decimal.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `Numeric`, `nil` | `nil` | example value |
| `max` | `Numeric`, `nil` | `nil` | maximum value |
| `min` | `Numeric`, `nil` | `nil` | minimum value |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #extends

`#extends(type_name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L33)

Inherits all properties from another type.
Can be called multiple times to inherit from multiple types.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `type_name` | `Symbol` |  | the type to inherit from |

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

`#integer(name, as: nil, default: nil, deprecated: false, description: nil, enum: nil, example: nil, max: nil, min: nil, nullable: false, optional: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L186)

Defines an integer.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `enum` | `Array`, `Symbol`, `nil` | `nil` | allowed values |
| `example` | `Integer`, `nil` | `nil` | example value |
| `max` | `Integer`, `nil` | `nil` | maximum value |
| `min` | `Integer`, `nil` | `nil` | minimum value |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #integer?

`#integer?(name, as: nil, default: nil, deprecated: false, description: nil, enum: nil, example: nil, max: nil, min: nil, nullable: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L235)

Defines an optional integer.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `enum` | `Array`, `Symbol`, `nil` | `nil` | allowed values |
| `example` | `Integer`, `nil` | `nil` | example value |
| `max` | `Integer`, `nil` | `nil` | maximum value |
| `min` | `Integer`, `nil` | `nil` | minimum value |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #literal

`#literal(name, value:, as: nil, default: nil, deprecated: false, description: nil, optional: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1195)

Defines a literal value.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `value` | `Object` |  | the exact value (required) |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `optional` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #merge!

`#merge!(type_name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L50)

Includes all properties from another type.
Can be called multiple times to merge from multiple types.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `type_name` | `Symbol` |  | the type to merge from |

**Returns**

`Array<Symbol>`

**Example**

```ruby
object :admin do
  merge! :user
  boolean :superuser
end
```

---

### #number

`#number(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, max: nil, min: nil, nullable: false, optional: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L375)

Defines a number.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `Numeric`, `nil` | `nil` | example value |
| `max` | `Numeric`, `nil` | `nil` | maximum value |
| `min` | `Numeric`, `nil` | `nil` | minimum value |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #number?

`#number?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, max: nil, min: nil, nullable: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L421)

Defines an optional number.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `Numeric`, `nil` | `nil` | example value |
| `max` | `Numeric`, `nil` | `nil` | maximum value |
| `min` | `Numeric`, `nil` | `nil` | minimum value |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #object

`#object(name, as: nil, default: nil, deprecated: false, description: nil, nullable: false, optional: false, required: false, store: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L945)

Defines an object.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #object?

`#object?(name, as: nil, default: nil, deprecated: false, description: nil, nullable: false, required: false, store: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L985)

Defines an optional object.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #param

`#param(name, type: nil, as: nil, default: nil, deprecated: false, description: nil, discriminator: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: false, of: nil, optional: false, required: false, shape: nil, store: nil, transform: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L78)

Defines a param with explicit type.

This is the verbose form. Prefer sugar methods (string, integer, etc.)
for static definitions.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | param name |
| `type` | `Symbol`, `nil` | `nil` | param type |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `discriminator` | `Symbol`, `nil` | `nil` | discriminator param name (unions only) |
| `enum` | `Array`, `Symbol`, `nil` | `nil` | allowed values or enum reference |
| `example` | `Object`, `nil` | `nil` | example value |
| `format` | `Symbol`, `nil` | `nil` | format hint |
| `max` | `Integer`, `nil` | `nil` | maximum value or length |
| `min` | `Integer`, `nil` | `nil` | minimum value or length |
| `nullable` | `Boolean` | `false` |  |
| `of` | `Symbol`, `Hash`, `nil` | `nil` | element type (arrays only) |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `shape` | `Contract::Object`, `Contract::Union`, `nil` | `nil` | pre-built shape |
| `store` | `Boolean`, `nil` | `nil` | whether to persist |
| `transform` | `Proc`, `nil` | `nil` | value transformation lambda |
| `value` | `Object`, `nil` | `nil` | literal value |

**Returns**

`void`

**Yields** [Contract::Object](/reference/contract/object), [Contract::Union](/reference/contract/union), [Contract::Element](/reference/contract/element)

**Example: Object with block (instance_eval style)**

```ruby
param :address, type: :object do
  string :street
  string :city
end
```

**Example: Object with block (yield style)**

```ruby
param :address, type: :object do |address|
  address.string :street
  address.string :city
end
```

---

### #reference

`#reference(name, to: nil, as: nil, default: nil, deprecated: false, description: nil, nullable: false, optional: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1232)

Defines a reference to a named type.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `to` | `Symbol`, `nil` | `nil` | target type name (defaults to name) |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #reference?

`#reference?(name, to: nil, as: nil, default: nil, deprecated: false, description: nil, nullable: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1271)

Defines an optional reference to a named type.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `to` | `Symbol`, `nil` | `nil` | target type name (defaults to name) |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #string

`#string(name, as: nil, default: nil, deprecated: false, description: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: false, optional: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L83)

Defines a string.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `enum` | `Array`, `Symbol`, `nil` | `nil` | allowed values |
| `example` | `String`, `nil` | `nil` | example value |
| `format` | `Symbol`, `nil` | `nil` | format hint (:email, :uri, :uuid) |
| `max` | `Integer`, `nil` | `nil` | maximum length |
| `min` | `Integer`, `nil` | `nil` | minimum length |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #string?

`#string?(name, as: nil, default: nil, deprecated: false, description: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L135)

Defines an optional string.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `enum` | `Array`, `Symbol`, `nil` | `nil` | allowed values |
| `example` | `String`, `nil` | `nil` | example value |
| `format` | `Symbol`, `nil` | `nil` | format hint (:email, :uri, :uuid) |
| `max` | `Integer`, `nil` | `nil` | maximum length |
| `min` | `Integer`, `nil` | `nil` | minimum length |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #time

`#time(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L785)

Defines a time.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `String`, `nil` | `nil` | example value |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #time?

`#time?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L825)

Defines an optional time.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `String`, `nil` | `nil` | example value |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #union

`#union(name, as: nil, default: nil, deprecated: false, description: nil, discriminator: nil, nullable: false, optional: false, required: false, store: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1112)

Defines a union.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `discriminator` | `Symbol`, `nil` | `nil` | discriminator field name |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #union?

`#union?(name, as: nil, default: nil, deprecated: false, description: nil, discriminator: nil, nullable: false, required: false, store: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1155)

Defines an optional union.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `discriminator` | `Symbol`, `nil` | `nil` | discriminator field name |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #uuid

`#uuid(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L705)

Defines a UUID.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `String`, `nil` | `nil` | example value |
| `nullable` | `Boolean` | `false` |  |
| `optional` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #uuid?

`#uuid?(name, as: nil, default: nil, deprecated: false, description: nil, example: nil, nullable: false, required: false, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L745)

Defines an optional UUID.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the name |
| `as` | `Symbol`, `nil` | `nil` | target attribute name |
| `default` | `Object`, `nil` | `nil` | default value |
| `deprecated` | `Boolean` | `false` |  |
| `description` | `String`, `nil` | `nil` | documentation description |
| `example` | `String`, `nil` | `nil` | example value |
| `nullable` | `Boolean` | `false` |  |
| `required` | `Boolean` | `false` |  |
| `store` | `Object`, `nil` | `nil` | value to persist (replaces received value) |

**Returns**

`void`

---
