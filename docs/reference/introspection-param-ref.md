---
order: 57
prev: false
next: false
---

# Introspection::Param::Ref

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/ref.rb#L18)

Ref param representing a reference to a named type.

Used when a param references a shared type definition.

**Example: Basic usage**

```ruby
param.type    # => :ref
param.ref?    # => true
param.scalar? # => false
```

**Example: Reference**

```ruby
param.ref     # => :address (the referenced type name)
```

## Instance Methods

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L90)

**Returns**

`Boolean` — false — override in Array

---

### #binary?

`#binary?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L180)

**Returns**

`Boolean` — false — override in Binary

---

### #boolean?

`#boolean?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L150)

**Returns**

`Boolean` — false — override in Boolean

---

### #boundable?

`#boundable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L120)

**Returns**

`Boolean` — false — override in types that support min/max

---

### #date?

`#date?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L162)

**Returns**

`Boolean` — false — override in Date

---

### #datetime?

`#datetime?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L156)

**Returns**

`Boolean` — false — override in DateTime

---

### #decimal?

`#decimal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L144)

**Returns**

`Boolean` — false — override in Decimal

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L66)

**Returns**

`Object`, `nil` — the default value

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L72)

**Returns**

`Boolean` — true if a default value is defined

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L48)

**Returns**

`Boolean` — true if this field is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L54)

**Returns**

`String`, `nil` — the field description

---

### #enum?

`#enum?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L198)

**Returns**

`Boolean` — false — override in scalar types with enum constraints

---

### #enum_ref?

`#enum_ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L204)

**Returns**

`Boolean` — false — override in scalar types

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L60)

**Returns**

`Object`, `nil` — the example value

---

### #formattable?

`#formattable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L210)

**Returns**

`Boolean` — false — override in String, Integer

---

### #integer?

`#integer?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L132)

**Returns**

`Boolean` — false — override in Integer

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L108)

**Returns**

`Boolean` — false — override in Literal

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L36)

**Returns**

`Boolean` — true if this field can be null

---

### #number?

`#number?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L138)

**Returns**

`Boolean` — false — override in Number

---

### #numeric?

`#numeric?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L114)

**Returns**

`Boolean` — false — override in Integer, Number, Decimal

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L96)

**Returns**

`Boolean` — false — override in Object

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L42)

**Returns**

`Boolean` — true if this field is optional

---

### #partial?

`#partial?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L216)

**Returns**

`Boolean` — false — override in Object

---

### #ref

`#ref`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/ref.rb#L21)

**Returns**

`Symbol` — the referenced type name

---

### #ref?

`#ref?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/ref.rb#L27)

**Returns**

`Boolean` — true if this is a type reference param

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L84)

**Returns**

`Boolean` — false — override in scalar subclasses

---

### #string?

`#string?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L126)

**Returns**

`Boolean` — false — override in String

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L78)

**Returns**

`String`, `nil` — the discriminator tag for union variants

---

### #time?

`#time?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L168)

**Returns**

`Boolean` — false — override in Time

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/ref.rb#L33)

**Returns**

`Hash` — structured representation

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L30)

**Returns**

`Symbol` — the param type (:string, :integer, :array, :object, etc.)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L102)

**Returns**

`Boolean` — false — override in Union

---

### #unknown?

`#unknown?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L186)

**Returns**

`Boolean` — false — override in Unknown

---

### #uuid?

`#uuid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L174)

**Returns**

`Boolean` — false — override in UUID

---
