---
order: 80
prev: false
next: false
---

# Attribute

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L16)

Represents an attribute defined on a representation.

Attributes map to model columns and define serialization behavior.
Used by adapters to build contracts and serialize records.

**Example**

```ruby
attribute = InvoiceRepresentation.attributes[:title]
attribute.name # => :title
attribute.type # => :string
attribute.filterable? # => true
```

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L168)

Whether this attribute is deprecated.

**Returns**

`Boolean`

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L74)

The description for this attribute.

**Returns**

`String`, `nil`

---

### #enum

`#enum`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L74)

The enum for this attribute.

**Returns**

`Array<Object>`, `nil`

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L74)

The example for this attribute.

**Returns**

`Object`, `nil`

---

### #filterable?

`#filterable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L176)

Whether this attribute is filterable.

**Returns**

`Boolean`

---

### #format

`#format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L74)

The format for this attribute.

**Returns**

`Symbol`, `nil`

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L74)

The maximum for this attribute.

**Returns**

`Integer`, `nil`

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L74)

The minimum for this attribute.

**Returns**

`Integer`, `nil`

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L74)

The name for this attribute.

**Returns**

`Symbol`

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L200)

Whether this attribute is nullable.

**Returns**

`Boolean`

---

### #of

`#of`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L74)

The of for this attribute.

**Returns**

`Symbol`, `nil`

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L192)

Whether this attribute is optional.

**Returns**

`Boolean`

---

### #preload

`#preload`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L74)

The preload for this attribute.

**Returns**

`Symbol`, `Array`, `Hash`, `nil`

---

### #sortable?

`#sortable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L184)

Whether this attribute is sortable.

**Returns**

`Boolean`

---

### #writable?

`#writable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L211)

Whether this attribute is writable.

**Returns**

`Boolean`

**See also**

- [#writable_for?](#writable-for?)

---

### #writable_for?

`#writable_for?(action)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L222)

Whether this attribute is writable for the given action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`action`** | `Symbol<:create, :update>` |  | The action. |

</div>

**Returns**

`Boolean`

**See also**

- [#writable?](#writable?)

---
