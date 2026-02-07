---
order: 49
prev: false
next: false
---

# Contact

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/contact.rb#L32)

The email for this contact.

**Returns**

`String`, `nil`

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/contact.rb#L24)

The name for this contact.

**Returns**

`String`, `nil`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/contact.rb#L48)

Converts this contact to a hash.

**Returns**

`Hash`

---

### #url

`#url`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/contact.rb#L40)

The URL for this contact.

**Returns**

`String`, `nil`

---
