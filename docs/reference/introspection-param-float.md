---
order: 39
prev: false
next: false
---

# Introspection::Param::Float

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/float.rb#L26)

Float param representing floating-point number values.

**Example: Basic usage**

```ruby
param.type       # => :float
param.scalar?    # => true
param.float?     # => true
param.numeric?   # => true
```

**Example: Constraints**

```ruby
param.min          # => 0.0 or nil
param.max          # => 100.0 or nil
param.boundable?   # => true
param.formattable? # => false
```

**Example: Enum (scalar-only, use guard)**

```ruby
if param.scalar? && param.enum?
  param.enum      # => [0.5, 1.0, 1.5]
  param.enum_ref? # => false
end
```

## Instance Methods

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L99)

**Returns**

[Boolean](introspection-boolean) — false — override in Array

---

### #binary?

`#binary?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L189)

**Returns**

[Boolean](introspection-boolean) — false — override in Binary

---

### #boolean?

`#boolean?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L159)

**Returns**

[Boolean](introspection-boolean) — false — override in Boolean

---

### #boundable?

`#boundable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/float.rb#L78)

**Returns**

[Boolean](introspection-boolean) — true if this param supports min/max constraints

---

### #date?

`#date?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L171)

**Returns**

[Boolean](introspection-boolean) — false — override in Date

---

### #datetime?

`#datetime?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L165)

**Returns**

[Boolean](introspection-boolean) — false — override in DateTime

---

### #decimal?

`#decimal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L153)

**Returns**

[Boolean](introspection-boolean) — false — override in Decimal

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L75)

**Returns**

[Object](introspection-object), `nil` — the default value

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L81)

**Returns**

[Boolean](introspection-boolean) — true if a default value is defined

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L57)

**Returns**

[Boolean](introspection-boolean) — true if this field is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L63)

**Returns**

[String](introspection-string), `nil` — the field description

---

### #enum

`#enum`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/float.rb#L59)

**Returns**

[Array](introspection-array), `Symbol`, `nil` — enum values (Array) or reference name (Symbol)

**See also**

- [#enum?](#enum?)

---

### #enum?

`#enum?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/float.rb#L52)

**Returns**

[Boolean](introspection-boolean) — true if this param has enum constraints

**See also**

- [#scalar?](#scalar?)

**Example**

```ruby
if param.scalar? && param.enum?
  param.enum # => [0.5, 1.0, 1.5]
end
```

---

### #enum_ref?

`#enum_ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/float.rb#L66)

**Returns**

[Boolean](introspection-boolean) — true if enum is a reference to a named enum

**See also**

- [#enum?](#enum?)

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L69)

**Returns**

[Object](introspection-object), `nil` — the example value

---

### #float?

`#float?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/float.rb#L84)

**Returns**

[Boolean](introspection-boolean) — true if this is a float param

---

### #formattable?

`#formattable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/float.rb#L91)

**Returns**

[Boolean](introspection-boolean) — false — floats do not support format constraints

**See also**

- [#scalar?](#scalar?)

---

### #integer?

`#integer?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L141)

**Returns**

[Boolean](introspection-boolean) — false — override in Integer

---

### #json?

`#json?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L195)

**Returns**

[Boolean](introspection-boolean) — false — override in JSON

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L117)

**Returns**

[Boolean](introspection-boolean) — false — override in Literal

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/float.rb#L35)

**Returns**

`Numeric`, `nil` — the maximum value constraint

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/float.rb#L29)

**Returns**

`Numeric`, `nil` — the minimum value constraint

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L45)

**Returns**

[Boolean](introspection-boolean) — true if this field can be null

---

### #numeric?

`#numeric?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/float.rb#L72)

**Returns**

[Boolean](introspection-boolean) — true if this is a numeric param

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L105)

**Returns**

[Boolean](introspection-boolean) — false — override in Object

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L51)

**Returns**

[Boolean](introspection-boolean) — true if this field is optional

---

### #ref?

`#ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L207)

**Returns**

[Boolean](introspection-boolean) — false — override in Ref

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/float.rb#L41)

**Returns**

[Boolean](introspection-boolean) — true if this is a scalar type

---

### #string?

`#string?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L135)

**Returns**

[Boolean](introspection-boolean) — false — override in String

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L87)

**Returns**

[String](introspection-string), `nil` — the discriminator tag for union variants

---

### #time?

`#time?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L177)

**Returns**

[Boolean](introspection-boolean) — false — override in Time

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/float.rb#L97)

**Returns**

`Hash` — structured representation

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L39)

**Returns**

`Symbol` — the param type (:string, :integer, :array, :object, etc.)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L111)

**Returns**

[Boolean](introspection-boolean) — false — override in Union

---

### #unknown?

`#unknown?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L201)

**Returns**

[Boolean](introspection-boolean) — false — override in Unknown

---

### #uuid?

`#uuid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L183)

**Returns**

[Boolean](introspection-boolean) — false — override in UUID

---
