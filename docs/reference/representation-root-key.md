---
order: 68
prev: false
next: false
---

# Representation::RootKey

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/root_key.rb#L15)

Represents the JSON root key for a representation.

Root keys wrap response data in a named container.
Used by adapters to structure JSON responses.

**Example**

```ruby
root_key = InvoiceRepresentation.root_key
root_key.singular  # => "invoice"
root_key.plural    # => "invoices"
```

## Instance Methods

### #plural

`#plural`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/root_key.rb#L18)

**Returns**

`String` — root key for collections

---

### #singular

`#singular`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/root_key.rb#L22)

**Returns**

`String` — root key for single records

---
