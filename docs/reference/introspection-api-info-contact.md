---
order: 31
prev: false
next: false
---

# Introspection::API::Info::Contact

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/contact.rb#L15)

Wraps API contact information.

**Example**

```ruby
contact = api.info.contact
contact.name   # => "API Support"
contact.email  # => "support@example.com"
contact.url    # => "https://example.com/support"
```

## Instance Methods

### #email

`#email`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/contact.rb#L28)

**Returns**

`String`, `nil` — contact email

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/contact.rb#L22)

**Returns**

`String`, `nil` — contact name

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/contact.rb#L40)

**Returns**

`Hash` — structured representation

---

### #url

`#url`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/contact.rb#L34)

**Returns**

`String`, `nil` — contact URL

---
