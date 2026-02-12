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
api.types[:address].object? # => true
api.types[:address].shape[:city] # => Param for city field
```

**Example: Union type**

```ruby
api.types[:payment_method].union? # => true
api.types[:payment_method].variants # => [Param, ...]
api.types[:payment_method].discriminator # => :type
```

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L107)

Whether this type is deprecated.

**Returns**

`Boolean`

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L75)

The description for this type.

**Returns**

`String`, `nil`

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L67)

The discriminator for this type.

**Returns**

`Symbol`, `nil`

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L99)

The example for this type.

**Returns**

`Object`, `nil`

---

### #extends

`#extends`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L83)

The extends for this type.

**Returns**

`Array<Symbol>`

---

### #extends?

`#extends?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L91)

Whether this type extends other types.

**Returns**

`Boolean`

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L35)

Whether this type is an object.

**Returns**

`Boolean`

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L51)

The shape for this type.

**Returns**

`Hash{Symbol => Param}`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L115)

Converts this type to a hash.

**Returns**

`Hash`

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L27)

The type for this type.

**Returns**

`Symbol`, `nil`

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L43)

Whether this type is a union.

**Returns**

`Boolean`

---

### #variants

`#variants`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L59)

The variants for this type.

**Returns**

`Array<Param>`

---
