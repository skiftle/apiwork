---
order: 45
prev: false
next: false
---

# Introspection::Param::String

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/string.rb#L26)

String param representing text values.

**Example: Basic usage**

```ruby
param.type         # => :string
param.scalar?      # => true
param.string?      # => true
```

**Example: Constraints**

```ruby
param.min          # => 1 or nil
param.max          # => 255 or nil
param.format       # => :email or nil
param.boundable?   # => true
param.formattable? # => true
```

**Example: Enum**

```ruby
if param.enum?
  param.enum      # => ["draft", "published"]
  param.enum_ref? # => false
end
```

## Instance Methods

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L91)

**Returns**

[Boolean](introspection-boolean) — false — override in Array

---

### #binary?

`#binary?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L181)

**Returns**

[Boolean](introspection-boolean) — false — override in Binary

---

### #boolean?

`#boolean?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L151)

**Returns**

[Boolean](introspection-boolean) — false — override in Boolean

---

### #boundable?

`#boundable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/string.rb#L72)

**Returns**

[Boolean](introspection-boolean) — true if this param supports min/max constraints

---

### #date?

`#date?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L163)

**Returns**

[Boolean](introspection-boolean) — false — override in Date

---

### #datetime?

`#datetime?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L157)

**Returns**

[Boolean](introspection-boolean) — false — override in DateTime

---

### #decimal?

`#decimal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L145)

**Returns**

[Boolean](introspection-boolean) — false — override in Decimal

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L67)

**Returns**

[Object](introspection-object), `nil` — the default value

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L73)

**Returns**

[Boolean](introspection-boolean) — true if a default value is defined

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L49)

**Returns**

[Boolean](introspection-boolean) — true if this field is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L55)

**Returns**

[String](introspection-string), `nil` — the field description

---

### #enum

`#enum`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/string.rb#L60)

**Returns**

[Array](introspection-array), `Symbol`, `nil` — enum values (Array) or reference name (Symbol)

**See also**

- [#enum?](#enum?)

---

### #enum?

`#enum?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/string.rb#L53)

**Returns**

[Boolean](introspection-boolean) — true if this param has enum constraints

---

### #enum_ref?

`#enum_ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/string.rb#L66)

**Returns**

[Boolean](introspection-boolean) — true if enum is a reference to a named enum

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L61)

**Returns**

[Object](introspection-object), `nil` — the example value

---

### #float?

`#float?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L139)

**Returns**

[Boolean](introspection-boolean) — false — override in Float

---

### #format

`#format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/string.rb#L29)

**Returns**

`Symbol`, `nil` — the format constraint (:email, :uuid, :uri, :url, :ipv4, :ipv6, :hostname, :password)

---

### #formattable?

`#formattable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/string.rb#L78)

**Returns**

[Boolean](introspection-boolean) — true if this param supports format constraints

---

### #integer?

`#integer?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L133)

**Returns**

[Boolean](introspection-boolean) — false — override in Integer

---

### #json?

`#json?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L187)

**Returns**

[Boolean](introspection-boolean) — false — override in JSON

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L109)

**Returns**

[Boolean](introspection-boolean) — false — override in Literal

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/string.rb#L41)

**Returns**

[Integer](introspection-integer), `nil` — the maximum string length

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/string.rb#L35)

**Returns**

[Integer](introspection-integer), `nil` — the minimum string length

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L37)

**Returns**

[Boolean](introspection-boolean) — true if this field can be null

---

### #numeric?

`#numeric?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L115)

**Returns**

[Boolean](introspection-boolean) — false — override in Integer, Float, Decimal

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L97)

**Returns**

[Boolean](introspection-boolean) — false — override in Object

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L43)

**Returns**

[Boolean](introspection-boolean) — true if this field is optional

---

### #partial?

`#partial?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L223)

**Returns**

[Boolean](introspection-boolean) — false — override in Object

---

### #ref?

`#ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L199)

**Returns**

[Boolean](introspection-boolean) — false — override in Ref

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/string.rb#L47)

**Returns**

[Boolean](introspection-boolean) — true if this is a scalar type

---

### #string?

`#string?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/string.rb#L84)

**Returns**

[Boolean](introspection-boolean) — true if this is a string param

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L79)

**Returns**

[String](introspection-string), `nil` — the discriminator tag for union variants

---

### #time?

`#time?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L169)

**Returns**

[Boolean](introspection-boolean) — false — override in Time

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/string.rb#L90)

**Returns**

`Hash` — structured representation

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L31)

**Returns**

`Symbol` — the param type (:string, :integer, :array, :object, etc.)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L103)

**Returns**

[Boolean](introspection-boolean) — false — override in Union

---

### #unknown?

`#unknown?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L193)

**Returns**

[Boolean](introspection-boolean) — false — override in Unknown

---

### #uuid?

`#uuid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L175)

**Returns**

[Boolean](introspection-boolean) — false — override in UUID

---
