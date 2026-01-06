---
order: 50
prev: false
next: false
---

# Introspection::Type

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L74)

**Returns**

`Boolean` — whether this type is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L62)

**Returns**

`String`, `nil` — type description

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L56)

**Returns**

`Symbol`, `nil` — discriminator field for discriminated unions

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L68)

**Returns**

`Object`, `nil` — example value

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L31)

**Returns**

`Boolean` — whether this is an object type

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L44)

**Returns**

Hash{Symbol =&gt; [Param](contract-param)} — nested fields for object types

**See also**

- [Param](contract-param)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L80)

**Returns**

`Hash` — structured representation

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L25)

**Returns**

`Symbol`, `nil` — type kind (:object or :union)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L37)

**Returns**

`Boolean` — whether this is a union type

---

### #variants

`#variants`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/type.rb#L50)

**Returns**

Array&lt;[Param](contract-param)&gt; — variants for union types

---
