---
order: 73
prev: false
next: false
---

# Representation::Union::Variant

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/union/variant.rb#L17)

Represents a variant in a discriminated union representation.

Variants map discriminator tags to their representation classes.
Used by adapters to serialize records based on their actual type.

**Example**

```ruby
variant = ClientRepresentation.union.variants[:person]
variant.tag                 # => :person
variant.type                # => "PersonClient"
variant.representation_class # => PersonClientRepresentation
```

## Instance Methods

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/union/variant.rb#L20)

**Returns**

`Class` — the representation class for this variant

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/union/variant.rb#L24)

**Returns**

`Symbol` — the discriminator tag

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/union/variant.rb#L28)

**Returns**

`String` — the Rails STI type

---
