---
order: 32
prev: false
next: false
---

# Introspection::Param

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L24)

Wraps parameter/field definitions.

Used for request params, response bodies, type shapes, and more.
Provides type-safe accessors with built-in defaults.

**Example: Basic usage**

```ruby
param.type         # => :string
param.nullable?    # => false
param.optional?    # => true
param.description  # => "User email address"
```

**Example: Array type**

```ruby
param.array?       # => true
param.of           # => Param for element type
```

**Example: Object type**

```ruby
param.object?      # => true
param.shape[:name] # => Param for the name field
```

## Instance Methods

### #\[\]

`#\[\](key)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L172)

Access raw data for edge cases not covered by accessors.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `Symbol` | the data key to access |

**Returns**

`Object`, `nil` — the raw value

---

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L37)

**Returns**

`Boolean` — whether this is an array type

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L151)

**Returns**

`Object`, `nil` — default value

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L157)

**Returns**

`Boolean` — whether a default value is defined

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L115)

**Returns**

`Boolean` — whether this field is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L121)

**Returns**

`String`, `nil` — field description

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L85)

**Returns**

`Symbol`, `nil` — discriminator field for discriminated unions

---

### #enum

`#enum`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L97)

**Returns**

`Symbol`, `Array`, `nil` — enum name reference or inline values

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L127)

**Returns**

`Object`, `nil` — example value

---

### #format

`#format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L133)

**Returns**

`Symbol`, `nil` — format hint (e.g., :uuid, :email)

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L55)

**Returns**

`Boolean` — whether this is a literal type

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L145)

**Returns**

`Integer`, `nil` — maximum value for numeric types

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L139)

**Returns**

`Integer`, `nil` — minimum value for numeric types

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L103)

**Returns**

`Boolean` — whether this field can be null

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L43)

**Returns**

`Boolean` — whether this is an object type

---

### #of

`#of`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L61)

**Returns**

[Param](introspection-param), `nil` — element type for arrays

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L109)

**Returns**

`Boolean` — whether this field is optional

---

### #partial?

`#partial?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L163)

**Returns**

`Boolean` — whether this param is partial (for update payloads)

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L73)

**Returns**

`Hash{Symbol => Param}` — nested fields for objects

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L178)

**Returns**

`Hash` — structured representation

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L31)

**Returns**

`Symbol`, `nil` — type (:string, :integer, :array, :object, :union, etc.)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L49)

**Returns**

`Boolean` — whether this is a union type

---

### #value

`#value`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L91)

**Returns**

`Object`, `nil` — literal value

---

### #variants

`#variants`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L79)

**Returns**

`Array<Param>` — variants for unions

---
