---
order: 43
prev: false
next: false
---

# Introspection::Param::Object

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/object.rb#L19)

Object param representing structured data with named fields.

**Example: Basic usage**

```ruby
param.type      # => :object
param.object?   # => true
param.scalar?   # => false
```

**Example: Fields**

```ruby
param.shape     # => { name: Param, email: Param }
```

**Example: Partial objects (for updates)**

```ruby
param.partial?  # => true if all fields are optional
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L121)

**Returns**

[Boolean](introspection-boolean) — false — override in types that support min/max

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

### #enum?

`#enum?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L205)

**Returns**

[Boolean](introspection-boolean) — false — override in scalar types with enum constraints

---

### #enum_ref?

`#enum_ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L211)

**Returns**

[Boolean](introspection-boolean) — false — override in scalar types

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

### #formattable?

`#formattable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L217)

**Returns**

[Boolean](introspection-boolean) — false — override in String, Integer

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/object.rb#L34)

**Returns**

[Boolean](introspection-boolean) — true if this is an object param

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L43)

**Returns**

[Boolean](introspection-boolean) — true if this field is optional

---

### #partial?

`#partial?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/object.rb#L28)

**Returns**

[Boolean](introspection-boolean) — true if this is a partial object (all fields optional)

---

### #ref?

`#ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L199)

**Returns**

[Boolean](introspection-boolean) — false — override in Ref

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L85)

**Returns**

[Boolean](introspection-boolean) — false — override in scalar subclasses

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/object.rb#L22)

**Returns**

`Hash{Symbol => Param::Base}` — nested field definitions

---

### #string?

`#string?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L127)

**Returns**

[Boolean](introspection-boolean) — false — override in String

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/object.rb#L40)

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
