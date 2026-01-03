---
order: 47
prev: false
next: false
---

# Introspection::StringParam

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/string_param.rb#L14)

String param.

**Example**

```ruby
param.type    # => :string
param.format  # => :email, :uuid, :uri, :url, :ipv4, :ipv6, :hostname, :password
param.min     # => 1 (minimum string length)
param.max     # => 255 (maximum string length)
param.scalar? # => true
```

## Instance Methods

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L121)

**Returns**

`Boolean` — whether this is an array type

---

### #boundable?

`#boundable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/string_param.rb#L36)

**Returns**

`Boolean` — true - strings support min/max length constraints

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L97)

**Returns**

`Object`, `nil` — default value

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L103)

**Returns**

`Boolean` — whether a default value is defined

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L79)

**Returns**

`Boolean` — whether this field is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L85)

**Returns**

`String`, `nil` — field description

---

### #enum?

`#enum?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/scalar_param.rb#L14)

**Returns**

`Boolean` — whether this scalar has enum constraints

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L91)

**Returns**

`Object`, `nil` — example value

---

### #format

`#format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/string_param.rb#L18)

**Returns**

`Symbol`, `nil` — format constraint
Supported formats: :email, :uuid, :uri, :url, :ipv4, :ipv6, :hostname, :password

---

### #formattable?

`#formattable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/string_param.rb#L42)

**Returns**

`Boolean` — true - strings support format constraints

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L139)

**Returns**

`Boolean` — whether this is a literal type

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/string_param.rb#L30)

**Returns**

`Integer`, `nil` — maximum string length

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/string_param.rb#L24)

**Returns**

`Integer`, `nil` — minimum string length

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L67)

**Returns**

`Boolean` — whether this field can be null

---

### #numeric?

`#numeric?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L145)

**Returns**

`Boolean` — whether this is a numeric type (integer, float, decimal)

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L127)

**Returns**

`Boolean` — whether this is an object type

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L73)

**Returns**

`Boolean` — whether this field is optional

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/scalar_param.rb#L8)

**Returns**

`Boolean` — true for all scalar types

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L109)

**Returns**

`String`, `nil` — discriminator tag for union variants

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L163)

**Returns**

`Hash` — structured representation

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L61)

**Returns**

`Symbol`, `nil` — the parameter type
Scalar types: :string, :integer, :float, :decimal, :boolean,
:datetime, :date, :time, :uuid, :binary, :json, :unknown
Container types: :array, :object, :union, :literal
Reference types: any Symbol (custom type reference)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L133)

**Returns**

`Boolean` — whether this is a union type

---
