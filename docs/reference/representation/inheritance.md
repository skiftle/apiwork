---
order: 81
prev: false
next: false
---

# Inheritance

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L20)

The base representation class for this inheritance.

**Returns**

Class&lt;[Representation::Base](/reference/representation/base)&gt;

---

### #column

`#column`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L37)

The STI column name from the model.

**Returns**

`Symbol`

---

### #mapping

`#mapping`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L63)

Mapping of API names to database type values.

**Returns**

`Hash{String => String}`

---

### #needs_transform?

`#needs_transform?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L55)

Whether this inheritance needs transformation.

**Returns**

`Boolean`

---

### #resolve

`#resolve(record)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L46)

Resolves a record to its subclass representation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `record` | `ActiveRecord::Base` | the record to resolve |

**Returns**

Class&lt;[Representation::Base](/reference/representation/base)&gt;, `nil`

---

### #subclasses

`#subclasses`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L26)

All registered subclass representations.

**Returns**

Array&lt;Class&lt;[Representation::Base](/reference/representation/base)&gt;&gt;

---
