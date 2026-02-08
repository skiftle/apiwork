---
order: 83
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L18)

**Returns**

Class&lt;[Representation::Base](/reference/representation/base)&gt;

---

### #column

`#column`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L33)

**Returns**

`Symbol`

---

### #mapping

`#mapping`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L57)

Mapping of API names to database type values.

**Returns**

`Hash{String => String}`

---

### #needs_transform?

`#needs_transform?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L49)

**Returns**

`Boolean`

---

### #resolve

`#resolve(record)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L42)

Resolves a record to its subclass representation.

**Parameters**

| Name | Type | Description |
|------|------|------|
| `record` | `ActiveRecord::Base` | the record to resolve |

**Returns**

Class&lt;[Representation::Base](/reference/representation/base)&gt;, `nil`

---

### #subclasses

`#subclasses`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L24)

All registered subclass representations.

**Returns**

Array&lt;Class&lt;[Representation::Base](/reference/representation/base)&gt;&gt;

---
