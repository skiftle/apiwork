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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L82)

**Returns**

`Boolean` — whether this type is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L70)

**Returns**

`String`, `nil` — type description

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L64)

**Returns**

`Symbol`, `nil` — discriminator field for discriminated unions

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L76)

**Returns**

`Object`, `nil` — example value

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L24)

**Returns**

`Symbol` — type name

---

### #object?

`#object?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L39)

**Returns**

`Boolean` — whether this is an object type

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L52)

**Returns**

`Hash{Symbol => Param}` — nested fields for object types

**See also**

- [Param](spec-data-param)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L88)

**Returns**

`Hash` — the raw underlying data hash

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L33)

**Returns**

`Symbol`, `nil` — type kind (:object or :union)

---

### #union?

`#union?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L45)

**Returns**

`Boolean` — whether this is a union type

---

### #variants

`#variants`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/type.rb#L58)

**Returns**

`Array<Hash>` — variants for union types

---
