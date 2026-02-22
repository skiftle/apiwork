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
param.type # => :union
param.union? # => true
param.scalar? # => false
```

**Example: Variants**

```ruby
param.variants # => [Param, Param, ...]
```

**Example: Discriminated unions**

```ruby
param.discriminator # => :type or nil
```

## Instance Methods

### #array?

`#array?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L95)

Whether this param is an array.

**Returns**

`Boolean`

---

### #binary?

`#binary?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L215)

Whether this param is binary data.

**Returns**

`Boolean`

---

### #boolean?

`#boolean?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L175)

Whether this param is a boolean.

**Returns**

`Boolean`

---

### #boundable?

`#boundable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L135)

Whether this param is boundable.

**Returns**

`Boolean`

---

### #date?

`#date?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L191)

Whether this param is a date.

**Returns**

`Boolean`

---

### #datetime?

`#datetime?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L183)

Whether this param is a datetime.

**Returns**

`Boolean`

---

### #decimal?

`#decimal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L167)

Whether this param is a decimal.

**Returns**

`Boolean`

---

### #default

`#default`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L63)

The default for this param.

**Returns**

`Object`, `nil`

---

### #default?

`#default?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L71)

Whether this param has a default.

**Returns**

`Boolean`

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L39)

Whether this param is deprecated.

**Returns**

`Boolean`

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L47)

The description for this param.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L239)

Whether this param has an enum.

**Returns**

`Boolean`

---

### #enum_reference?

`#enum_reference?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L247)

Whether this param is an enum reference.

**Returns**

`Boolean`

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L55)

The example for this param.

**Returns**

`Object`, `nil`

---

### #formattable?

`#formattable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L255)

Whether this param is formattable.

**Returns**

`Boolean`

---

### #integer?

`#integer?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L151)

Whether this param is an integer.

**Returns**

`Boolean`

---

### #literal?

`#literal?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L119)

Whether this param is a literal.

**Returns**

`Boolean`

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L23)

Whether this param is nullable.

**Returns**

`Boolean`

---

### #number?

`#number?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L159)

Whether this param is a number.

**Returns**

`Boolean`

---

### #numeric?

`#numeric?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L127)

Whether this param is numeric.

**Returns**

`Boolean`

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L103)

Whether this param is an object.

**Returns**

`Boolean`

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L31)

Whether this param is optional.

**Returns**

`Boolean`

---

### #partial?

`#partial?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L263)

Whether this param is partial.

**Returns**

`Boolean`

---

### #reference?

`#reference?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L231)

Whether this param is a reference.

**Returns**

`Boolean`

---

### #scalar?

`#scalar?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L87)

Whether this param is scalar.

**Returns**

`Boolean`

---

### #string?

`#string?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L143)

Whether this param is a string.

**Returns**

`Boolean`

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L79)

The tag for this param.

**Returns**

`String`, `nil`

---

### #time?

`#time?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L199)

Whether this param is a time.

**Returns**

`Boolean`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/union.rb#L48)

Converts this param to a hash.

**Returns**

`Hash`

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L15)

The type for this param.

**Returns**

`Symbol`

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/union.rb#L40)

Whether this param is a union.

**Returns**

`Boolean`

---

### #unknown?

`#unknown?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L223)

Whether this param is of unknown type.

**Returns**

`Boolean`

---

### #uuid?

`#uuid?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/param/base.rb#L207)

Whether this param is a UUID.

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
