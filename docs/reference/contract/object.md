---
order: 41
prev: false
next: false
---

# Object

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L23)

Block context for defining request/response structure.

Accessed via `body do`, `query do`, or `object :x do`
inside contract actions. Use type methods to define fields.

**Example: Request body**

```ruby
body do
  string :title
  decimal :amount
end
```

**Example: Inline nested object**

```ruby
object :customer do
  string :name
end
```

## Instance Methods

### #array?

`#array?(name, as: nil, default: nil, deprecated: nil, description: nil, nullable: nil, of: nil, required: nil, store: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1069)

Defines an optional array.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `of` | `Symbol, Hash, nil` | element type |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #binary

`#binary(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L865)

Defines a binary.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `String, nil` | example value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #binary?

`#binary?(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L905)

Defines an optional binary.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `String, nil` | example value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #boolean

`#boolean(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L465)

Defines a boolean.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `Boolean, nil` | example value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #boolean?

`#boolean?(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L505)

Defines an optional boolean.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `Boolean, nil` | example value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #date

`#date(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L625)

Defines a date.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `String, nil` | example value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #date?

`#date?(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L665)

Defines an optional date.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `String, nil` | example value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #datetime

`#datetime(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L545)

Defines a datetime.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `String, nil` | example value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #datetime?

`#datetime?(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L585)

Defines an optional datetime.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `String, nil` | example value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #decimal

`#decimal(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, max: nil, min: nil, nullable: nil, optional: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L283)

Defines a decimal.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `Numeric, nil` | example value |
| `max` | `Numeric, nil` | maximum value |
| `min` | `Numeric, nil` | minimum value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #decimal?

`#decimal?(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, max: nil, min: nil, nullable: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L329)

Defines an optional decimal.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `Numeric, nil` | example value |
| `max` | `Numeric, nil` | maximum value |
| `min` | `Numeric, nil` | minimum value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #extends

`#extends(type_name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L33)

Inherits all properties from another type.
Can be called multiple times to inherit from multiple types.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `Symbol` | the type to inherit from |

**Returns**

`Array<Symbol>` — the inherited types

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

`#integer(name, as: nil, default: nil, deprecated: nil, description: nil, enum: nil, example: nil, max: nil, min: nil, nullable: nil, optional: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L186)

Defines an integer.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `enum` | `Array, Symbol, nil` | allowed values |
| `example` | `Integer, nil` | example value |
| `max` | `Integer, nil` | maximum value |
| `min` | `Integer, nil` | minimum value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #integer?

`#integer?(name, as: nil, default: nil, deprecated: nil, description: nil, enum: nil, example: nil, max: nil, min: nil, nullable: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L235)

Defines an optional integer.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `enum` | `Array, Symbol, nil` | allowed values |
| `example` | `Integer, nil` | example value |
| `max` | `Integer, nil` | maximum value |
| `min` | `Integer, nil` | minimum value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #literal

`#literal(name, value:, as: nil, default: nil, deprecated: nil, description: nil, optional: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1195)

Defines a literal value.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `value` | `Object` | the exact value (required) |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #merge!

`#merge!(type_name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L50)

Includes all properties from another type.
Can be called multiple times to merge from multiple types.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `Symbol` | the type to merge from |

**Returns**

`Array<Symbol>` — the merged types

**Example**

```ruby
object :admin do
  merge! :user
  boolean :superuser
end
```

---

### #meta

`#meta(optional: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L170)

Shorthand for `object :meta do ... end`.

Use for response data that doesn't belong to the resource itself.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `optional` | `Boolean` | whether meta can be omitted (default: false) |

---

### #number

`#number(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, max: nil, min: nil, nullable: nil, optional: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L375)

Defines a number.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `Numeric, nil` | example value |
| `max` | `Numeric, nil` | maximum value |
| `min` | `Numeric, nil` | minimum value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #number?

`#number?(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, max: nil, min: nil, nullable: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L421)

Defines an optional number.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `Numeric, nil` | example value |
| `max` | `Numeric, nil` | maximum value |
| `min` | `Numeric, nil` | minimum value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #object

`#object(name, as: nil, default: nil, deprecated: nil, description: nil, nullable: nil, optional: nil, required: nil, store: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L945)

Defines an object.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #object?

`#object?(name, as: nil, default: nil, deprecated: nil, description: nil, nullable: nil, required: nil, store: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L985)

Defines an optional object.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #param

`#param(name, type: nil, as: nil, default: nil, deprecated: nil, description: nil, discriminator: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: nil, of: nil, optional: nil, required: nil, shape: nil, store: nil, transform: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L65)

Defines a field with explicit type.

This is the verbose form. Prefer sugar methods (string, integer, etc.)
for static definitions. Use `param` for dynamic field generation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `type` | `Symbol, nil` | field type |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `discriminator` | `Symbol, nil` | discriminator field name (unions only) |
| `enum` | `Array, Symbol, nil` | allowed values or enum reference |
| `example` | `Object, nil` | example value |
| `format` | `Symbol, nil` | format hint |
| `max` | `Integer, nil` | maximum value or length |
| `min` | `Integer, nil` | minimum value or length |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `of` | `Symbol, Hash, nil` | element type (arrays only) |
| `optional` | `Boolean, nil` | whether field can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `shape` | `Contract::Object, Contract::Union, nil` | pre-built shape |
| `store` | `Boolean, nil` | whether to persist |
| `transform` | `Proc, nil` | value transformation lambda |
| `value` | `Object, nil` | literal value |

**Returns**

`void`

---

### #reference

`#reference(name, to: nil, as: nil, default: nil, deprecated: nil, description: nil, nullable: nil, optional: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1232)

Defines a reference to a named type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `to` | `Symbol, nil` | target type name (defaults to name) |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #reference?

`#reference?(name, to: nil, as: nil, default: nil, deprecated: nil, description: nil, nullable: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1271)

Defines an optional reference to a named type.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `to` | `Symbol, nil` | target type name (defaults to name) |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #string

`#string(name, as: nil, default: nil, deprecated: nil, description: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: nil, optional: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L83)

Defines a string.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `enum` | `Array, Symbol, nil` | allowed values |
| `example` | `String, nil` | example value |
| `format` | `Symbol, nil` | format hint (:email, :uri, :uuid) |
| `max` | `Integer, nil` | maximum length |
| `min` | `Integer, nil` | minimum length |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #string?

`#string?(name, as: nil, default: nil, deprecated: nil, description: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L135)

Defines an optional string.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `enum` | `Array, Symbol, nil` | allowed values |
| `example` | `String, nil` | example value |
| `format` | `Symbol, nil` | format hint (:email, :uri, :uuid) |
| `max` | `Integer, nil` | maximum length |
| `min` | `Integer, nil` | minimum length |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #time

`#time(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L785)

Defines a time.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `String, nil` | example value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #time?

`#time?(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L825)

Defines an optional time.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `String, nil` | example value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #union

`#union(name, as: nil, default: nil, deprecated: nil, description: nil, discriminator: nil, nullable: nil, optional: nil, required: nil, store: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1112)

Defines a union.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `discriminator` | `Symbol, nil` | discriminator field name |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #union?

`#union?(name, as: nil, default: nil, deprecated: nil, description: nil, discriminator: nil, nullable: nil, required: nil, store: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1155)

Defines an optional union.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `discriminator` | `Symbol, nil` | discriminator field name |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #uuid

`#uuid(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, optional: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L705)

Defines a UUID.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `String, nil` | example value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `optional` | `Boolean, nil` | whether it can be omitted |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---

### #uuid?

`#uuid?(name, as: nil, default: nil, deprecated: nil, description: nil, example: nil, nullable: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L745)

Defines an optional UUID.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the name |
| `as` | `Symbol, nil` | target attribute name |
| `default` | `Object, nil` | default value |
| `deprecated` | `Boolean, nil` | mark as deprecated |
| `description` | `String, nil` | documentation description |
| `example` | `String, nil` | example value |
| `nullable` | `Boolean, nil` | whether null is allowed |
| `required` | `Boolean, nil` | explicit required flag |
| `store` | `Object, nil` | value to persist (replaces received value) |

**Returns**

`void`

---
