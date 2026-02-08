---
order: 75
prev: false
next: false
---

# Union

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/union.rb#L19)

Union param representing a value that can be one of several types.

**Example: Basic usage**

```ruby
param.type      # => :union
param.union?    # => true
param.scalar?   # => false
```

**Example: Variants**

```ruby
param.variants  # => [Param, Param, ...]
```

**Example: Discriminated unions**

```ruby
param.discriminator # => :type or nil
```

## Instance Methods

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L75)

**Returns**

`Boolean`

---

### #binary?

`#binary?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L167)

**Returns**

`Boolean`

---

### #boolean?

`#boolean?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L137)

**Returns**

`Boolean`

---

### #boundable?

`#boundable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L107)

Whether this param supports min/max bounds.

**Returns**

`Boolean`

---

### #date?

`#date?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L149)

**Returns**

`Boolean`

---

### #datetime?

`#datetime?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L143)

**Returns**

`Boolean`

---

### #decimal?

`#decimal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L131)

**Returns**

`Boolean`

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L49)

**Returns**

`Object`, `nil`

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L57)

Whether a default value is present in the schema.

**Returns**

`Boolean`

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L31)

**Returns**

`Boolean`

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L37)

**Returns**

`String`, `nil`

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/union.rb#L32)

The discriminator for this param.

**Returns**

`Symbol`, `nil`

---

### #enum?

`#enum?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L185)

**Returns**

`Boolean`

---

### #enum_reference?

`#enum_reference?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L193)

Whether this param references a named enum type.

**Returns**

`Boolean`

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L43)

**Returns**

`Object`, `nil`

---

### #formattable?

`#formattable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L201)

Whether this param supports format hints.

**Returns**

`Boolean`

---

### #integer?

`#integer?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L119)

**Returns**

`Boolean`

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L93)

**Returns**

`Boolean`

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L19)

**Returns**

`Boolean`

---

### #number?

`#number?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L125)

**Returns**

`Boolean`

---

### #numeric?

`#numeric?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L99)

**Returns**

`Boolean`

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L81)

**Returns**

`Boolean`

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L25)

**Returns**

`Boolean`

---

### #partial?

`#partial?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L209)

Whether this param uses partial serialization.

**Returns**

`Boolean`

---

### #reference?

`#reference?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L179)

**Returns**

`Boolean`

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L69)

**Returns**

`Boolean`

---

### #string?

`#string?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L113)

**Returns**

`Boolean`

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L63)

**Returns**

`String`, `nil`

---

### #time?

`#time?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L155)

**Returns**

`Boolean`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/union.rb#L46)

Converts this param to a hash.

**Returns**

`Hash`

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L13)

**Returns**

`Symbol`

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/union.rb#L38)

**Returns**

`Boolean`

---

### #unknown?

`#unknown?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L173)

**Returns**

`Boolean`

---

### #uuid?

`#uuid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L161)

**Returns**

`Boolean`

---

### #variants

`#variants`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/union.rb#L24)

The variants for this param.

**Returns**

`Array<Param::Base>`

---
