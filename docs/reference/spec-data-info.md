---
order: 29
prev: false
next: false
---

# Spec::Data::Info

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/info.rb#L16)

Wraps API metadata/info.

**Example**

```ruby
info = data.info
info.title            # => "My API"
info.version          # => "1.0.0"
info.description      # => "API for managing resources"
info.contact&.email   # => "support@example.com"
info.license&.name    # => "MIT"
```

## Instance Methods

### #contact

`#contact`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/info.rb#L54)

**Returns**

[Contact](contact), `nil` — contact information

**See also**

- [Contact](contact)

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/info.rb#L35)

**Returns**

`String`, `nil` — API description

---

### #license

`#license`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/info.rb#L61)

**Returns**

[License](license), `nil` — license information

**See also**

- [License](license)

---

### #servers

`#servers`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/info.rb#L68)

**Returns**

`Array<Server>` — server definitions

**See also**

- [Server](server)

---

### #summary

`#summary`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/info.rb#L41)

**Returns**

`String`, `nil` — short summary

---

### #terms_of_service

`#terms_of_service`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/info.rb#L47)

**Returns**

`String`, `nil` — terms of service URL

---

### #title

`#title`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/info.rb#L23)

**Returns**

`String`, `nil` — API title

---

### #version

`#version`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/info.rb#L29)

**Returns**

`String`, `nil` — API version

---
