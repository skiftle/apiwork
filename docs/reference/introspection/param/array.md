---
order: 61
prev: false
next: false
---

# Array

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L22)

Array param representing ordered collections.

**Example: Basic usage**

```ruby
param.type       # => :array
param.array?     # => true
param.scalar?    # => false
```

**Example: Element type**

```ruby
param.of         # => Param (element type) or nil
param.shape      # => {} or { field: Param, ... }
```

**Example: Constraints**

```ruby
param.min        # => 1 or nil
param.max        # => 10 or nil
param.boundable? # => true
```

## Instance Methods

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L59)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L67)

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

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L53)

The maximum length for this param.

**Returns**

`Integer`, `nil`

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L45)

The minimum length for this param.

**Returns**

`Integer`, `nil`

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

### #of

`#of`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L27)

The element type for this param.

**Returns**

`Param::Base`, `nil`

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

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L35)

The shape for this param.

**Returns**

`Hash{Symbol => Param::Base}`

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/array.rb#L75)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L87)

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
