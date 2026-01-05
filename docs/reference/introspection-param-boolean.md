---
order: 35
prev: false
next: false
---

# Introspection::Param::Boolean

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/boolean.rb#L22)

Boolean param representing true/false values.

**Example: Basic usage**

```ruby
param.type         # => :boolean
param.scalar?      # => true
param.boolean?     # => true
```

**Example: Capabilities**

```ruby
param.formattable? # => false
```

**Example: Enum (scalar-only, use guard)**

```ruby
if param.scalar? && param.enum?
  param.enum      # => [true]
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/boolean.rb#L56)

**Returns**

[Boolean](introspection-boolean) — true if this is a boolean param

---

### #boundable?

`#boundable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L129)

**Returns**

[Boolean](introspection-boolean) — false — override in types that support min/max

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/boolean.rb#L43)

**Returns**

[Array](introspection-array), `Symbol`, `nil` — enum values (Array) or reference name (Symbol)

**See also**

- [#enum?](#enum?)

---

### #enum?

`#enum?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/boolean.rb#L36)

**Returns**

[Boolean](introspection-boolean) — true if this param has enum constraints

**See also**

- [#scalar?](#scalar?)

**Example**

```ruby
if param.scalar? && param.enum?
  param.enum # => [true]
end
```

---

### #enum_ref?

`#enum_ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/boolean.rb#L50)

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

### #formattable?

`#formattable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/boolean.rb#L63)

**Returns**

[Boolean](introspection-boolean) — false — booleans do not support format constraints

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

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L45)

**Returns**

[Boolean](introspection-boolean) — true if this field can be null

---

### #numeric?

`#numeric?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L123)

**Returns**

[Boolean](introspection-boolean) — false — override in Integer, Float, Decimal

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/boolean.rb#L25)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L213)

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
