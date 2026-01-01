---
order: 31
prev: false
next: false
---

# Spec::Data::Param

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L25)

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
param.of           # => :string or { type: :object, shape: {...} }
```

**Example: Object type**

```ruby
param.object?      # => true
param.shape[:name] # => Param for the name field
```

## Instance Methods

### #\[\]

`#\[\](key)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L167)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L38)

**Returns**

`Boolean` — whether this is an array type

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L146)

**Returns**

`Object`, `nil` — default value

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L152)

**Returns**

`Boolean` — whether a default value is defined

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L110)

**Returns**

`Boolean` — whether this field is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L116)

**Returns**

`String`, `nil` — field description

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L80)

**Returns**

`Symbol`, `nil` — discriminator field for discriminated unions

---

### #enum

`#enum`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L92)

**Returns**

`Symbol`, `Array`, `nil` — enum name reference or inline values

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L122)

**Returns**

`Object`, `nil` — example value

---

### #format

`#format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L128)

**Returns**

`Symbol`, `nil` — format hint (e.g., :uuid, :email)

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L56)

**Returns**

`Boolean` — whether this is a literal type

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L140)

**Returns**

`Integer`, `nil` — maximum value for numeric types

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L134)

**Returns**

`Integer`, `nil` — minimum value for numeric types

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L98)

**Returns**

`Boolean` — whether this field can be null

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L44)

**Returns**

`Boolean` — whether this is an object type

---

### #of

`#of`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L62)

**Returns**

`Symbol`, `Hash`, `nil` — element type for arrays

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L104)

**Returns**

`Boolean` — whether this field is optional

---

### #partial?

`#partial?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L158)

**Returns**

`Boolean` — whether this param is partial (for update payloads)

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L68)

**Returns**

`Hash{Symbol => Param}` — nested fields for objects

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L173)

**Returns**

`Hash` — the raw underlying data hash

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L32)

**Returns**

`Symbol`, `nil` — type (:string, :integer, :array, :object, :union, etc.)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L50)

**Returns**

`Boolean` — whether this is a union type

---

### #value

`#value`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L86)

**Returns**

`Object`, `nil` — literal value

---

### #variants

`#variants`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/param.rb#L74)

**Returns**

`Array<Hash>` — variants for unions

---
