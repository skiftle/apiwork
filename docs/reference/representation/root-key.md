---
order: 82
prev: false
next: false
---

# RootKey

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/root_key.rb#L20)

The plural form for this root key.

**Returns**

`String`

---

### #singular

`#singular`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/root_key.rb#L26)

The singular form for this root key.

**Returns**

`String`

---
