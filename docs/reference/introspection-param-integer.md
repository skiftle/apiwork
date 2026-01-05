---
order: 40
prev: false
next: false
---

# Introspection::Param::Integer

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L32)

Integer param representing whole number values.

**Example: Basic usage**

```ruby
param.type       # => :integer
param.scalar?    # => true
param.integer?   # => true
param.numeric?   # => true
```

**Example: Constraints**

```ruby
param.min          # => 0 or nil
param.max          # => 100 or nil
param.format       # => :int32 or nil
param.boundable?   # => true
param.formattable? # => true
```

**Example: Enum (scalar-only, use guard)**

```ruby
if param.scalar? && param.enum?
  param.enum      # => [1, 2, 3]
  param.enum_ref? # => false
end
```

**Example: Format (scalar-only, use guard)**

```ruby
if param.scalar? && param.formattable?
  param.format # => :int32 or nil
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L90)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L71)

**Returns**

[Array](introspection-array), `Symbol`, `nil` — enum values (Array) or reference name (Symbol)

**See also**

- [#enum?](#enum?)

---

### #enum?

`#enum?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L64)

**Returns**

[Boolean](introspection-boolean) — true if this param has enum constraints

**See also**

- [#scalar?](#scalar?)

**Example**

```ruby
if param.scalar? && param.enum?
  param.enum # => [1, 2, 3]
end
```

---

### #enum_ref?

`#enum_ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L78)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L147)

**Returns**

[Boolean](introspection-boolean) — false — override in Float

---

### #format

`#format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L47)

**Returns**

`Symbol`, `nil` — the format constraint (:int32, :int64)

---

### #formattable?

`#formattable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L97)

**Returns**

[Boolean](introspection-boolean) — true if this param supports format constraints

**See also**

- [#scalar?](#scalar?)

---

### #integer?

`#integer?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L103)

**Returns**

[Boolean](introspection-boolean) — true if this is an integer param

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L41)

**Returns**

`Numeric`, `nil` — the maximum value constraint

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L35)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L84)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L53)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/integer.rb#L109)

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
