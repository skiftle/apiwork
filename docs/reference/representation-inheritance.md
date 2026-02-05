---
order: 82
prev: false
next: false
---

# Representation::Inheritance

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L15)

Tracks STI subclass representations for a base representation.

Created automatically when a representation's model uses STI.
Provides resolution of records to their correct subclass representation.

**Example**

```ruby
ClientRepresentation.inheritance.column      # => :type
ClientRepresentation.inheritance.subclasses  # => [PersonClientRepresentation, ...]
ClientRepresentation.inheritance.resolve(record)  # => PersonClientRepresentation
```

## Instance Methods

### #base_class

`#base_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L18)

**Returns**

`Class` — the base representation class for this inheritance chain

---

### #column

`#column`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L35)

The STI column name from the model.

**Returns**

`Symbol`

---

### #mapping

`#mapping`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L61)

Mapping of API names to database type values.

**Returns**

`Hash{String => String}`

---

### #needs_transform?

`#needs_transform?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L53)

Whether any subclass has a custom sti_name different from the model.

**Returns**

`Boolean`

---

### #resolve

`#resolve(record)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L44)

Resolves a record to its subclass representation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `record` | `ActiveRecord::Base` |  |

**Returns**

`Class`, `nil`

---

### #subclasses

`#subclasses`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L24)

All registered subclass representations.

**Returns**

`Array<Class>`

---
