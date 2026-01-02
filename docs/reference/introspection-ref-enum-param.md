---
order: 46
prev: false
next: false
---

# Introspection::RefEnumParam

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/ref_enum_param.rb#L14)

Param subclass for enum references.

**Example**

```ruby
param.type    # => :string (base type)
param.enum    # => :status (enum name symbol)
param.scalar? # => true
param.enum?   # => true
param.ref?    # => true
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

### #enum

`#enum`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum_param.rb#L37)

**Returns**

`Symbol`, `Array` — enum reference or inline values

---

### #enum?

`#enum?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum_param.rb#L19)

**Returns**

`Boolean` — true for all enum types

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L88)

**Returns**

`Object`, `nil` — example value

---

### #inline?

`#inline?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum_param.rb#L31)

**Returns**

`Boolean` — whether this has inline enum values

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L136)

**Returns**

`Boolean` — whether this is a literal type

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

### #ref?

`#ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/ref_enum_param.rb#L17)

**Returns**

`Boolean` — always true for RefEnumParam

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/scalar_param.rb#L17)

**Returns**

`Boolean` — true for all scalar types

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param.rb#L106)

**Returns**

`String`, `nil` — discriminator tag for union variants

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum_param.rb#L43)

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
