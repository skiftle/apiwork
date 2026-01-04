---
order: 48
prev: false
next: false
---

# Introspection::Param::Scalar::String

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/scalar/string.rb#L19)

String param.

**Example**

```ruby
param.type         # => :string
param.format       # => :email or nil
param.min          # => 1 or nil
param.max          # => 255 or nil
param.scalar?      # => true
param.string?      # => true
param.boundable?   # => true
param.formattable? # => true
```

## Instance Methods

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L92)

**Returns**

[Boolean](introspection-boolean) — whether this is an array type

---

### #binary?

`#binary?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L188)

**Returns**

[Boolean](introspection-boolean) — whether this is a binary type

---

### #boolean?

`#boolean?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L158)

**Returns**

[Boolean](introspection-boolean) — whether this is a boolean type

---

### #boundable?

`#boundable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/scalar/string.rb#L41)

**Returns**

[Boolean](introspection-boolean) — true - strings support min/max length constraints

---

### #date?

`#date?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L170)

**Returns**

[Boolean](introspection-boolean) — whether this is a date type

---

### #datetime?

`#datetime?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L164)

**Returns**

[Boolean](introspection-boolean) — whether this is a datetime type

---

### #decimal?

`#decimal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L152)

**Returns**

[Boolean](introspection-boolean) — whether this is a decimal type

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L68)

**Returns**

[Object](introspection-object), `nil` — default value

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L74)

**Returns**

[Boolean](introspection-boolean) — whether a default value is defined

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L50)

**Returns**

[Boolean](introspection-boolean) — whether this field is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L56)

**Returns**

[String](introspection-string), `nil` — field description

---

### #enum?

`#enum?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/scalar.rb#L15)

**Returns**

[Boolean](introspection-boolean) — whether this scalar has enum constraints

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L62)

**Returns**

[Object](introspection-object), `nil` — example value

---

### #float?

`#float?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L146)

**Returns**

[Boolean](introspection-boolean) — whether this is a float type

---

### #format

`#format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/scalar/string.rb#L23)

**Returns**

`Symbol`, `nil` — format constraint
Supported formats: :email, :uuid, :uri, :url, :ipv4, :ipv6, :hostname, :password

---

### #formattable?

`#formattable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/scalar/string.rb#L47)

**Returns**

[Boolean](introspection-boolean) — true - strings support format constraints

---

### #integer?

`#integer?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L140)

**Returns**

[Boolean](introspection-boolean) — whether this is an integer type

---

### #json?

`#json?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L194)

**Returns**

[Boolean](introspection-boolean) — whether this is a JSON type

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L110)

**Returns**

[Boolean](introspection-boolean) — whether this is a literal type

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/scalar/string.rb#L35)

**Returns**

[Integer](introspection-integer), `nil` — maximum string length

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/scalar/string.rb#L29)

**Returns**

[Integer](introspection-integer), `nil` — minimum string length

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L38)

**Returns**

[Boolean](introspection-boolean) — whether this field can be null

---

### #numeric?

`#numeric?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L116)

**Returns**

[Boolean](introspection-boolean) — whether this is a numeric type (integer, float, decimal)

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L98)

**Returns**

[Boolean](introspection-boolean) — whether this is an object type

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L44)

**Returns**

[Boolean](introspection-boolean) — whether this field is optional

---

### #ref_type?

`#ref_type?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L206)

**Returns**

[Boolean](introspection-boolean) — whether this is a type reference

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/scalar.rb#L9)

**Returns**

[Boolean](introspection-boolean) — true for all scalar types

---

### #string?

`#string?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/scalar/string.rb#L53)

**Returns**

[Boolean](introspection-boolean) — true for string params

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L80)

**Returns**

[String](introspection-string), `nil` — discriminator tag for union variants

---

### #time?

`#time?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L176)

**Returns**

[Boolean](introspection-boolean) — whether this is a time type

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/scalar/string.rb#L59)

**Returns**

`Hash` — structured representation

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L32)

**Returns**

`Symbol`, `nil` — the parameter type
Scalar types: :string, :integer, :float, :decimal, :boolean,
:datetime, :date, :time, :uuid, :binary, :json, :unknown
Container types: :array, :object, :union, :literal
Reference types: any Symbol (custom type reference)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L104)

**Returns**

[Boolean](introspection-boolean) — whether this is a union type

---

### #unknown?

`#unknown?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L200)

**Returns**

[Boolean](introspection-boolean) — whether this is an unknown type

---

### #uuid?

`#uuid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L182)

**Returns**

[Boolean](introspection-boolean) — whether this is a UUID type

---
