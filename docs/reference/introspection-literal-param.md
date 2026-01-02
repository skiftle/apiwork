---
order: 43
prev: false
next: false
---

# Introspection::LiteralParam

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/literal_param.rb#L12)

Param subclass for literal types.

**Example**

```ruby
param.type     # => :literal
param.value    # => "active" or 42 or true
param.literal? # => true
```

## Instance Methods

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L118)

**Returns**

`Boolean` — whether this is an array type

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

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L88)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L64)

**Returns**

`Boolean` — whether this field can be null

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L124)

**Returns**

`Boolean` — whether this is an object type

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L70)

**Returns**

`Boolean` — whether this field is optional

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L112)

**Returns**

`Boolean` — whether this is a scalar type

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L106)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L58)

**Returns**

`Symbol`, `nil` — type (:string, :integer, :array, :object, :union, etc.)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L130)

**Returns**

`Boolean` — whether this is a union type

---

### #value

`#value`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/literal_param.rb#L15)

**Returns**

`Object`, `nil` — literal value

---
