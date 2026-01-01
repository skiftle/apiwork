---
order: 26
prev: false
next: false
---

# Spec::Data::Contact

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/contact.rb#L14)

Wraps API contact information.

**Example**

```ruby
contact = data.info.contact
contact.name   # => "API Support"
contact.email  # => "support@example.com"
contact.url    # => "https://example.com/support"
```

## Instance Methods

### #email

`#email`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/contact.rb#L27)

**Returns**

`String`, `nil` — contact email

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/contact.rb#L21)

**Returns**

`String`, `nil` — contact name

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/contact.rb#L39)

**Returns**

`Hash` — structured representation

---

### #url

`#url`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/contact.rb#L33)

**Returns**

`String`, `nil` — contact URL

---
