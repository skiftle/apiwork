---
order: 70
prev: false
next: false
---

# Representation::Attribute

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

### #deprecated

`#deprecated`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L26)

**Returns**

`Boolean` — whether this attribute is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L30)

**Returns**

`String`, `nil` — documentation description

---

### #enum

`#enum`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L34)

**Returns**

`Array`, `nil` — allowed values

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L38)

**Returns**

`Object`, `nil` — example value for documentation

---

### #filterable?

`#filterable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L144)

**Returns**

`Boolean` — whether filtering is enabled

---

### #format

`#format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L42)

**Returns**

`Symbol`, `nil` — format hint

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L46)

**Returns**

`Integer`, `nil` — maximum value or length

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L50)

**Returns**

`Integer`, `nil` — minimum value or length

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L54)

**Returns**

`Symbol` — attribute name

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L162)

**Returns**

`Boolean` — whether this attribute can be null

---

### #of

`#of`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L58)

**Returns**

`Symbol`, `nil` — element type for arrays

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L156)

**Returns**

`Boolean` — whether this attribute can be omitted

---

### #sortable?

`#sortable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L150)

**Returns**

`Boolean` — whether sorting is enabled

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L62)

**Returns**

`Symbol` — data type

---

### #writable?

`#writable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L170)

**Returns**

`Boolean` — whether this attribute is writable

---

### #writable_for?

`#writable_for?(action)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L177)

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | `Symbol` | the action to check (:create or :update) |

**Returns**

`Boolean` — whether this attribute is writable for the given action

---
