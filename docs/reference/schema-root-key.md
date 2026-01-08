---
order: 55
prev: false
next: false
---

# Schema::RootKey

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/root_key.rb#L15)

Represents the JSON root key for a schema.

Root keys wrap response data in a named container.
Used by adapters to structure JSON responses.

**Example**

```ruby
root_key = InvoiceSchema.root_key
root_key.singular  # => "invoice"
root_key.plural    # => "invoices"
```

## Instance Methods

### #initialize

`#initialize(singular, plural = singular.pluralize)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/root_key.rb#L29)

Creates a new root key.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `singular` | `String` | root key for single records |
| `plural` | `String` | root key for collections (default: singular.pluralize) |

**Returns**

[RootKey](schema-root-key) — a new instance of RootKey

---

### #plural

`#plural`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/root_key.rb#L18)

**Returns**

`String` — root key for collections

---

### #singular

`#singular`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/root_key.rb#L22)

**Returns**

`String` — root key for single records

---

### #to_s

`#to_s`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/root_key.rb#L38)

Returns the singular root key.

**Returns**

`String`

---
