---
order: 79
prev: false
next: false
---

# Association

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L151)

Whether this association is a collection.

**Returns**

`Boolean`

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L110)

Whether this association is deprecated.

**Returns**

`Boolean`

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L21)

The description for this association.

**Returns**

`String`, `nil`

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L27)

The example value for this association.

**Returns**

`Object`, `nil`

---

### #filterable?

`#filterable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L118)

Whether this association is filterable.

**Returns**

`Boolean`

---

### #include

`#include`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L33)

The include behavior for this association.

**Returns**

`Symbol`

---

### #model_class

`#model_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L57)

The model class for this association.

**Returns**

`Class<ActiveRecord::Base>`

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L39)

The name for this association.

**Returns**

`Symbol`

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L175)

Whether this association is nullable.

**Returns**

`Boolean`

---

### #polymorphic

`#polymorphic`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L45)

The polymorphic representation classes for this association.

**Returns**

Array&lt;Class&lt;[Representation::Base](/reference/representation/base)&gt;&gt;, `nil`

---

### #polymorphic?

`#polymorphic?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L167)

Whether this association is polymorphic.

**Returns**

`Boolean`

---

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L191)

The representation class for this association.

**Returns**

Class&lt;[Representation::Base](/reference/representation/base)&gt;, `nil`

---

### #singular?

`#singular?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L159)

Whether this association is singular.

**Returns**

`Boolean`

---

### #sortable?

`#sortable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L126)

Whether this association is sortable.

**Returns**

`Boolean`

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L51)

The type for this association.

**Returns**

`Symbol`

---

### #writable?

`#writable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L134)

Whether this association is writable.

**Returns**

`Boolean`

---

### #writable_for?

`#writable_for?(action)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L143)

Whether this association is writable for a specific action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | `Symbol` | the action to check (:create or :update) |

**Returns**

`Boolean`

---
