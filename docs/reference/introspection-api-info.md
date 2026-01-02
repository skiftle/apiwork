---
order: 21
prev: false
next: false
---

# Introspection::API::Info

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L16)

Wraps API metadata/info.

**Example**

```ruby
info = api.info
info.title            # => "My API"
info.version          # => "1.0.0"
info.description      # => "API for managing resources"
info.contact&.email   # => "support@example.com"
info.license&.name    # => "MIT"
```

## Instance Methods

### #contact

`#contact`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L54)

**Returns**

`Info::Contact`, `nil` — contact information

**See also**

- [Info::Contact](info-contact)

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L35)

**Returns**

`String`, `nil` — API description

---

### #license

`#license`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L61)

**Returns**

`Info::License`, `nil` — license information

**See also**

- [Info::License](info-license)

---

### #servers

`#servers`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L68)

**Returns**

`Array<Info::Server>` — server definitions

**See also**

- [Info::Server](info-server)

---

### #summary

`#summary`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L41)

**Returns**

`String`, `nil` — short summary

---

### #terms_of_service

`#terms_of_service`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L47)

**Returns**

`String`, `nil` — terms of service URL

---

### #title

`#title`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L23)

**Returns**

`String`, `nil` — API title

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L74)

**Returns**

`Hash` — structured representation

---

### #version

`#version`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L29)

**Returns**

`String`, `nil` — API version

---
