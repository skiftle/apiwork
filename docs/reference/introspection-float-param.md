---
order: 39
prev: false
next: false
---

# Introspection::FloatParam

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/float_param.rb#L13)

Param subclass for float types.

**Example**

```ruby
param.type   # => :float
param.min    # => 0.0
param.max    # => 100.0
param.float? # => true
```

## Instance Methods

### #\[\]

`#\[\](key)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L109)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L189)

**Returns**

`Boolean` — whether this is an array type

---

### #binary?

`#binary?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L171)

**Returns**

`Boolean` — whether this is a binary type

---

### #boolean?

`#boolean?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L141)

**Returns**

`Boolean` — whether this is a boolean type

---

### #date?

`#date?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L153)

**Returns**

`Boolean` — whether this is a date type

---

### #datetime?

`#datetime?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L147)

**Returns**

`Boolean` — whether this is a datetime type

---

### #decimal?

`#decimal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L135)

**Returns**

`Boolean` — whether this is a decimal type

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L94)

**Returns**

`Object`, `nil` — default value

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L100)

**Returns**

`Boolean` — whether a default value is defined

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L76)

**Returns**

`Boolean` — whether this field is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L82)

**Returns**

`String`, `nil` — field description

---

### #enum_ref?

`#enum_ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L219)

**Returns**

`Boolean` — whether this is an enum reference

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L88)

**Returns**

`Object`, `nil` — example value

---

### #float?

`#float?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/float_param.rb#L28)

**Returns**

`Boolean` — always true for FloatParam

---

### #inline_enum?

`#inline_enum?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L225)

**Returns**

`Boolean` — whether this is an inline enum

---

### #integer?

`#integer?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L123)

**Returns**

`Boolean` — whether this is an integer type

---

### #json?

`#json?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L177)

**Returns**

`Boolean` — whether this is a json type

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L207)

**Returns**

`Boolean` — whether this is a literal type

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/float_param.rb#L22)

**Returns**

`Numeric`, `nil` — maximum value

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/float_param.rb#L16)

**Returns**

`Numeric`, `nil` — minimum value

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L64)

**Returns**

`Boolean` — whether this field can be null

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L195)

**Returns**

`Boolean` — whether this is an object type

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L70)

**Returns**

`Boolean` — whether this field is optional

---

### #string?

`#string?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L117)

**Returns**

`Boolean` — whether this is a string type

---

### #time?

`#time?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L159)

**Returns**

`Boolean` — whether this is a time type

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/float_param.rb#L34)

**Returns**

`Hash` — structured representation

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L58)

**Returns**

`Symbol`, `nil` — type (:string, :integer, :array, :object, :union, etc.)

---

### #type_ref?

`#type_ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L213)

**Returns**

`Boolean` — whether this is a type reference

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L201)

**Returns**

`Boolean` — whether this is a union type

---

### #unknown?

`#unknown?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L183)

**Returns**

`Boolean` — whether this is an unknown type

---

### #uuid?

`#uuid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L165)

**Returns**

`Boolean` — whether this is a uuid type

---
