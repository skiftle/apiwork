---
order: 77
prev: false
next: false
---

# Type

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L18)

Wraps custom type definitions.

Types can be objects (with shapes) or unions (with variants).

**Example: Object type**

```ruby
api.types[:address].object?      # => true
api.types[:address].shape[:city] # => Param for city field
```

**Example: Union type**

```ruby
api.types[:payment_method].union?        # => true
api.types[:payment_method].variants      # => [Param, ...]
api.types[:payment_method].discriminator # => :type
```

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L85)

**Returns**

`Boolean`

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L61)

**Returns**

`String`, `nil`

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L55)

**Returns**

`Symbol`, `nil`

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L79)

**Returns**

`Object`, `nil`

---

### #extends

`#extends`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L67)

**Returns**

`Array<Symbol>`

---

### #extends?

`#extends?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L73)

**Returns**

`Boolean`

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L31)

**Returns**

`Boolean`

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L43)

**Returns**

`Hash{Symbol => Param}`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L93)

Converts this type to a hash.

**Returns**

`Hash`

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L25)

**Returns**

`Symbol`, `nil`

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L37)

**Returns**

`Boolean`

---

### #variants

`#variants`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L49)

**Returns**

`Array<Param>`

---
