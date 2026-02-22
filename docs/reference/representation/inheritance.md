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
ClientRepresentation.inheritance.column # => :type
ClientRepresentation.inheritance.subclasses # => [PersonClientRepresentation, ...]
ClientRepresentation.inheritance.resolve(record) # => PersonClientRepresentation
```

## Instance Methods

### #base_class

`#base_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L26)

The base class for this inheritance.

**Returns**

Class&lt;[Representation::Base](/reference/representation/base)&gt;

---

### #column

`#column`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L38)

The column for this inheritance.

**Returns**

`Symbol`

---

### #mapping

`#mapping`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L65)

Mapping of API names to database type values.

**Returns**

`Hash{String => String}`

---

### #resolve

`#resolve(record)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L48)

Resolves a record to its subclass representation.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`record`** | `ActiveRecord::Base` |  | The record to resolve. |

</div>

**Returns**

Class&lt;[Representation::Base](/reference/representation/base)&gt;, `nil`

---

### #transform?

`#transform?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/inheritance.rb#L57)

Whether this inheritance requires type transformation.

**Returns**

`Boolean`

---
