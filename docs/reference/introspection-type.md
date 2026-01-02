---
order: 33
prev: false
next: false
---

# Introspection::Type

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L20)

Wraps custom type definitions.

Types can be objects (with shapes) or unions (with variants).

**Example: Object type**

```ruby
type.name         # => :address
type.object?      # => true
type.shape[:city] # => Param for city field
```

**Example: Union type**

```ruby
type.name          # => :payment_method
type.union?        # => true
type.variants      # => [Param, ...]
type.discriminator # => :type
```

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L81)

**Returns**

`Boolean` — whether this type is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L69)

**Returns**

`String`, `nil` — type description

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L63)

**Returns**

`Symbol`, `nil` — discriminator field for discriminated unions

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L75)

**Returns**

`Object`, `nil` — example value

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L23)

**Returns**

`Symbol` — type name

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L38)

**Returns**

`Boolean` — whether this is an object type

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L51)

**Returns**

`Hash{Symbol => Param}` — nested fields for object types

**See also**

- [Param](introspection-param)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L87)

**Returns**

`Hash` — structured representation

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L32)

**Returns**

`Symbol`, `nil` — type kind (:object or :union)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L44)

**Returns**

`Boolean` — whether this is a union type

---

### #variants

`#variants`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L57)

**Returns**

`Array<Param>` — variants for union types

---
