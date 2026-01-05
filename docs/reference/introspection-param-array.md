---
order: 32
prev: false
next: false
---

# Introspection::Param::Array

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L17)

Array param.

**Example**

```ruby
param.type       # => :array
param.of         # => Param or nil
param.shape      # => {} or { field: Param, ... }
param.min        # => 1 or nil
param.max        # => 10 or nil
param.array?     # => true
param.boundable? # => true
```

## Instance Methods

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L44)

**Returns**

[Boolean](introspection-boolean) — always true for Array

---

### #binary?

`#binary?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L171)

**Returns**

[Boolean](introspection-boolean) — whether this is a binary type

---

### #boolean?

`#boolean?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L141)

**Returns**

[Boolean](introspection-boolean) — whether this is a boolean type

---

### #boundable?

`#boundable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L50)

**Returns**

[Boolean](introspection-boolean) — true - arrays support min/max length constraints

---

### #date?

`#date?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L153)

**Returns**

[Boolean](introspection-boolean) — whether this is a date type

---

### #datetime?

`#datetime?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L147)

**Returns**

[Boolean](introspection-boolean) — whether this is a datetime type

---

### #decimal?

`#decimal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L135)

**Returns**

[Boolean](introspection-boolean) — whether this is a decimal type

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L51)

**Returns**

[Object](introspection-object), `nil` — default value

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L57)

**Returns**

[Boolean](introspection-boolean) — whether a default value is defined

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L33)

**Returns**

[Boolean](introspection-boolean) — whether this field is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L39)

**Returns**

[String](introspection-string), `nil` — field description

---

### #enum

`#enum`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L201)

**Returns**

[Array](introspection-array), `Symbol`, `nil` — inline values (Array) or ref name (Symbol)

---

### #enum?

`#enum?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L195)

**Returns**

[Boolean](introspection-boolean) — whether this param has enum constraints

---

### #enum_ref?

`#enum_ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L207)

**Returns**

[Boolean](introspection-boolean) — whether this is a reference to a named enum

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L45)

**Returns**

[Object](introspection-object), `nil` — example value

---

### #float?

`#float?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L129)

**Returns**

[Boolean](introspection-boolean) — whether this is a float type

---

### #formattable?

`#formattable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L111)

**Returns**

[Boolean](introspection-boolean) — whether this type supports format constraints

---

### #integer?

`#integer?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L123)

**Returns**

[Boolean](introspection-boolean) — whether this is an integer type

---

### #json?

`#json?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L177)

**Returns**

[Boolean](introspection-boolean) — whether this is a JSON type

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L93)

**Returns**

[Boolean](introspection-boolean) — whether this is a literal type

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L38)

**Returns**

[Integer](introspection-integer), `nil` — maximum array length

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L32)

**Returns**

[Integer](introspection-integer), `nil` — minimum array length

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L21)

**Returns**

[Boolean](introspection-boolean) — whether this field can be null

---

### #numeric?

`#numeric?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L99)

**Returns**

[Boolean](introspection-boolean) — whether this is a numeric type (integer, float, decimal)

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L81)

**Returns**

[Boolean](introspection-boolean) — whether this is an object type

---

### #of

`#of`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L20)

**Returns**

`Param::Base`, `nil` — element type for arrays

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L27)

**Returns**

[Boolean](introspection-boolean) — whether this field is optional

---

### #ref?

`#ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L189)

**Returns**

[Boolean](introspection-boolean) — whether this is a ref type

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L69)

**Returns**

[Boolean](introspection-boolean) — whether this is a scalar type

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L26)

**Returns**

`Hash{Symbol => Param::Base}` — nested fields for array-of-objects

---

### #string?

`#string?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L117)

**Returns**

[Boolean](introspection-boolean) — whether this is a string type

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L63)

**Returns**

[String](introspection-string), `nil` — discriminator tag for union variants

---

### #time?

`#time?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L159)

**Returns**

[Boolean](introspection-boolean) — whether this is a time type

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L56)

**Returns**

`Hash` — structured representation

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L15)

**Returns**

`Symbol` — the parameter type
:string, :integer, :float, :decimal, :boolean, :datetime, :date, :time,
:uuid, :binary, :json, :unknown, :array, :object, :union, :literal, :ref

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L87)

**Returns**

[Boolean](introspection-boolean) — whether this is a union type

---

### #unknown?

`#unknown?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L183)

**Returns**

[Boolean](introspection-boolean) — whether this is an unknown type

---

### #uuid?

`#uuid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L165)

**Returns**

[Boolean](introspection-boolean) — whether this is a UUID type

---
