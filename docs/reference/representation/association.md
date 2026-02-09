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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L154)

Whether this association is a collection.

**Returns**

`Boolean`

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L111)

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

The example for this association.

**Returns**

`Object`, `nil`

---

### #filterable?

`#filterable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L119)

Whether this association is filterable.

**Returns**

`Boolean`

---

### #include

`#include`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L35)

The include for this association.

:always or :optional.

**Returns**

`Symbol`

---

### #model_class

`#model_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L59)

The model class for this association.

**Returns**

`Class<ActiveRecord::Base>`

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L41)

The name for this association.

**Returns**

`Symbol`

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L178)

Whether this association is nullable.

**Returns**

`Boolean`

---

### #polymorphic

`#polymorphic`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L47)

The polymorphic for this association.

**Returns**

Array&lt;Class&lt;[Representation::Base](/reference/representation/base)&gt;&gt;, `nil`

---

### #polymorphic?

`#polymorphic?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L170)

Whether this association is polymorphic.

**Returns**

`Boolean`

---

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L199)

Uses explicit `representation:` if set, otherwise inferred from the model.

**Returns**

Class&lt;[Representation::Base](/reference/representation/base)&gt;, `nil`

---

### #singular?

`#singular?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L162)

Whether this association is singular.

**Returns**

`Boolean`

---

### #sortable?

`#sortable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L127)

Whether this association is sortable.

**Returns**

`Boolean`

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L53)

The type for this association.

**Returns**

`Symbol`

---

### #writable?

`#writable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L136)

Whether this association is writable.

**Returns**

`Boolean`

**See also**

- [#writable_for?](#writable-for?)

---

### #writable_for?

`#writable_for?(action)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/association.rb#L146)

Whether this association is writable for the given action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action`** | `Symbol` |  | :create or :update |

</div>

**Returns**

`Boolean`

**See also**

- [#writable?](#writable?)

---
