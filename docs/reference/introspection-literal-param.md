---
order: 42
prev: false
next: false
---

# Introspection::LiteralParam

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/literal_param.rb#L12)

Literal param.

**Example**

```ruby
param.type     # => :literal
param.value    # => "active" or 42 or true
param.literal? # => true
```

## Instance Methods

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L122)

**Returns**

`Boolean` — whether this is an array type

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L98)

**Returns**

`Object`, `nil` — default value

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L104)

**Returns**

`Boolean` — whether a default value is defined

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L80)

**Returns**

`Boolean` — whether this field is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L86)

**Returns**

`String`, `nil` — field description

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L92)

**Returns**

`Object`, `nil` — example value

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/literal_param.rb#L21)

**Returns**

`Boolean` — always true for LiteralParam

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L68)

**Returns**

`Boolean` — whether this field can be null

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L128)

**Returns**

`Boolean` — whether this is an object type

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L74)

**Returns**

`Boolean` — whether this field is optional

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L116)

**Returns**

`Boolean` — whether this is a scalar type

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L110)

**Returns**

`String`, `nil` — discriminator tag for union variants

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/literal_param.rb#L27)

**Returns**

`Hash` — structured representation

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L62)

**Returns**

`Symbol`, `nil` — the parameter type
Scalar types: :string, :integer, :float, :decimal, :boolean,
:datetime, :date, :time, :uuid, :binary, :json, :unknown
Container types: :array, :object, :union, :literal
Reference types: any Symbol (custom type reference)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L134)

**Returns**

`Boolean` — whether this is a union type

---

### #value

`#value`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/literal_param.rb#L15)

**Returns**

`Object`, `nil` — literal value

---
