---
order: 77
prev: false
next: false
---

# Representation::Association

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L16)

Represents an association defined on a representation.

Associations map to model relationships and define serialization behavior.
Used by adapters to build contracts and serialize records.

**Example**

```ruby
association = InvoiceRepresentation.associations[:customer]
association.name         # => :customer
association.type         # => :belongs_to
association.representation_class # => CustomerRepresentation
```

## Instance Methods

### #collection?

`#collection?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L123)

**Returns**

`Boolean` — whether this is a has_many association

---

### #deprecated

`#deprecated`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L19)

**Returns**

`Boolean` — whether this association is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L23)

**Returns**

`String`, `nil` — documentation description

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L27)

**Returns**

`Object`, `nil` — example value for documentation

---

### #filterable?

`#filterable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L98)

**Returns**

`Boolean` — whether filtering is enabled

---

### #include

`#include`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L31)

**Returns**

`Symbol` — include mode (:always or :optional)

---

### #model_class

`#model_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L47)

**Returns**

`Class` — the owner representation's model class

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L35)

**Returns**

`Symbol` — association name

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L141)

**Returns**

`Boolean` — whether this association can be null

---

### #polymorphic

`#polymorphic`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L39)

**Returns**

`Array<Class>`, `nil` — polymorphic representation classes

---

### #polymorphic?

`#polymorphic?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L135)

**Returns**

`Boolean` — whether this is a polymorphic association

---

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L160)

Returns the representation class for this association.

Returns the explicitly configured class if set, otherwise infers
from the association's model class using namespace conventions.

**Returns**

`Class`, `nil` — the representation class or nil if not found

---

### #singular?

`#singular?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L129)

**Returns**

`Boolean` — whether this is a has_one or belongs_to association

---

### #sortable?

`#sortable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L104)

**Returns**

`Boolean` — whether sorting is enabled

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L43)

**Returns**

`Symbol` — association type (:has_one, :has_many, :belongs_to)

---

### #writable?

`#writable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L110)

**Returns**

`Boolean` — whether this association is writable

---

### #writable_for?

`#writable_for?(action)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L117)

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | `Symbol` | the action to check (:create or :update) |

**Returns**

`Boolean` — whether this association is writable for the given action

---
