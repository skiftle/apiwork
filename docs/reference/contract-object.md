---
order: 24
prev: false
next: false
---

# Contract::Object

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1025)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L821)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L861)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L421)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L461)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L581)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L621)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L501)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L541)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L239)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L285)

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

### #integer

`#integer(name, as: nil, default: nil, deprecated: nil, description: nil, enum: nil, example: nil, max: nil, min: nil, nullable: nil, optional: nil, required: nil, store: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L142)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L191)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1151)

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

`#merge!(other)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L16)

Merges params from another object into this one.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | `Apiwork::Object` | the object to merge from |

**Returns**

`self`

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L331)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L377)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L901)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L941)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1188)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1227)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L39)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L91)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L741)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L781)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1068)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L1111)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L661)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/object.rb#L701)

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
