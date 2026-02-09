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
attribute.name       # => :title
attribute.type       # => :string
attribute.filterable? # => true
```

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L160)

Whether this attribute is deprecated.

**Returns**

`Boolean`

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L28)

The description for this attribute.

**Returns**

`String`, `nil`

---

### #enum

`#enum`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L34)

The enum for this attribute.

**Returns**

`Array<Object>`, `nil`

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L40)

The example for this attribute.

**Returns**

`Object`, `nil`

---

### #filterable?

`#filterable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L168)

Whether this attribute is filterable.

**Returns**

`Boolean`

---

### #format

`#format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L46)

The format for this attribute.

**Returns**

`Symbol`, `nil`

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L52)

The maximum for this attribute.

**Returns**

`Integer`, `nil`

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L58)

The minimum for this attribute.

**Returns**

`Integer`, `nil`

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L64)

The name for this attribute.

**Returns**

`Symbol`

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L192)

Whether this attribute is nullable.

**Returns**

`Boolean`

---

### #of

`#of`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L70)

The of for this attribute.

**Returns**

`Symbol`, `nil`

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L184)

Whether this attribute is optional.

**Returns**

`Boolean`

---

### #sortable?

`#sortable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L176)

Whether this attribute is sortable.

**Returns**

`Boolean`

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L76)

The type for this attribute.

**Returns**

`Symbol`

---

### #writable?

`#writable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L203)

Whether this attribute is writable.

**Returns**

`Boolean`

**See also**

- [#writable_for?](#writable-for?)

---

### #writable_for?

`#writable_for?(action)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L213)

Whether this attribute is writable for the given action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `action` | `Symbol` |  | :create or :update |

</div>

**Returns**

`Boolean`

**See also**

- [#writable?](#writable?)

---
