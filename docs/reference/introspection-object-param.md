---
order: 43
prev: false
next: false
---

# Introspection::ObjectParam

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/object_param.rb#L13)

Object param.

**Example**

```ruby
param.type      # => :object
param.shape     # => { name: Param, email: Param }
param.partial?  # => true for update payloads
param.object?   # => true
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L151)

**Returns**

`Boolean` — whether this type supports min/max constraints

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

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L91)

**Returns**

`Object`, `nil` — example value

---

### #formattable?

`#formattable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L157)

**Returns**

`Boolean` — whether this type supports format constraints

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L139)

**Returns**

`Boolean` — whether this is a literal type

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/object_param.rb#L28)

**Returns**

`Boolean` — always true for ObjectParam

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L73)

**Returns**

`Boolean` — whether this field is optional

---

### #partial?

`#partial?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/object_param.rb#L22)

**Returns**

`Boolean` — whether this object is partial (for update payloads)

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L115)

**Returns**

`Boolean` — whether this is a scalar type

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/object_param.rb#L16)

**Returns**

`Hash{Symbol => Param}` — nested fields

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L109)

**Returns**

`String`, `nil` — discriminator tag for union variants

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/object_param.rb#L34)

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
