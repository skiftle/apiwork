---
order: 36
prev: false
next: false
---

# Spec::Data::Type

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L21)

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
type.variants      # => [{ type: :credit_card, ... }, ...]
type.discriminator # => :type
```

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L80)

**Returns**

`Boolean` — whether this type is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L68)

**Returns**

`String`, `nil` — type description

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L62)

**Returns**

`Symbol`, `nil` — discriminator field for discriminated unions

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L74)

**Returns**

`Object`, `nil` — example value

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L37)

**Returns**

`Boolean` — whether this is an object type

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L50)

**Returns**

`Hash{Symbol => Param}` — nested fields for object types

**See also**

- [Param](param)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L86)

**Returns**

`Hash` — the raw underlying data hash

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L31)

**Returns**

`Symbol`, `nil` — type kind (:object or :union)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L43)

**Returns**

`Boolean` — whether this is a union type

---

### #variants

`#variants`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L56)

**Returns**

`Array<Hash>` — variants for union types

---
