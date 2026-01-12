---
order: 62
prev: false
next: false
---

# Schema::Attribute

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L16)

Represents an attribute defined on a schema.

Attributes map to model columns and define serialization behavior.
Used by adapters to build contracts and serialize records.

**Example**

```ruby
attribute = InvoiceSchema.attributes[:title]
attribute.name       # => :title
attribute.type       # => :string
attribute.filterable? # => true
```

## Instance Methods

### #deprecated

`#deprecated`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L27)

**Returns**

`Boolean` — whether this attribute is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L31)

**Returns**

`String`, `nil` — documentation description

---

### #enum

`#enum`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L35)

**Returns**

`Array`, `nil` — allowed values

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L39)

**Returns**

`Object`, `nil` — example value for documentation

---

### #filterable?

`#filterable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L146)

**Returns**

`Boolean` — whether filtering is enabled

---

### #format

`#format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L43)

**Returns**

`Symbol`, `nil` — format hint

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L47)

**Returns**

`Integer`, `nil` — maximum value or length

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L51)

**Returns**

`Integer`, `nil` — minimum value or length

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L55)

**Returns**

`Symbol` — attribute name

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L164)

**Returns**

`Boolean` — whether this attribute can be null

---

### #of

`#of`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L59)

**Returns**

`Symbol`, `nil` — element type for arrays

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L158)

**Returns**

`Boolean` — whether this attribute can be omitted

---

### #sortable?

`#sortable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L152)

**Returns**

`Boolean` — whether sorting is enabled

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L63)

**Returns**

`Symbol` — data type

---

### #writable?

`#writable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L172)

**Returns**

`Boolean` — whether this attribute is writable

---

### #writable_for?

`#writable_for?(action)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/attribute.rb#L179)

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | `Symbol` | the action to check (:create or :update) |

**Returns**

`Boolean` — whether this attribute is writable for the given action

---
