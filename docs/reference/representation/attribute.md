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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L142)

**Returns**

`Boolean`

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L26)

**Returns**

`String`, `nil`

---

### #enum

`#enum`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L30)

**Returns**

`Array<Object>`, `nil`

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L34)

**Returns**

`Object`, `nil`

---

### #filterable?

`#filterable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L148)

**Returns**

`Boolean`

---

### #format

`#format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L38)

**Returns**

`Symbol`, `nil`

---

### #max

`#max`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L42)

**Returns**

`Integer`, `nil`

---

### #min

`#min`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L46)

**Returns**

`Integer`, `nil`

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L50)

**Returns**

`Symbol`

---

### #nullable?

`#nullable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L166)

**Returns**

`Boolean`

---

### #of

`#of`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L56)

The element type when [#type](#type) is `:array`.

**Returns**

`Symbol`, `nil`

---

### #optional?

`#optional?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L160)

**Returns**

`Boolean`

---

### #sortable?

`#sortable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L154)

**Returns**

`Boolean`

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L60)

**Returns**

`Symbol`

---

### #writable?

`#writable?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L175)

**Returns**

`Boolean`

**See also**

- [#writable_for?](#writable-for?)

---

### #writable_for?

`#writable_for?(action)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/attribute.rb#L183)

**Parameters**

| Name | Type | Description |
|------|------|------|
| `action` | `Symbol` | :create or :update |

**Returns**

`Boolean`

**See also**

- [#writable?](#writable?)

---
